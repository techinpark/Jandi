//
//  AppDelegate.swift
//  jandi
//
//  Created by Fernando on 2021/01/29.
//

import Cocoa
import SwiftSoup
import Then

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem?
    private var refreshTimer: Timer?
    private var username = UserDefaults.standard.string(forKey: "username") ?? ""

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
        $0.keyEquivalent = "r"
        $0.tag = 2
    }

    private let changeUserMenuItem = NSMenuItem().then {
        $0.title = Localized.changeUsername
        $0.action = #selector(onChangeUsernameClick)
        $0.keyEquivalent = "u"
        $0.tag = 3
    }

    private let quitMenuItem = NSMenuItem().then {
        $0.title = Localized.quit
        $0.action = #selector(onQuitClick)
        $0.tag = 4
        $0.keyEquivalent = "q"
    }

    func applicationDidFinishLaunching(_: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if username.isEmpty {
            showChangeUsernameAlert()
            return
        }

        setupUI()
        fetchContributions(username: username)
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
        menu.addItem(refreshMenuItem)
        menu.addItem(changeUserMenuItem)
        menu.addItem(quitMenuItem)

        statusItem?.menu = menu
        userMenuItem.title = Localized.hello.replacingOccurrences(of: "${username}", with: username)
    }

    private func updateUI() {
        userMenuItem.title = Localized.hello.replacingOccurrences(of: "${username}", with: username)
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

    private func changeUsername(withUsername username: String) {
        UserDefaults.standard.setValue(username, forKey: "username")
        self.username = UserDefaults.standard.string(forKey: "username")!

        refresh()
    }

    private func refresh() {
        removeAllItems()
        invalidateRefreshTimer()
        updateUI()
        fetchContributions(username: username)
        setupRefreshTimer()
    }

    private func setupRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Consts.refreshInterval * 60),
                                            repeats: true,
                                            block: { [weak self] _ in
                                                guard let self = self else { return }
                                                self.removeAllItems()
                                                self.fetchContributions(username: self.username)
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

    private func showContributions(count: String) {
        DispatchQueue.main.async {
            guard let count = Int(count) else { return }
            let emoji = count.getEmoji()
            let textString = "\(emoji) \(count)"
            let attributes = (count == .zero) ? Attributes.red : Attributes.green
            self.statusItem?.button?.attributedTitle = NSAttributedString(string: textString, attributes: attributes)
        }
    }

    private func fetchContributions(username: String) {
        let targetURL = URL(string: "https://github.com/users/\(username)/contributions")!
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

            self.parseHTML(html: html)
        }
        .resume()
    }

    private func parseHTML(html: String) {
        do {
            let doc = try SwiftSoup.parse(html)
            let days = try doc.getElementsByTag(ParseKeys.rect)
            let weekend = days.suffix(Consts.fetchCount)
            guard let today = days.last() else { return }

            _ = weekend.map {
                guard let attr = $0.getAttributes() else { return }
                let date: String = attr.get(key: ParseKeys.date)

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                let dateForWeekend = dateFormatter.date(from: date)
                guard let weekend = dateForWeekend?.dayOfWeek() else { return }
                guard let count = Int(attr.get(key: ParseKeys.contributionCount)) else { return }

                let emoji = count.getEmoji()
                let statusText = "\(emoji) \(date) (\(weekend)) - \(count)"
                let menuItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")

                if date != today.getAttributes()?.get(key: ParseKeys.date) {
                    let attributes = (count == .zero) ? Attributes.red : Attributes.green
                    menuItem.attributedTitle = NSAttributedString(string: statusText,
                                                                  attributes: attributes)
                    menuItem.isEnabled = true
                    menuItem.tag = Consts.contributionTag

                    self.menu.insertItem(menuItem, at: .zero)
                }
            }

            guard let attrs = today.getAttributes() else {
                showError()
                return
            }

            let count = attrs.get(key: ParseKeys.contributionCount)
            showContributions(count: count)

        } catch {
            showError()
        }
    }
}
