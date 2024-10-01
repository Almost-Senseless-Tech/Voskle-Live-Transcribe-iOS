//
//  ContentView.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 13.04.24.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: VLTViewModel
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.appStatus != .downloading && viewModel.appStatus != .unpacking && !viewModel.keyboardInput {
                    LanguagePicker()
                    
                    Divider()
                        .accessibilityHidden(true)
                }
                TranscriptView()
                
                Divider()
                    .accessibilityHidden(true)
                if !viewModel.keyboardInput {
                    HStack {
                        Button(action: {
                            checkAndRequestMicPermissions()
                        }) {
                            let buttonLabel = viewModel.recording ? NSLocalizedString("Stop transcribing", comment: "Label for the stop transcribing button") : NSLocalizedString("Start transcribing", comment: "Label for the start transcribing button")
                            Image(systemName: viewModel.recording ? "stop.circle" : "record.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text(buttonLabel)
                                .cornerRadius(8)
                                .padding()
                                .disabled(!viewModel.language.isAvailable)
                        }
                        
                        Button(action: {
                            viewModel.clearTranscript()
                        }) {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text("Delete transcript", comment: "Label for the delete transcript button")
                                .cornerRadius(8)
                                .padding()
                        }
                        .disabled(viewModel.transcript.isEmpty)
                    }
                    .padding()
                    
                    Divider()
                        .accessibilityHidden(true)
                    
                    HStack {
                        Text(viewModel.appStatus.localizedStatus)
                            .padding()
                            .onChange(of: viewModel.appStatus) { _, status in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    UIAccessibility.post(notification: .announcement, argument: status.localizedStatus)
                                }
                            }
                        if viewModel.isDownloading {
                            ProgressView(value: viewModel.downloadProgress, total: 1.0)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .padding()
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text("Settings")
                                .padding()
                                .cornerRadius(8)
                        }
                        .frame(height: 50)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $viewModel.keyboardInput) {
                        HStack {
                            Image(systemName: viewModel.keyboardInput ? "pencil.slash" : "pencil.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                            
                            Text("Keyboard input", comment: "Label of the keyboard input toggle")
                                .padding()
                                .cornerRadius(8)
                                .accessibilityHint(NSLocalizedString("Toggles transcript editing on or off", comment: "Accessibility hint for the keyboard input toggle"))
                        }
                        .onChange(of: viewModel.keyboardInput) { _, keyboardInput in
                            if keyboardInput && viewModel.recording {
                                viewModel.toggleRecording()
                            }
                            
                            if !keyboardInput {
                                if !viewModel.transcript.hasSuffix(".") && !viewModel.transcript.hasSuffix(". ") {
                                    viewModel.transcript = viewModel.transcript.appending(". ")
                                }
                            }
                        }
                    }
                    .frame(height: 50)
                }
                ToolbarItem(placement: .principal) {
                    Spacer()
                }
            }
        }
        
        if viewModel.hasError() {
            if case .modelDownloadFailed(let _) = viewModel.error! {
                ErrorModal(title: viewModel.error!.localizedTitle, viewModel: viewModel) {
                    Text(viewModel.error!.localizedMessage)
                        .padding()
                    Divider()
                        .accessibilityHidden(true)
                    Button(action: {
                        viewModel.downloadModel()
                    }) {
                        Text("Try again", comment: "The label for the retry downloading button")
                            .accessibilityHint(NSLocalizedString("Attempts to download the model again", comment: "Accessibility hint for the retry downloading button"))
                    }
                    .padding()
                }
            } else {
                ErrorModal(title: viewModel.error!.localizedTitle, viewModel: viewModel) {
                    Text(viewModel.error!.localizedMessage)
                        .padding()
                }
            }
        }
        
        if viewModel.downloadSuccessful {
            ModalDialog(
                title: NSLocalizedString("Model downloaded successfully!", comment: "The title of the download success modal dialog."),
                onDismiss: {
                    viewModel.setDownloadSuccessful(success: false)
                }
            ) {
                Text("The model for \(viewModel.language.localizedName) was downloaded successfully. In the future you won't have to download it again until you uninstall the app.", comment: "The message of the download successful modal dialog.")
                    .padding()
            }
        }
        
        if viewModel.showDownloadPrompt {
            ModalDialog(
                title: NSLocalizedString("Confirm model download", comment: "The title of the model download confirmation dialog"),
                onDismiss: {
                    viewModel.setShowDownloadPrompt(prompt: false)
                }
            ) {
                Text("The model for \(viewModel.language.localizedName) isn't available on your device yet. Downloading it requires an internet connection and may take a minute. Do you want to download it?", comment: "The message of the download confirmation dialog")
                    .padding()
                Divider()
                    .accessibilityHidden(true)
                Button(action: {
                    viewModel.setShowDownloadPrompt(prompt: false)
                    viewModel.downloadModel()
                }) {
                    Text("Confirm", comment: "The label of the confirm download button")
                }
                .padding()
                Button(action: {
                    self.viewModel.setShowDownloadPrompt(prompt: false)
                }) {
                    Text("Cancel", comment: "The label for the cancel download button")
                }
                .padding()
            }
        }
            
        if viewModel.showInsufficientPermissions {
            ModalDialog(
                title: NSLocalizedString("Insufficient permissions", comment: "Title of the insufficient permissions dialog"),
                onDismiss: {
                    viewModel.setShowInsufficientPermissions(show: false)
                }
            ) {
                Text("Voskle Live Transcribe needs access to the microphone to record and transcribe speech. However, this access is currently denied. Go to the system settings to change that.")
                    .padding()
                Divider()
                    .accessibilityHidden(true)
                
                Button(action: {
                    let settingsURL = URL(string: UIApplication.openSettingsURLString)
                    if settingsURL != nil {
                        if UIApplication.shared.canOpenURL(settingsURL!) {
                            UIApplication.shared.open(settingsURL!, options: [:], completionHandler: { _ in
                                viewModel.setShowInsufficientPermissions(show: false)
                            })
                        } else {
                            viewModel.setError(kind: .settingsUrlOpeningFailed)
                        }
                    } else {
                        viewModel.setError(kind: .settingsUrlOpeningFailed)
                    }
                }) {
                    Text("Open settings")
                        .padding()
                }
            }
        }
    }
    
    /**
     Checks the microphone permissions, requests them if necessary, and shows
     relevant error and information dialogs.
     */
    private func checkAndRequestMicPermissions() {
        let micPermissions = AVAudioSession.sharedInstance().recordPermission
        switch micPermissions {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    viewModel.toggleRecording()
                }
                // Otherwise just do nothing; the user consciously clicked on decline.
            }
        case .granted:
            viewModel.toggleRecording()
        case .denied:
            viewModel.setShowInsufficientPermissions(show: true)
        @unknown default:
            viewModel.setError(kind: .unknownPermissionResult)
        }
    }
}
