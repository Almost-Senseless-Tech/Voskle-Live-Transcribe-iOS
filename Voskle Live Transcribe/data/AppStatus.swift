//
//  AppStatus.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 28.06.24.
//

import Foundation

enum AppStatus {
    case notDownloaded
    case downloading
    case unpacking
    case ready
    case modelInit
    case recording
    case paused
    
    var localizedStatus: String {
        switch self {
        case .notDownloaded:
            return NSLocalizedString("Model not downloaded", comment: "notDownloaded app status")
        case .downloading:
            return NSLocalizedString("Downloading model...", comment: "downloading app status")
        case .unpacking:
            return NSLocalizedString("Unpacking model...", comment: "unpacking app status")
        case .ready:
            return NSLocalizedString("Ready", comment: "ready app status")
        case .modelInit:
            return NSLocalizedString("Setting model up...", comment: "modelInit app status")
        case .recording:
            return NSLocalizedString("Recording", comment: "recording app status")
        case .paused:
            return NSLocalizedString("Transcription paused", comment: "Paused app status")
        }
    }
}
