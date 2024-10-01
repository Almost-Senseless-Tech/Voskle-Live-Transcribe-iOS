//
//  SettingsView.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 27.06.24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: VLTViewModel
    
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $viewModel.themeSetting) {
                    Text(ThemeSetting.auto.localizedName).tag(ThemeSetting.auto)
                    Text(ThemeSetting.light.localizedName).tag(ThemeSetting.light)
                    Text(ThemeSetting.dark.localizedName).tag(ThemeSetting.dark)
                }
                
                Toggle(isOn: $viewModel.highContrast) {
                    Text("High contrast")
                }
                
                Picker("Transcript font size", selection: $viewModel.transcriptFontSize) {
                    ForEach(FontSize.allCases.sorted()) { fontSize in
                        Text(fontSize.localizedName).tag(fontSize)
                            .font(Font.system(size: fontSize.size, weight: .regular, design: .default))
                            .lineSpacing(fontSize.lineSpacing)
                    }
                }
            }
            Section("Behavior") {
                Toggle(isOn: $viewModel.autoscroll) {
                    Text("Visual autoscroll")
                }
                
                Toggle(isOn: $viewModel.accessibilityAutoscroll) {
                    Text("Autoscroll on braille displays")
                }
                
                Toggle(isOn: $viewModel.keepTranscribingInBackground) {
                    Text("Keep transcribing while the app isn't focused")
                }
            }
            Section("About the app") {
                Button(action: {
                    viewModel.contactUs()
                }) {
                    Text("Contact us")
                }
                
                Text("Copyright © 2024 Tim Böttcher")
                Text("Licensed under the Apache license, version 2.0.")
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if viewModel.keyboardInput {
                viewModel.setKeyboardInput(on: false)
            }
            if viewModel.recording {
                viewModel.toggleRecording()
            }
        }
    }
}
