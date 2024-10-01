//
//  VLTViewModel.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 13.06.24.
//


import AVFoundation
import Combine
import Foundation
import SwiftUI
import Zip

/**
 The view model for the Voskle Live Transcribe app.
 
 This view model gets used in (almost) all parts of the app
 and therefore gets provided as an environment object from the
 ContentView down.
 */
class VLTViewModel: NSObject, ObservableObject, URLSessionDownloadDelegate {
    /**
     The currently selected transcription language.
     
     Defaults to American English.
     */
    @Published var language: Language {
        didSet {
            UserDefaults.standard.transcriptionLanguage = language
        }
    }
    
    /// Whether or not to accept keyboard input on the transcript view.
    @Published var keyboardInput: Bool = false
    
    /// Whether or not to show an integrated high contrast mode in dark mode
    @Published var highContrast: Bool {
        didSet {
            UserDefaults.standard.highContrast = highContrast
        }
    }
    
    /// The theme setting - light, dark or auto.
    @Published var themeSetting: ThemeSetting {
        didSet {
            UserDefaults.standard.themeSetting = themeSetting
        }
    }
    
    /// Whether or not to automatically scroll onscreen.
    @Published var autoscroll: Bool {
        didSet {
            UserDefaults.standard.autoscroll = autoscroll
        }
    }
    
    /// Whether or not to automatically scroll on braille displays.
    @Published var accessibilityAutoscroll: Bool {
        didSet {
            UserDefaults.standard.accessibilityAutoscroll = accessibilityAutoscroll
        }
    }
    
    /// The text that has already been transcribed.
    @Published var transcript: String
    
    /// The current status of the app.
    @Published var appStatus: AppStatus
    
    /// Whether or not audio input is currently getting recorded.
    @Published var recording: Bool
    
    /// The progress of the model download.
    @Published var downloadProgress: Double = 0.0
    
    /// Whether or not there's a model download in progress.
    @Published var isDownloading: Bool = false
    
    /**
     Whether or not the most recent download was successful.
     
     Used to display a notification dialog.
     */
    @Published var downloadSuccessful: Bool = false
    
    /// Whether or not to display a prompt to download the current language model.
    @Published var showDownloadPrompt: Bool = false
    
    /// If not nil, this signals the app encountered an error and displays an error dialog.
    @Published var error: AppErrorKind? = nil
    
    /// Whether or not to show the insufficient permissions dialog
    @Published var showInsufficientPermissions: Bool = false
    
    /// Whether or not transcription should stop when the app goes into the bakcground.
    @Published var keepTranscribingInBackground: Bool {
        didSet {
            UserDefaults.standard.keepTranscribingInBackground = keepTranscribingInBackground
        }
    }
    
    /// The font size of the transcript (normal, large, largest).
    @Published var transcriptFontSize: FontSize {
        didSet {
            UserDefaults.standard.transcriptFontSize = transcriptFontSize
        }
    }
    
    /// Used internally to manage tasks associated with downloading models.
    private var cancellables = Set<AnyCancellable>()
    /// Used internally to record audio data from the microphone.
    private var audioEngine: AVAudioEngine? = nil
    /// Used internally to handle transcription results asynchronously.
    private var processingQueue: DispatchQueue
    /// The VOSK model for the current transcription language.
    private var model: VoskModel? = nil
    
    /// Sets up some properties that need special handling
    override init() {
        self.language = UserDefaults.standard.transcriptionLanguage
        self.autoscroll = UserDefaults.standard.autoscroll
        self.accessibilityAutoscroll = UserDefaults.standard.accessibilityAutoscroll
        self.themeSetting = UserDefaults.standard.themeSetting
        self.highContrast = UserDefaults.standard.highContrast
        self.keepTranscribingInBackground = UserDefaults.standard.keepTranscribingInBackground
        self.transcriptFontSize = UserDefaults.standard.transcriptFontSize
        self.transcript = ""
        self.recording = false
        self.processingQueue = DispatchQueue(label: "recognizerQueue")
        self.appStatus = UserDefaults.standard.transcriptionLanguage.isAvailable ? .ready : .notDownloaded
        super.init()
        if !self.language.isAvailable {
            self.showDownloadPrompt = true
        }
    }
    
    /**
     Sets the transcription language.
     
     - parameter language: The new transcription language.
     */
    func setLanguage(language: Language) {
        self.language = language
        if language.isAvailable {
            self.appStatus = .ready
        } else {
            self.appStatus = .notDownloaded
        }
    }
    
