//
//  FontSize.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 03.07.24.
//

import Foundation

enum FontSize: String, CaseIterable, Identifiable, Comparable {
    case normal = "normal"
    case large = "large"
    case largest = "largest"
    
    var id: String { return self.rawValue }
    
    var localizedName: String {
        switch self {
        case .normal:
            return NSLocalizedString("Normal", comment: "normal font size option")
        case .large:
            return NSLocalizedString("Large", comment: "Large font size option")
        case .largest:
            return NSLocalizedString("Largest", comment: "Largest font size option")
        }
    }
        
    var size: CGFloat {
        switch self {
        case .normal:
            return 16
        case .large:
            return 32
        case .largest:
            return 64
        }
    }
    
    var lineSpacing: CGFloat {
        switch self {
        case .normal:
            return 8
        case .large:
            return 16
        case .largest:
            return 30
        }
    }
    
    static func < (lhs: FontSize, rhs: FontSize) -> Bool {
        return lhs.size < rhs.size
    }
}
