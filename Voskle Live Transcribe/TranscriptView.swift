//
//  TranscriptView.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 23.06.24.
//

import Foundation
import SwiftUI

struct TranscriptView: View {
    @EnvironmentObject var viewModel: VLTViewModel
    @FocusState private var transcriptFocused: Bool
    @State private var text = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            let transcriptLabelText = NSLocalizedString("Transcript:", comment: "Label of the transcript text view")
            Text(transcriptLabelText)
                .accessibilityHidden(true)
                .font(.headline)
                .padding(.bottom, 5)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        TextEditor(text: $text)
                            .padding()
                            .cornerRadius(8)
                            .font(Font.system(
                                size: viewModel.transcriptFontSize.size,
                                weight: .regular,
                                design: .default
                            ))
                            .lineSpacing(viewModel.transcriptFontSize.lineSpacing)
                            .focused($transcriptFocused)
                            .disabled(!viewModel.accessibilityAutoscroll)
                            .frame(minHeight: 200)
                            .onChange(of: viewModel.recording) { _, recording in
                                if !recording && viewModel.keyboardInput {
                                    transcriptFocused = true
                                }
                                
                                if !viewModel.keyboardInput && viewModel.accessibilityAutoscroll {
                                    transcriptFocused = recording
                                }
                            }
                            .onChange(of: viewModel.transcript) { _, transcript in
                                if !viewModel.keyboardInput {
                                    text = transcript
                                }
                            }
                            .onChange(of: text) { _, newText in
                                if viewModel.keyboardInput {
                                    viewModel.transcript = newText
                                }
                            }
                            .onChange(of: viewModel.accessibilityAutoscroll) { _, autoscroll in
                                if viewModel.recording {
                                    transcriptFocused = autoscroll
                                }
                            }
                            .accessibilityLabel(transcriptLabelText)
                            .accessibilityAddTraits(.updatesFrequently)
                        
                        Text("")
                            .id("bottom")
                            .accessibilityHidden(true)
                    }
                    .onChange(of: viewModel.transcript) { _, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if viewModel.autoscroll {
                                withAnimation {
                                    proxy.scrollTo("bottom", anchor: .bottom)
                                }
                            }
                            UIAccessibility.post(notification: .layoutChanged, argument: nil)
                        }
                    }
                    .onChange(of: viewModel.autoscroll) { _, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if viewModel.autoscroll {
                                withAnimation {
                                    proxy.scrollTo("bottom", anchor: .bottom)
                                    UIAccessibility.post(notification: .layoutChanged, argument: nil)
                                }
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                            UIAccessibility.post(notification: .layoutChanged, argument: nil)
                        }
                    }
                }
            }
        }
    }
}
