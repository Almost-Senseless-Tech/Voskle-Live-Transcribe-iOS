//
//  Vosk.swift
//  VoskApiTest
//
//  Created by Niсkolay Shmyrev on 01.03.20.
//  Copyright © 2020-2021 Alpha Cephei. All rights reserved.
//

import Foundation

public final class VoskModel {
    
    var model : OpaquePointer!
    var spkModel : OpaquePointer!
    
    init(modelPath: String, speakerModelPath: String?) {
        
        // Set to -1 to disable logs
        vosk_set_log_level(0)
        model = vosk_model_new(modelPath)
        
        if (speakerModelPath != nil) {
            spkModel = vosk_spk_model_new(speakerModelPath!)
        }
    }
    
    deinit {
        vosk_model_free(model)
        vosk_spk_model_free(spkModel)
    }
    
}