    /**
     Set the keyboard input on or off.
     
     - parameter on: Whether or not keyboard input is active.
     */
    func setKeyboardInput(on: Bool) {
        self.keyboardInput = on
    }
    
    /**
     Sets the current error.
     
     - parameter kind: Which kind of error the app encountered.
     */
    func setError(kind: AppErrorKind) {
        self.error = kind
    }
    
    /// Resets the current app error to nil.
    func resetError() {
        self.error = nil
    }
    
    /// Sets the transcript to an empty String.
    func clearTranscript() {
        self.transcript = ""
    }
    
    /**
     Sets the recording status of the app.
     
     - parameter recording: Whether or not the app is recording audio data.
     */
    func setRecording(recording: Bool) {
        self.recording = recording
    }
    
    /**
     Sets the `downloadSuccessful` property.
     
     - parameter success: Whether or not to show the download success dialog.
     */
    func setDownloadSuccessful(success: Bool) {
        self.downloadSuccessful = success
    }
    
    /**
     Sets the `showDownloadPrompt` property.
     
     - parameter prompt: Whether or not to show a prompt for downloading the current language's model.
     */
    func setShowDownloadPrompt(prompt: Bool) {
        self.showDownloadPrompt = prompt
    }
    
    /**
     Sets the `showInsufficientPermissions` property.
     
     - parameter show: Whether or not to show the dialog.
     */
    func setShowInsufficientPermissions(show: Bool) {
        self.showInsufficientPermissions = show
    }
    
    
    /**
     Utility function to check whether the app currently has an active error.
     
     - returns: `true` if the èrror` property isn't nil, `false` otherwise.
     */
    func hasError() -> Bool {
        return self.error != nil
    }
    
    /**
     This function drafts an email URL and attempts opening it.
     
     It already populates the email with the correct recipient, a reasonable
     subject and some data relevant for debugging any errors.
     */
    func contactUs() {
        let recipient = "project@almost-senseless.tech"
        let subject = "[VLT] Feedback about the iOS app"
        let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let iOSVersion = UIDevice.current.systemVersion
        let deviceModel = deviceModel()
        let body = "\n\n-----\nV\(appVersionString) (\(appVersion)); iOS \(iOSVersion); \(deviceModel)"
        
        let url = createEmailURL(to: recipient, subject: subject, body: body)
        
        if url != nil {
            if UIApplication.shared.canOpenURL(url!) {
                /*
                 For some reason I don't even want to begin to unpickle,
                 the resulting email content is invisible in the default apple Mail
                 app if you use VoiceOver. I bet it's visible for sighted people,
                 but to a blind user it looks like this email is blank.
                 
                 Insert internal screaming here.
                 */
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                setError(kind: .cannotOpenContactURL)
            }
        } else {
            setError(kind: .invalidContactURL)
        }
    }
    
