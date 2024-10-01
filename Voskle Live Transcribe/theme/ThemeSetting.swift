//
//  ThemeSetting.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 02.07.24.
//

import Foundation

enum ThemeSetting: String {
    case auto = "auto"
    case dark = "dark"
    case light = "light"
    
    var localizedName: String {
        switch self {
        case .auto:
            return NSLocalizedString("Auto", comment: "Label for the auto theme setting")
        case .dark:
            return NSLocalizedString("Dark", comment: "Label for the dark theme setting")
        case .light:
            return NSLocalizedString("Light", comment: "Label for the light theme setting")
        }
    }
}
