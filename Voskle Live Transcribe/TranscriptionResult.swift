//
//  TranscriptionResult.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 22.06.24.
//

import Foundation

class TranscriptionResult: Decodable {
    var text: String
    var speakerFingerprint: [Float]?
    
    enum CodingKeys: String, CodingKey {
        case text
        case speakerFingerprint = "spk_data"
    }
    
    init(text: String, speakerFingerprint: [Float]? = nil) {
        self.text = text
        self.speakerFingerprint = speakerFingerprint
    }
    
    func getText() -> String {
        return text
    }
}