    /**
     Downloads a language model or the speaker recognition model.
     
     The model gets downloaded as a ZIP file from models.almost-senseless.tech
     and unzipped to the app-specific cache directory.
     
     - parameter speakerModel: Whether or not to download the speaker model.
     */
    func downloadModel(speakerModel: Bool = false) {
        self.showDownloadPrompt = false
        self.isDownloading = true
        self.appStatus = .downloading
        downloadProgress = 0.0
        let urlStr = if speakerModel {
            "https://models.vlt.almost-senseless.tech/vosk-model-spk-0.4.zip" } else {
                "https://models.vlt.almost-senseless.tech/\(language.modelPath).zip"
            }
        let url = URL(string: urlStr)!
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        // The actual downloading and unzipping happens in functions below.
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
    
    /**
     Pauses, unpauses and starts the audio engine as appropriate.
     
     Since starting the audio engine and setting up a VOSK recognizer
     is somewhat slow (~1.5 s), we usually just want to pause and unpause
     the audio stream.
     */
    func toggleRecording() {
        if self.recording {
            self.audioEngine!.pause()
            self.appStatus = .paused
            self.setRecording(recording: false)
        } else if self.audioEngine == nil {
            startAudioEngine()
        } else {
            do {
                try self.audioEngine!.start()
                DispatchQueue.main.async {
                    self.setRecording(recording: true)
                    self.appStatus = .recording
                }
            } catch {
                DispatchQueue.main.async {
                    self.setError(kind: .audioEngineError(error.localizedDescription))
                }
            }
        }
    }
    
    /**
     Stops the audio engine and frees the VOSK model and recognizer.
     
     Should only get called when the transcription language changed.
     */
    func stopAudioEngine() {
        self.audioEngine?.stop()
        self.audioEngine?.reset()
        self.audioEngine = nil
        self.model = nil
        if language.isAvailable {
            self.appStatus = .ready
        } else {
            self.appStatus = .notDownloaded
        }
        self.setRecording(recording: false)
    }
    
    /**
     Downloads a model file to a temporary location and initiates the unzipping process.
     
     - parameter session: The active URL session.
     - parameter downloadTask: The current download task.
     - parameter location: The temporary file's location.
     */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        let destinationURL = fileManager.temporaryDirectory.appendingPathComponent("downloadedModel.zip")
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: location, to: destinationURL)
            DispatchQueue.main.async {
                print("Download succeeded. Attempting to unzip...")
                self.isDownloading = false
                self.appStatus = .unpacking
                self.downloadProgress = 1.0
            }
            let unzipDestinationURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("models")
            self.unzipFile(at: destinationURL, to: unzipDestinationURL)
        } catch {
            DispatchQueue.main.async {
                self.isDownloading = false
                self.appStatus = .notDownloaded
                self.setError(kind: .modelDownloadFailed(self.language))
            }
        }
    }
    
    /**
     Tracks the progress of the model download.
     
     - parameter session: The active URL session.
     - parameter downloadTask: The current download task.
     - parameter bytesWritten: How many bytes have been written since the last call.
     - parameter totalBytesWritten: How many bytes have been written on disk (i.e., how much got downloaded already).
     - parameter totalBytesExpectedToWrite: The size of the file that's getting downloaded, usually as per the header
     */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.downloadProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        }
    }
    
    /**
     Unzips a ZIP arhive to the app-specific cache directory.
     
     - parameter sourceURL: Where the ZIP archive is located.
     - parameter destinationURL: Where to unzip the contents.
     */
    private func unzipFile(at sourceURL: URL, to destinationURL: URL) {
        do {
            let fileManager = FileManager.default
            var isDirectory: ObjCBool = true
            let exists = fileManager.fileExists(atPath: destinationURL.path, isDirectory: &isDirectory)
            if !exists || !isDirectory.boolValue {
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: false)
            }
            
            try Zip.unzipFile(sourceURL, destination: destinationURL, overwrite: true, password: nil)
            
            DispatchQueue.main.async {
                self.appStatus = .ready
                self.downloadSuccessful = true
            }
        } catch {
            DispatchQueue.main.async {
                self.setError(kind: .modelDownloadFailed(self.language))
                self.appStatus = .notDownloaded
                self.isDownloading = false
            }
        }
    }
    
    /**
     Launches the audio engine and initializes VOSK speech recognition.
     
     Here Be Dragons! (Hopefully not, though.)
     
     This function takes a second to complete, so it should only run when really necessary.
     */
    private func startAudioEngine() {
        do {
            // First configure various aspects of the audio processing.
            DispatchQueue.main.async {
                self.appStatus = .modelInit
            }
            self.audioEngine = AVAudioEngine()
            let inputNode = audioEngine!.inputNode
            let inputFormat = inputNode.inputFormat(forBus: 0)
            // Next, get the VoskModel and Vosk instance set up.
            let formatPcm = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: true)
            let fileManager = FileManager.default
            let fullModelPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("models").appendingPathComponent(language.modelPath)
            // TODO Make usage of speaker models possible.
            self.model = VoskModel(modelPath: fullModelPath.path, speakerModelPath: nil)
            let recognizer = Vosk(model: model!, sampleRate: Float(inputFormat.sampleRate))
            // Hook the recognizer up to the audio stream
            inputNode.installTap(onBus: 0, bufferSize: UInt32(inputFormat.sampleRate / 10), format: formatPcm) { buffer, time in
                self.processingQueue.async {
                    let res = recognizer.recognizeData(buffer: buffer)
                    DispatchQueue.main.async {
                        /*
                         The result is in JSON format and can be a Result
                         or a PartialResult. We need to handle those
                         differently.
                         */
                        if res.contains("\"text\"") {
                            self.processResult(rawData: res)
                        } else if res.contains("\"partial\"") {
                            self.processPartialResult(rawData: res)
                        }
                    }
                }
            }
            audioEngine!.prepare()
            try audioEngine!.start()
            DispatchQueue.main.async {
                self.appStatus = .recording
                self.setRecording(recording: true)
            }
        } catch {
            DispatchQueue.main.async {
                self.setError(kind: .audioEngineError(error.localizedDescription))
            }
        }
    }
    
    /**
     Processes a `TranscriptionResult`, appending it to the last line followed by a period.
     
     Known issue: The way this works, right-to-left languages like Persian
     or Arabic don't get represented correctly as of yet (I think).
     
     I'm also unsure if Chinese, Korean and Japanese use periods at all...
     
     - parameter rawData: The data yielded by the VOSK speech recognition library.
     */
    private func processResult(rawData: String) {
        if let data = rawData.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(TranscriptionResult.self, from: data)
                let resultText = result.getText()
                if resultText.isEmpty {
                    return
                }
                DispatchQueue.main.async {
                    // Using `appending` is somewhat more efficient than format Strings.
                    if self.transcript.isEmpty || !self.transcript.contains(".") {
                        self.transcript = resultText.appending(". ")
                    } else if self.transcript.hasSuffix(". ") {
                        self.transcript = self.transcript.appending(resultText).appending(". ")
                    } else if self.transcript.hasSuffix(".") {
                        self.transcript = self.transcript.appending(" ").appending(resultText).appending(". ")
                    } else {
                        // There's a partial result at the end of the text which
                        // we need to replace.
                        let range = self.transcript.range(of: ".", options: .backwards)!
                        let prefix = self.transcript[self.transcript.startIndex..<range.upperBound]
                        self.transcript = prefix.appending(" ").appending(resultText).appending(". ")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.setError(kind: .dataError(rawData))
                }
            }
        }
    }
    
    /**
     Handles `PartialTranscriptionResult`s, appending them to the end of the transcript.
     
     - parameter rawData: The data yielded by the VOSK speech recognition.
     */
    private func processPartialResult(rawData: String) {
        if let data = rawData.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(PartialTranscriptionResult.self, from: data)
                let resultText = result.getText()
                if resultText.isEmpty {
                    return
                }
                DispatchQueue.main.async {
                    if self.transcript.isEmpty || !self.transcript.contains(".") {
                        self.transcript = resultText
                    } else {
                        // Find the last period and replace everything after it.
                        let range = self.transcript.range(of: ".", options: .backwards)!
                        let prefix = self.transcript[self.transcript.startIndex..<range.upperBound]
                        self.transcript = prefix.appending(" ").appending(resultText)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.setError(kind: .dataError(rawData))
                }
            }
        }
    }
}

