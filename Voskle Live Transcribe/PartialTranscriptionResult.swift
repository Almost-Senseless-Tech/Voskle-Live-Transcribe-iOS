//
//  PartialTranscriptionResult.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 22.06.24.
//

import Foundation

class PartialTranscriptionResult: Decodable {
    var text: String
    
    enum CodingKeys: String, CodingKey {
        case text = "partial"
    }
    
    init(text: String) {
        self.text = text
    }
    
    func getText() -> String {
        return text
    }
}
