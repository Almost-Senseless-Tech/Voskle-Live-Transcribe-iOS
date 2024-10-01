//
//  VoskleLiveTranscribeApp.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 13.04.24.
//

import SwiftUI

@main
struct VoskleLiveTranscribeApp: App {
    @StateObject private var viewmodel = VLTViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewmodel)
                .voskleLiveTranscribeTheme(themeSetting: viewmodel.themeSetting, highContrast: viewmodel.highContrast)
                .onChange(of: scenePhase) { _, phase in
                    if !viewmodel.keepTranscribingInBackground && phase == .inactive {
                        if viewmodel.recording {
                            viewmodel.toggleRecording()
                        }
                    }
                }
        }
    }
}
