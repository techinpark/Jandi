//
//  Localized.swift
//  jandi
//
//  Created by Fernando on 2021/01/30.
//

import Foundation

enum Localized {
    static let placeholder = ""
    static let hello = NSLocalizedString("wellcome_user_message", comment: "👋 Hi,  @${username}")
    static let refresh = NSLocalizedString("refresh", comment: "refresh")
    static let changeUsername = NSLocalizedString("change_username", comment: "Change username")
    static let textFieldPlaceholder = NSLocalizedString("textfield_placeholder", comment: "Github username")
    static let setUsernameDescription = NSLocalizedString("username_description", comment: "Set username")
    static let changeUsernameDescription = NSLocalizedString("change_username_description", comment: "Change username")
    static let information = NSLocalizedString("information", comment: "Enter your GitHub username. We’ll fetch the number of contributions.")

    static let ok = NSLocalizedString("ok", comment: "Okay")
    static let cancel = NSLocalizedString("cancel", comment: "cancel")
    static let error = NSLocalizedString("error", comment: "error")
    static let quit = NSLocalizedString("quit", comment: "quit")
}
