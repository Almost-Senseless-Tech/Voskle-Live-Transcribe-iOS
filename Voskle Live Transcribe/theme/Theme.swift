//
//  Theme.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on i01.07.24.
//

import SwiftUI

/*
 A whole lot of the theme colors remain unused, so the styles
 are far from identical. But the basics are already in place and
 can added in at suitable times.
 */
struct VoskleLiveTranscribeTheme: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var themeSetting: ThemeSetting
    var highContrast: Bool

    func body(content: Content) -> some View {
        let darkTheme = (themeSetting == .auto && colorScheme == .dark) || themeSetting == .dark
        
        content
            .environment(\.font, Typography.bodyLarge)
            .accentColor(darkTheme ? (highContrast ? Color.mdThemeHcPrimary : Color.mdThemeDarkPrimary) : Color.mdThemeLightPrimary)
            .background(darkTheme ? (highContrast ? Color.mdThemeHcBackground : Color.mdThemeDarkBackground) : Color.mdThemeLightBackground)
    }
}

extension View {
    func voskleLiveTranscribeTheme(themeSetting: ThemeSetting, highContrast: Bool) -> some View {
        self.modifier(VoskleLiveTranscribeTheme(themeSetting: themeSetting, highContrast: highContrast))
    }
}
