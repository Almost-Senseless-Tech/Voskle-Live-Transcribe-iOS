//
//  LanguagePicker.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 17.06.24.
//

import Foundation
import SwiftUI

struct LanguagePicker: View {
    @EnvironmentObject var viewModel: VLTViewModel
    
    var body: some View {
        Menu {
            ForEach(Language.allCases.sorted()) { language in
                if language == viewModel.language {
                    Button(action: {
                        if !viewModel.language.isAvailable {
                            viewModel.setShowDownloadPrompt(prompt: true)
                        }
                    }) {
                        Text(language.localizedName)
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                    .accessibilityAddTraits(.isSelected)
                } else {
                    Button(action: {
                        viewModel.setLanguage(language: language)
                        if !viewModel.language.isAvailable {
                            viewModel.setShowDownloadPrompt(prompt: true)
                        }
                        viewModel.stopAudioEngine()
                    }) {
                        Text(language.localizedName)
                    }
                }
            }
        } label: {
            let currentLanguage = viewModel.language.localizedName
            Image(systemName: "globe")
                .resizable()
                .frame(width: 50, height: 50)
            
            Text("Select language (currently \(currentLanguage))", comment: "Label of the language picker")
        }
    }
}