extension UserDefaults {
    private enum Keys {
        static let transcriptionLanguage = "transcriptionLanguage"
        static let autoscroll = "autoscroll"
        static let accessibilityAutoscroll = "accessibilityAutoscroll"
        static let highContrast = "highContrast"
        static let themeSetting = "themeSetting"
        static let keepTranscribingInBackground = "keepTranscribingInBackground"
        static let transcriptFontSize = "transcriptFontSize"
    }
    
    var transcriptionLanguage: Language {
        get {
            return Language(rawValue: string(forKey: Keys.transcriptionLanguage) ?? "en-us")!
        }
        set {
            set(newValue.rawValue, forKey: Keys.transcriptionLanguage)
        }
    }
    
    var autoscroll: Bool {
        get {
            // bool(forKey: ...) returns false if the key does not exist, but we want default true
            if object(forKey: Keys.autoscroll) == nil {
                return true
            }
            return bool(forKey: Keys.autoscroll)
        }
        set {
            set(newValue, forKey: Keys.autoscroll)
        }
    }
    
    var accessibilityAutoscroll: Bool {
        get {
            // Here we want default false, so it's fine.
            return bool(forKey: Keys.accessibilityAutoscroll)
        }
        set {
            set(newValue, forKey: Keys.accessibilityAutoscroll)
        }
    }
    
    var highContrast: Bool {
        get {
            return bool(forKey: Keys.highContrast)
        }
        set {
            set(newValue, forKey: Keys.highContrast)
        }
    }
    
    var themeSetting: ThemeSetting {
        get {
            return ThemeSetting(rawValue: string(forKey: Keys.themeSetting) ?? "auto")!
        }
        set {
            set(newValue.rawValue, forKey: Keys.themeSetting)
        }
    }
    
    var keepTranscribingInBackground: Bool {
        get {
            return bool(forKey: Keys.keepTranscribingInBackground)
        }
        set {
            set(newValue, forKey: Keys.keepTranscribingInBackground)
        }
    }
    
    var transcriptFontSize: FontSize {
        get {
            return FontSize(rawValue: string(forKey: Keys.transcriptFontSize) ?? "normal")!
        }
        set {
            set(newValue.rawValue, forKey: Keys.transcriptFontSize)
        }
    }
}
