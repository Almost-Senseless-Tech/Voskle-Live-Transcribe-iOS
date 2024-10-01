//
//  language.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 13.06.24.
//

import Foundation

enum Language: String, CaseIterable, Identifiable, Comparable {
    case arabic = "ar"
    case breton = "br"
    case catalan = "ca"
    case chinese = "cn"
    case czech = "cs"
    case german = "de"
    case englishIN = "en-in"
    case englishUS = "en-us"
    case esperanto = "eo"
    case spanish = "es"
    case persian = "fa"
    case french = "fr"
    case gujarati = "gu"
    case hindi = "hi"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case kazakh = "kz"
    case dutch = "nl"
    case polish = "pl"
    case portuguese = "pt"
    case russian = "ru"
    case swedish = "sv"
    case turkish = "tr"
    case ukrainian = "uk"
    case uzbek = "uz"
    case vietnamese = "vn"
    
    var id: String { self.rawValue }
    
    var modelPath: String {
        switch self {
        case .arabic:
            return "vosk-model-ar-mgb2-0.4"
        case .breton:
            return "vosk-model-br-0.7"
        case .catalan:
            return "vosk-model-small-ca-0.4"
        case .chinese:
            return "vosk-model-small-cn-0.22"
        case .czech:
            return "vosk-model-small-cs-0.4-rhasspy"
        case .german:
            return "vosk-model-small-de-0.15"
        case .englishIN:
            return "vosk-model-small-en-in-0.4"
        case .englishUS:
            return "vosk-model-small-en-us-0.15"
        case .esperanto:
            return "vosk-model-small-eo-0.42"
        case .spanish:
            return "vosk-model-small-es-0.42"
        case .persian:
            return "vosk-model-small-fa-0.5"
        case .french:
            return "vosk-model-small-fr-0.22"
        case .gujarati:
            return "vosk-model-small-gu-0.42"
        case .hindi:
            return "vosk-model-small-hi-0.22"
        case .italian:
            return "vosk-model-small-it-0.22"
        case .japanese:
            return "vosk-model-small-ja-0.22"
        case .korean:
            return "vosk-model-small-ko-0.22"
        case .kazakh:
            return "vosk-model-small-kz-0.15"
        case .dutch:
            return "vosk-model-small-nl-0.22"
        case .polish:
            return "vosk-model-small-pl-0.22"
        case .portuguese:
            return "vosk-model-small-pt-0.3"
        case .russian:
            return "vosk-model-small-ru-0.22"
        case .swedish:
            return "vosk-model-small-sv-rhasspy-0.15"
        case .turkish:
            return "vosk-model-small-tr-0.3"
        case .ukrainian:
            return "vosk-model-small-uk-v3-small"
        case .uzbek:
            return "vosk-model-small-uz-0.22"
        case .vietnamese:
            return "vosk-model-small-vn-0.4"
        }
    }
    
    var localizedName: String {
        switch self {
        case .arabic:
            return NSLocalizedString("Arabic", comment: "Localized language name for Arabic")
        case .breton:
            return NSLocalizedString("Breton", comment: "Localized language name for Breton")
        case .catalan:
            return NSLocalizedString("Catalan", comment: "Localized language name for Catalan")
        case .chinese:
            return NSLocalizedString("Chinese", comment: "Localized language name for Chinese")
        case .czech:
            return NSLocalizedString("Czech", comment: "Localized language name for Czech")
        case .german:
            return NSLocalizedString("German", comment: "Localized language name for German")
        case .englishIN:
            return NSLocalizedString("Indian English", comment: "Localized language name for Indian English")
        case .englishUS:
            return NSLocalizedString("American English", comment: "Localized language name for American English")
        case .esperanto:
            return NSLocalizedString("Esperanto", comment: "Localized language name for Esperanto")
        case .spanish:
            return NSLocalizedString("Spanish", comment: "Localized language name for Spanish")
        case .persian:
            return NSLocalizedString("Persian", comment: "Localized language name for Persian")
        case .french:
            return NSLocalizedString("French", comment: "Localized language name for French")
        case .gujarati:
            return NSLocalizedString("Gujarati", comment: "Localized language name for Gujarati")
        case .hindi:
            return NSLocalizedString("Hindi", comment: "Localized language name for Hindi")
        case .italian:
            return NSLocalizedString("Italian", comment: "Localized language name for Italian")
        case .japanese:
            return NSLocalizedString("Japanese", comment: "Localized language name for Japanese")
        case .korean:
            return NSLocalizedString("Korean", comment: "Localized language name for Korean")
        case .kazakh:
            return NSLocalizedString("Kazakh", comment: "Localized language name for Kazakh")
        case .dutch:
            return NSLocalizedString("Dutch", comment: "Localized language name for Dutch")
        case .polish:
            return NSLocalizedString("Polish", comment: "Localized language name for Polish")
        case .portuguese:
            return NSLocalizedString("Portuguese", comment: "Localized language name for Portuguese")
        case .russian:
            return NSLocalizedString("Russian", comment: "Localized language name for Russian")
        case .swedish:
            return NSLocalizedString("Swedish", comment: "Localized language name for Swedish")
        case .turkish:
            return NSLocalizedString("Turkish", comment: "Localized language name for Turkish")
        case .ukrainian:
            return NSLocalizedString("Ukrainian", comment: "Localized language name for Ukrainian")
        case .uzbek:
            return NSLocalizedString("Uzbek", comment: "Localized language name for Uzbek")
        case .vietnamese:
            return NSLocalizedString("Vietnamese", comment: "Localized language name for Vietnamese")
        }
    }
    
    var isAvailable: Bool {
        let fileManager = FileManager.default
        let modelDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("models").appendingPathComponent(self.modelPath)
        var isDirectory: ObjCBool = true
        let exists = fileManager.fileExists(atPath: modelDir.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    static func < (lhs: Language, rhs: Language) -> Bool {
        lhs.localizedName < rhs.localizedName
    }
}
