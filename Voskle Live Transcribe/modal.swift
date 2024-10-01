//
//  modal.swift
//  Voskle Live Transcribe
//
//  Created by Tim Böttcher on 14.06.24.
//

import SwiftUI

struct ModalDialog<Content: View>: View {
    let title: String
    let content: Content
    let onDismiss: (() -> Void)?
    
    init(title: String, onDismiss: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack {
                Text(title)
                    .font(.headline)
                        .padding()
                    .accessibilityAddTraits(.isHeader)
                Divider()
                    .accessibilityHidden(true)
                content
                    .accessibilityElement(children: .contain)
                Divider()
                    .accessibilityHidden(true)
                Button(action: {
                    onDismiss?()
                }) {
                    Text("Close", comment: "Close a modal dialog")
                        .font(.body)
                        .padding()
                        .cornerRadius(8)
                }
                .accessibilityHint(NSLocalizedString("Closes this modal dialog", comment: "Accessibility hint for the close button of a modal dialog"))
            }
            .cornerRadius(12)
            .shadow(radius: 20)
            .padding()
            .accessibilityElement(children: .contain)
            .accessibilityHint(NSLocalizedString("Swipe down with three fingers to close this modal dialog.", comment: "Accessibility hint for the modal dialog container"))
            .accessibilityAddTraits(.isModal)
        }
    }
}

struct ErrorModal<Content: View>: View {
    let title: String
    let content: Content
    let viewModel: VLTViewModel
    let onDismiss: (() -> Void)?
    
    init(title: String, viewModel: VLTViewModel, onDismiss: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ModalDialog(title: title, onDismiss: {
            viewModel.resetError()
            onDismiss?()
        }) {
            content
                .accessibilityElement(children: .contain)
            Divider()
                .accessibilityHidden(true)
            Button(action: {
                viewModel.contactUs()
            }) {
                Text("Contact us", comment: "Text for the contact buttons in error modals and the settings")
                    .font(.body)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .accessibilityHint(NSLocalizedString("Drafts a feedback email", comment: "Accessibility hint for the contact us button"))
            }
        }
    }
}

