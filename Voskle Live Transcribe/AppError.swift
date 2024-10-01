//
//  AppError.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 15.06.24.
//

import Foundation

enum AppErrorKind {
    case invalidContactURL
    case cannotOpenContactURL
    case modelDownloadFailed(Language)
    case modelUnpackingFailed(Language)
    case audioEngineError(String)
    case dataError(String)
    case settingsUrlOpeningFailed
    case unknownPermissionResult
    
    private var error: AppError {
        switch self {
        case .invalidContactURL:
            return AppError(
                title: NSLocalizedString("Invalid contact URL", comment: "the title of the invalid contact URL error"),
                localizedMessage: NSLocalizedString("The email URL to contact us is invalid. This is a definite bug, please manually write an email to projects@almost-senseless.tech to report this error.", comment: "The message for the invalid contact URL error")
            )
        case .cannotOpenContactURL:
            return AppError(
                title: NSLocalizedString("Cannot open contact URL", comment: "Title of the URL opening error"),
                localizedMessage: NSLocalizedString("Opening the contact URL failed. Please manually write an email to projects@almost-senseless.tech if the problem persists.", comment: "The message of the URL opening error")
            )
        case .modelDownloadFailed(let language):
            let format = NSLocalizedString("Downloading the language model for %@ failed. Please check your internet connection and make sure there's enough space on your device.", comment: "Message of the model download failed error")
            return AppError(
                title: NSLocalizedString("Model download failed", comment: "Title of the model download failed error"),
                localizedMessage: String(format: format, language.localizedName)
            )
        case .modelUnpackingFailed(let language):
            let format = NSLocalizedString("Unpacking the model for %@ to the cache directory failed. Please make sure there's enough space on your device.", comment: "Message of the model unpacking failed error")
            return AppError(
                title: NSLocalizedString("Model unpacking failed", comment: "The title of the model unpacking failed error"),
                localizedMessage: String(format: format, language.localizedName)
            )
        case .audioEngineError(let msg):
            let format = NSLocalizedString("Failed to start the audio engine and thus can't record audio input. Reason: %@", comment: "The message of the audio engine error")
            return AppError(
                title: NSLocalizedString("Audio engine error", comment: "The title of the audio engine error."),
                localizedMessage: String(format: format, msg)
            )
        case .dataError(let data):
            let format = NSLocalizedString("Received invalid data from the VOSK engine: %@", comment: "Message of the data error")
            return AppError(
                title: NSLocalizedString("Invalid data", comment: "Title of the data error"),
                localizedMessage: String(format: format, data)
            )
        case .settingsUrlOpeningFailed:
            return AppError(
                title: NSLocalizedString("Failed to open settings", comment: "Title for the settings opening failed error"),
                localizedMessage: NSLocalizedString("Couldn't open the app's area in the system settings. Please navigate there manually.", comment: "Message of the settings opening failed error")
            )
        case .unknownPermissionResult:
            return AppError(
                title: NSLocalizedString("Unknown permissions", comment: "title of the unknown permissions result error"),
                localizedMessage: NSLocalizedString("Got an unexpected result while checking the microphone permissions. Please contact us if the problem persists", comment: "message of the unknown permissions result error")
            )
        }
    }
    
    var localizedMessage: String {
        return self.error.localizedMessage
    }
    
    var localizedTitle: String {
        return self.error.title
    }
}

struct AppError {
    let title: String
    let localizedMessage: String
    
    init(title: String, localizedMessage: String) {
        self.title = title
        self.localizedMessage = localizedMessage
    }
}
