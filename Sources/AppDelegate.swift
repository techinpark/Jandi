//
//  AppDelegate.swift
//  jandi
//
//  Created by Fernando on 2021/01/29.
//

import Cocoa
import Then
import SwiftUI
import SwiftSoup

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    var statusItem: NSStatusItem?
    var refreshTimer: Timer?
    var username = UserDefaults.standard.string(forKey: "username") ?? ""
    
    let attributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.green
    ]
    
    let redAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: Colors.red
    ]
    
    private struct ParseKeys {
        static let date = "data-date"
        static let contributionCount = "data-count"
        static let rect = "rect"
    }
    
    private struct Consts {
        static let fetchCount = 10
        static let refreshInterval = 10
        static let contributionTag = 1
    }
    
    private struct Localized {
        static let placeholder = ""
        static let hello = NSLocalizedString("wellcome_user_message", comment: "👋 안녕,  @${username}")
        static let refresh = NSLocalizedString("refresh", comment: "refresh")
        static let changeUsername = NSLocalizedString("change_username", comment: "Change username")
        static let textFieldPlaceholder = NSLocalizedString("textfield_placeholder", comment: "Github username")
        static let setUsernameDescription = NSLocalizedString("username_description", comment: "Set username")
        static let changeUsernameDescription = NSLocalizedString("change_username_description", comment: "Change username")
        static let information = NSLocalizedString("information", comment: "Enter your GitHub username. We’ll fetch the number of contributions.")
        
        static let ok = NSLocalizedString("ok", comment: "Okay")
        static let cancel = NSLocalizedString("cancel", comment: "cancel")
        static let error =  NSLocalizedString("error", comment: "error")
        static let quit = NSLocalizedString("quit", comment: "quit")
    }
    
    private struct Colors {
        static let green = NSColor(calibratedRed: 0.0/255.0, green: 142.0/255.0, blue: 2.0/255.0, alpha: 1.0)
        static let red = NSColor(calibratedRed: 142.0/255.0, green: 0.0/255.0, blue: 2.0/255.0, alpha: 1.0)
    }
  
    private let menu = NSMenu().then {
        $0.title = ""
    }
    
    private let userMenuItem = NSMenuItem().then {
        $0.title = Localized.hello
        $0.tag = 0
    }
    
    private let refreshMenuItem = NSMenuItem().then {
        $0.title = Localized.refresh
        $0.action = #selector(onRefreshClick)
        $0.tag = 2
    }
    
    private let changeUserMenuItem = NSMenuItem().then {
        $0.title = Localized.changeUsername
        $0.action = #selector(onChangeUsernameClick)
        $0.tag = 3
    }
    
    private let quitMenuItem = NSMenuItem().then {
        $0.title = Localized.quit
        $0.action = #selector(onQuitClick)
        $0.tag = 4
        $0.keyEquivalent = "q"
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if username.isEmpty {
            showChangeUsernameAlert()
            return
        }
        
        setupUI()
        fetchContributions(username: username)
        setupRefreshTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        invalidateRefreshTimer()
        destroyStatusItem()
    }
    
    private func setupUI() {

        menu.addItem(.separator())
        menu.addItem(userMenuItem)
        menu.addItem(.separator())
        menu.addItem(refreshMenuItem)
        menu.addItem(changeUserMenuItem)
        menu.addItem(quitMenuItem)
        
        statusItem?.menu = menu
        userMenuItem.title = Localized.hello.replacingOccurrences(of: "${username}", with: username)
    }
    
    //MARK: Private functions
    
    private func updateUI() {
        userMenuItem.title = Localized.hello.replacingOccurrences(of: "${username}", with: username)
    }

    private func destroyStatusItem() {
        statusItem = nil
    }

    @objc func onRefreshClick() {
        refresh()
    }
    
    @objc func onQuitClick() {
        NSApplication.shared.terminate(self)
    }

    @objc func onChangeUsernameClick() {
        showChangeUsernameAlert()
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
            let username = usernameTextField.stringValue

            if username.isEmpty {
                if self.username.isEmpty {
                    NSApplication.shared.terminate(self)
                }

                return
            }

            changeUsername(withUsername: username)
        }
    }

    private func changeUsername(withUsername username: String) {
        UserDefaults.standard.setValue(username, forKey: "username")
        self.username = UserDefaults.standard.string(forKey: "username")!

        refresh()
    }

    private func refresh() {
        
        let _ = self.menu.items.map {
            if $0.tag == Consts.contributionTag {
                print("delete")
                self.menu.removeItem($0)
            }
        }
        
        invalidateRefreshTimer()
        updateUI()
        fetchContributions(username: username)
        setupRefreshTimer()
    }

    private func fetchContributions(username: String) {
        let targetURL = URL(string: "https://github.com/users/\(username)/contributions")!
        URLSession.shared.dataTask(with: targetURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if error != nil {
                self.showError()
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.showError()
                return
            }

            guard let mimeType = httpResponse.mimeType,
                  mimeType == "text/html",
                  let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                self.showError()
                return
            }

            self.parseHTML(html: html)
        }
        .resume()
    }

    private func setupRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Consts.refreshInterval * 60),
                                            repeats: true,
                                            block: { [weak self] timer in
                                                guard let self = self else { return }
                                                self.fetchContributions(username: self.username)
        })
    }

    private func invalidateRefreshTimer() {
        refreshTimer?.invalidate()
    }

    private func currentDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }

    private func showError() {
        DispatchQueue.main.async {
            self.statusItem?.button?.title = Localized.error
        }
    }
    
    private func parseHTML(html: String) {
        
        do {
            
            let doc = try SwiftSoup.parse(html)
            let days = try doc.getElementsByTag(ParseKeys.rect)
            let today = days.last()!
            
            let weekend = days.suffix(Consts.fetchCount)
            
            _ = weekend.map {
                let attr = $0.getAttributes()!
                let date: String = attr.get(key: ParseKeys.date)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let dateForWeekend = dateFormatter.date(from: date)
                guard let weekend = dateForWeekend?.dayOfWeek() else { return }
                
                guard let count = Int(attr.get(key: ParseKeys.contributionCount))  else { return }
                let emoji = count.getEmoji()
                let dummyText = "\(emoji) \(date) (\(weekend)) - \(count)"
                let menuItem = NSMenuItem(title: dummyText, action: nil, keyEquivalent: "")
                
                if date != today.getAttributes()?.get(key: ParseKeys.date) {
                    let attributes = (.zero == count) ? self.redAttributes : self.attributes
                    menuItem.attributedTitle = NSAttributedString(string: dummyText,
                                                                  attributes: attributes)
                    menuItem.isEnabled = true
                    menuItem.tag = Consts.contributionTag
                    
                    self.menu.insertItem(menuItem, at: .zero)
                }
            }
         
            guard let attrs = today.getAttributes() else {
                self.showError()
                return
            }
            
            let count = attrs.get(key: ParseKeys.contributionCount)
            self.showContributions(count: count)
            
        } catch {
            self.showError()
        }
    }

    private func showContributions(count: String) {
        DispatchQueue.main.async {
            guard let count = Int(count)  else { return }
            let emoji = count.getEmoji()
            let textString = "\(emoji) \(count)"
            let attributes = (.zero == count) ? self.redAttributes : self.attributes
            self.statusItem?.button?.attributedTitle = NSAttributedString(string: textString, attributes: attributes)
        }
    }
}


