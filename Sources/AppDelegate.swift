//
//  AppDelegate.swift
//  jandi
//
//  Created by Fernando on 2021/01/29.
//

import Cocoa
import SwiftSoup
import Then
import LaunchAtLogin

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem?
    private var refreshTimer: Timer?
    private var username = UserDefaults.standard.string(forKey: Consts.usernameDefaultKey) ?? ""
    private var friendUsername = UserDefaults.standard.string(forKey: Consts.friendUsernameDefaultKey) ?? ""
    private let menu = NSMenu().then {
        $0.title = ""
    }
    
    
    private var myContributes: [ContributeData] = []
    private var friendContributes: [ContributeData] = []
    private var mystreaks: ContributeData = ContributeData(count: 0, weekend: "", date: "")

    private let userMenuItem = NSMenuItem().then {
        $0.title = Localized.hello
        $0.tag = 0
    }

    private let refreshMenuItem = NSMenuItem().then {
        $0.title = Localized.refresh
        $0.action = #selector(onRefreshClick)
        $0.keyEquivalent = "r"
        $0.tag = 2
    }

    private let changeUserMenuItem = NSMenuItem().then {
        $0.title = Localized.changeUsername
        $0.action = #selector(onChangeUsernameClick)
        $0.keyEquivalent = "u"
        $0.tag = 3
    }
    
    private let helpMenuItem = NSMenuItem().then {
        $0.title = Localized.help
        $0.action = #selector(onHelpClick)
        $0.keyEquivalent = ""
        $0.tag = 4
    }
    
    private let quitMenuItem = NSMenuItem().then {
        $0.title = Localized.quit
        $0.action = #selector(onQuitClick)
        $0.tag = 5
        $0.keyEquivalent = "q"
    }
    
    private let friendMenuItem = NSMenuItem().then {
        $0.title = Localized.changeFriendUsername
        $0.action = #selector(onChangeFriendUsernameClick)
        $0.tag = 6
        $0.keyEquivalent = "f"
    }
    
    private let RemoveFriendMenuItem = NSMenuItem().then {
        $0.title = Localized.removeFriendUsername
        $0.action = #selector(onRemoveFriendUsernameClick)
        $0.tag = 6
        $0.keyEquivalent = "d"
    }
    
    private let settingMenuItem = NSMenuItem().then {
        $0.title = Localized.setting
        $0.action = #selector(onSettingClick)
        $0.keyEquivalent = "s"
        $0.tag = 7
    }

    func applicationDidFinishLaunching(_: Notification) {
        
        setupUI()
        
        if username.isEmpty {
            showChangeUsernameAlert()
            return
        }
        
        fetchContributions()
        setupRefreshTimer()
    }

    func applicationWillTerminate(_: Notification) {
        invalidateRefreshTimer()
        destroyStatusItem()
    }

    // MARK: Setup UI

    private func setupUI() {
        
        menu.addItem(.separator())
        menu.addItem(userMenuItem)
        menu.addItem(.separator())
        menu.addItem(helpMenuItem)
        menu.addItem(.separator())
        menu.addItem(friendMenuItem)
        menu.addItem(RemoveFriendMenuItem)
        menu.addItem(.separator())
        menu.addItem(refreshMenuItem)
        menu.addItem(changeUserMenuItem)
        menu.addItem(settingMenuItem)
        menu.addItem(quitMenuItem)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.menu = menu
        
        updateUI()
    }

    private func updateUI() {
        
        var withFriend = ""
        if !friendUsername.isEmpty {
            withFriend = Localized.withFriend.replacingOccurrences(of: "${username}", with: friendUsername)
        }
        
        let userMenuItemTitle = Localized.hello.replacingOccurrences(of: "${username}", with: username).replacingOccurrences(of: "${withFriend}", with: withFriend)
        userMenuItem.attributedTitle = NSAttributedString(string: userMenuItemTitle)
        
        let friendMenuItemTitle = self.friendUsername.isEmpty ? Localized.setFriendUsername : Localized.changeFriendUsername
        friendMenuItem.title = friendMenuItemTitle
        
        RemoveFriendMenuItem.isHidden = self.friendUsername.isEmpty
    }
    
    private func showSettingAlert() {
        let alert = NSAlert()
        
        alert.messageText = Localized.settingTitle
        let button = NSButton(checkboxWithTitle: Localized.autoLaunch, target: nil, action: #selector(setupLauchToggle))
        button.state = LaunchAtLogin.isEnabled ? .on : .off
        alert.accessoryView = button
        
        if alert.runModal() == .alertFirstButtonReturn {
            return
        }
    }

    private func showChangeUsernameAlert() {
        let alert = NSAlert()
        let usernameTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 20))

        usernameTextField.placeholderString = username.isEmpty ? Localized.textFieldPlaceholder : username

        alert.messageText = username.isEmpty ? Localized.setUsernameDescription : Localized.changeUsernameDescription
        alert.informativeText = Localized.information
        alert.alertStyle = .informational
        alert.accessoryView = usernameTextField
        alert.addButton(withTitle: Localized.ok)

        if !username.isEmpty {
            alert.addButton(withTitle: Localized.cancel)
        }

        alert.window.initialFirstResponder = alert.accessoryView

        if alert.runModal() == .alertFirstButtonReturn {
            let username = usernameTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)

            if username.isEmpty {
                if self.username.isEmpty {
                    NSApplication.shared.terminate(self)
                }
                return
            }
            changeUsername(withUsername: username)
        }
    }
    
    private func showChangeFriendUsernameAlert() {
        let alert = NSAlert()
        let friendUsernameTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 20))

        friendUsernameTextField.placeholderString = friendUsername.isEmpty ? Localized.textFieldPlaceholder : friendUsername

        alert.messageText = friendUsername.isEmpty ? Localized.setUsernameDescription : Localized.changeUsernameDescription
        alert.informativeText = Localized.friend_information
        alert.alertStyle = .informational
        alert.accessoryView = friendUsernameTextField
        alert.addButton(withTitle: Localized.ok)
        alert.addButton(withTitle: Localized.cancel)
        alert.window.initialFirstResponder = alert.accessoryView

        if alert.runModal() == .alertFirstButtonReturn {
            let friendUsername = friendUsernameTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if friendUsername.isEmpty {
                removeFriendinfo()
            }
            else {
                changeFriendUsername(withUsername: friendUsername)
            }
        }
    }

    private func showError() {
        DispatchQueue.main.async {
            self.statusItem?.button?.title = Localized.error
        }
    }

    private func destroyStatusItem() {
        statusItem = nil
    }

    // MARK: Actions

    @objc func onRefreshClick() {
        refresh()
    }

    @objc func onQuitClick() {
        NSApplication.shared.terminate(self)
    }

    @objc func onChangeUsernameClick() {
        showChangeUsernameAlert()
    }
    
    @objc func onChangeFriendUsernameClick(){
        showChangeFriendUsernameAlert()
    }
    
    @objc func onRemoveFriendUsernameClick(){
        removeFriendinfo()
    }
    
    @objc func onHelpClick() {
        let url = URL(string: "https://github.com/techinpark/Jandi")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func onSettingClick() {
        showSettingAlert()
    }
    
    @objc func setupLauchToggle() {
        LaunchAtLogin.isEnabled.toggle()
    }


    private func changeUsername(withUsername username: String) {
        UserDefaults.standard.setValue(username, forKey: Consts.usernameDefaultKey)
        self.username = UserDefaults.standard.string(forKey: Consts.usernameDefaultKey)!

        refresh()
    }
    
    private func changeFriendUsername(withUsername username: String) {
        UserDefaults.standard.setValue(username, forKey: Consts.friendUsernameDefaultKey)
        self.friendUsername = UserDefaults.standard.string(forKey: Consts.friendUsernameDefaultKey)!
        
        refresh()
    }
    
    private func removeFriendinfo(){
        UserDefaults.standard.setValue("", forKey: Consts.friendUsernameDefaultKey)
        self.friendUsername = ""
        self.friendContributes = []
        
        refresh()
    }
    
    
    private func refresh() {
        removeAllItems()
        invalidateRefreshTimer()
        updateUI()
        fetchContributions()
        setupRefreshTimer()
    }

    private func setupRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Consts.refreshInterval * 60),
                                            repeats: true,
                                            block: { [weak self] _ in
                                                guard let self = self else { return }
                                                self.removeAllItems()
                                                self.fetchContributions()
                                            })
    }

    private func invalidateRefreshTimer() {
        refreshTimer?.invalidate()
    }

    private func removeAllItems() {
        _ = menu.items.map {
            if $0.tag == Consts.contributionTag {
                self.menu.removeItem($0)
            }
        }
    }

    // MARK: Contribution functions

    private func updateContributions(){
        if self.myContributes.count == self.friendContributes.count {
            let contributes = zip(self.myContributes, self.friendContributes)
            for (myContribute, friendContribute) in contributes{
                myContribute.merge(contributeData: friendContribute)
                
                let menuItem = NSMenuItem().then {
                    $0.isEnabled = true
                    $0.tag = Consts.contributionTag
                    $0.attributedTitle = myContribute.getStatusDetailAttributedString()
                }

                self.menu.insertItem(menuItem, at: .zero)
            }
            
            guard let myLastContribute = self.myContributes.last else { return }
            guard let friendLastContribute = self.friendContributes.last else { return }
            myLastContribute.merge(contributeData: friendLastContribute)
            DispatchQueue.main.async {
                self.statusItem?.button?.attributedTitle = myLastContribute.getStatusBarAttributedString()
            }
            
        } else {
            for myContribute in self.myContributes {
                
                let menuItem = NSMenuItem().then {
                    $0.isEnabled = true
                    $0.tag = Consts.contributionTag
                    $0.attributedTitle = myContribute.getStatusDetailAttributedString()
                }

                self.menu.insertItem(menuItem, at: .zero)
            }
            
            guard let lastContribute = self.myContributes.last else { return }
            DispatchQueue.main.async {
                self.statusItem?.button?.attributedTitle = lastContribute.getStatusBarAttributedString()
            }
        }
    }
    
    private func fetchContributions() {
        let group = DispatchGroup()
        group.enter()
        fetchContributionsByUserame(username: self.username, group: group)
        
        if !self.friendUsername.isEmpty {
            group.enter()
            fetchContributionsByUserame(username: self.friendUsername, isFriend: true, group: group)
        }
        group.notify(queue: .main){
            self.updateContributions()
            self.fetchStreaks(self.mystreaks)
        }
        
    }
    
    private func fetchStreaks(_ date: ContributeData) {
        let menuItem = NSMenuItem().then {
            $0.isEnabled = true
            $0.tag = Consts.contributionTag
            $0.attributedTitle = date.getStreaks()
        }

        self.menu.insertItem(.separator(), at: .zero)
        self.menu.insertItem(menuItem, at: .zero)
    }
    
    private func fetchContributionsByUserame(username: String, isFriend: Bool = false, group: DispatchGroup? = nil ) {
        guard let targetURL = URL(string: "https://github.com/users/\(username)/contributions") else { return }
        URLSession.shared.dataTask(with: targetURL) { [weak self] data, response, error in
            guard let self = self else { return }

            if error != nil {
                self.showError()
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                self.showError()
                return
            }

            guard let mimeType = httpResponse.mimeType,
                  mimeType == "text/html",
                  let data = data,
                  let html = String(data: data, encoding: .utf8)
            else {
                self.showError()
                return
            }

            
            let contributeDataList = self.parseHtmltoData(html: html)
            if isFriend {
                self.friendContributes = contributeDataList
            } else{
                self.myContributes = contributeDataList
                self.mystreaks = self.parseHtmltoDataForCount(html: html)
            }
            
            if group != nil {
                group?.leave()
            }
            
        }
        .resume()
    }
    
    
    private func mapFunction(ele : Element) -> ContributeData {
        guard let attr = ele.getAttributes() else { return ContributeData(count: 0, weekend: "", date: "") }
        let date: String = attr.get(key: ParseKeys.date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current

        let dateForWeekend = dateFormatter.date(from: date)
        guard let weekend = dateForWeekend?.dayOfWeek() else { return ContributeData(count: 0, weekend: "", date: "")}
        guard let count = Int(attr.get(key: ParseKeys.contributionCount)) else { return ContributeData(count: 0, weekend: "", date: "")}
        
        return ContributeData(count: count, weekend: weekend, date: date)
    }
    
    private func parseHtmltoData(html: String) -> [ContributeData] {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let rects: Elements = try doc.getElementsByTag(ParseKeys.rect)
            let days: [Element] = rects.array().filter { $0.hasAttr(ParseKeys.date) }
            let weekend = days.suffix(Consts.fetchCount)
            let contributeDataList = weekend.map(mapFunction)
            return contributeDataList
            
        } catch {
            return []
        }
    }
    
    
    private func parseHtmltoDataForCount(html: String) -> ContributeData {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let rects: Elements = try doc.getElementsByTag(ParseKeys.rect)
            let days: [Element] = rects.array().filter { $0.hasAttr(ParseKeys.date) }
            let count = days.suffix(Consts.fetchStreak)
            var contributeLastDate = count.map(mapFunction)
            contributeLastDate.sort{ $0.date > $1.date }
            for date in contributeLastDate {
                if date.count == .zero {
                    return date
                }
            }
            
            return ContributeData(count: 0, weekend: "", date: "")
        } catch {
            return ContributeData(count: 0, weekend: "", date: "")
        }
    }

}
