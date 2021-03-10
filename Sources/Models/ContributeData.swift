//
//  ContributeData.swift
//  jandi
//
//  Created by daehyun han on 2021/02/22.
//

import Foundation

class ContributeData {
    let count : Int
    let weekend : String
    let date : String
    private var friendContributeData : ContributeData?
    
    init(count: Int, weekend: String, date: String) {
            self.count   = count
            self.weekend = weekend
            self.date  = date
        }
    
    private func getAttributes() -> [NSAttributedString.Key : Any] {
        return (count == .zero) ? Attributes.red : Attributes.green
    }

    private func getGoalAttributes(_ goal: Int) -> [NSAttributedString.Key : Any] {
        return (count >= goal) ? Attributes.green : Attributes.red
    }

    private func getGoalCountString(_ goal: Int) -> String {
        return String(goal - count)
    }
    
    public func merge(contributeData: ContributeData) {
        self.friendContributeData = contributeData
    }
    
    public func getStatusDetailString() -> String {
        let emoji = count.getEmoji()
        var textString = "\(date) (\(weekend)) - \(emoji) \(count)"
        
        if self.friendContributeData != nil {
            guard let friendContributeData = self.friendContributeData else {return textString}
            textString += " vs \(friendContributeData.count) \(friendContributeData.count.getEmoji())"
        }
        return textString
    }
    
    
    public func getStatusBarString() -> String {
        let emoji = count.getEmoji()
        var textString = "\(emoji) \(count)"
        
        if self.friendContributeData != nil {
            guard let friendContributeData = self.friendContributeData else { return textString }
            textString += " vs \(friendContributeData.count) \(friendContributeData.count.getEmoji())"
        }
        return textString
    }
    
    public func getStreaks() -> NSAttributedString {
        let statusDetailAttributedString = NSMutableAttributedString()
        guard let day = Int(date.getDateFormat().timeAgoSince()) else { return statusDetailAttributedString }
        var attribute = Attributes.red
        var textString = day.getStreaks()
        if day > 0 {
            attribute = Attributes.green
        }
        if count == 1000 {
            textString = Localized.streakFifthStage
        }
        
        let attributedString = NSAttributedString(string: textString, attributes: attribute)
        statusDetailAttributedString.append(attributedString)
        return statusDetailAttributedString
    }
    
    public func getStatusDetailAttributedString() -> NSAttributedString {
        let statusDetailAttributedString = NSMutableAttributedString()
        let emoji = count.getEmoji()
        let textString = "\(date) (\(weekend)) - \(emoji) \(count)"
        
        let attributedString = NSAttributedString(string: textString, attributes: getAttributes())
        statusDetailAttributedString.append(attributedString)
        
        if self.friendContributeData != nil {
            guard let friendContributeData = self.friendContributeData else {return statusDetailAttributedString}
            
            statusDetailAttributedString.append(NSAttributedString(string: " vs ", attributes: Attributes.black))
            
            let AddedTextString = "\(friendContributeData.count) \(friendContributeData.count.getEmoji())"
            let addedAttributedString = NSAttributedString(string: AddedTextString, attributes: friendContributeData.getAttributes())
            statusDetailAttributedString.append(addedAttributedString)
        }
        
        return statusDetailAttributedString
    }


    public func getStatusBarAttributedString() -> NSAttributedString {
        let statusDetailAttributedString = NSMutableAttributedString()
        let emoji = count.getEmoji()
        let textString = "\(emoji) \(count)"
        
        let attributedString = NSAttributedString(string: textString, attributes: getAttributes())
        statusDetailAttributedString.append(attributedString)
        
        if self.friendContributeData != nil {
            guard let friendContributeData = self.friendContributeData else {return statusDetailAttributedString}
            let AddedTextString = "\(friendContributeData.count) \(friendContributeData.count.getEmoji())"
            
            statusDetailAttributedString.append(NSAttributedString(string: " vs ", attributes: Attributes.white))
            
            let addedAttributedString = NSAttributedString(string: AddedTextString, attributes: friendContributeData.getAttributes())
            statusDetailAttributedString.append(addedAttributedString)
        }
        
        return statusDetailAttributedString
    }

    public func getGoalAttributedString(goal: Int) -> NSAttributedString {
        let goalAttributedString = NSMutableAttributedString()

        let textString: String
        if count >= goal {
            textString = Localized.goalAccomplished
        } else {
            textString = Localized.goalToGo.replacingOccurrences(of: "${commit}", with: getGoalCountString(goal))
        }

        let attributedString = NSAttributedString(string: textString, attributes: getGoalAttributes(goal))
        goalAttributedString.append(attributedString)

        return goalAttributedString
    }
    
    
}
