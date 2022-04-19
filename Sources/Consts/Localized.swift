//
//  Localized.swift
//  jandi
//
//  Created by Fernando on 2021/01/30.
//

import Foundation

enum Localized {
    static let placeholder = ""
    static let hello = NSLocalizedString("wellcome_user_message", comment: "👋 Hi,  @${username} ${withFriend}")
    static let withFriend = NSLocalizedString("with_friend", comment: "\nwith @${username}")
    static let refresh = NSLocalizedString("refresh", comment: "refresh")
    static let changeUsername = NSLocalizedString("change_username", comment: "Change username")
    static let changeFriendUsername = NSLocalizedString("change_friend_username", comment: "Change friend username")
    static let setFriendUsername = NSLocalizedString("set_friend_username", comment: "Set friend username")
    static let removeFriendUsername = NSLocalizedString("remove_friend_username", comment: "Remove friend username")
    static let setGoal = NSLocalizedString("set_goal", comment: "Set goal")
    static let help = NSLocalizedString("help", comment: "help")
    static let textFieldPlaceholder = NSLocalizedString("textfield_placeholder", comment: "Github username")
    static let setUsernameDescription = NSLocalizedString("username_description", comment: "Set username")
    static let changeUsernameDescription = NSLocalizedString("change_username_description", comment: "Change username")
    static let autoLaunch = NSLocalizedString("auto_launch", comment: "Automatically start Jandi at login")
    static let information = NSLocalizedString("information", comment: "Enter your GitHub username. We’ll fetch the number of contributions.")
    static let friend_information = NSLocalizedString("friend_information", comment: "Enter your friend GitHub username. We'll fetch the number of contributions.")
    static let goal =  NSLocalizedString("goal", comment: "Enter your GitHub username. We’ll fetch the number of contributions.")
    static let goalInformation =  NSLocalizedString("goal_information", comment: "Enter your GitHub username. We’ll fetch the number of contributions.")
    static let setting = NSLocalizedString("setting", comment: "Preferences")
    static let settingTitle = NSLocalizedString("setting_title", comment: "Preferences Title")
    static let viewMyProfile = NSLocalizedString("view_my_profile", comment: "View my profile")
    
    static let streakFristStage = NSLocalizedString("streak_first_stage", comment: "streak stage 1")
    static let streakSecondStage = NSLocalizedString("streak_second_stage", comment: "streak stage 2")
    static let streakThirdStage = NSLocalizedString("streak_third_stage", comment: "streak stage 3")
    static let streakForthStage = NSLocalizedString("streak_fourth_stage", comment: "streak stage 4")
    static let streakFifthStage = NSLocalizedString("streak_fifth_stage", comment: "streak stage 5")
    static let goalToGo = NSLocalizedString("goal_to_go", comment: "commits to go")
    static let goalAccomplished = NSLocalizedString("goal_accomplished", comment: "Goal accomplished")
    
    static let ok = NSLocalizedString("ok", comment: "Okay")
    static let cancel = NSLocalizedString("cancel", comment: "cancel")
    static let error = NSLocalizedString("error", comment: "error")
    static let quit = NSLocalizedString("quit", comment: "quit")
}
