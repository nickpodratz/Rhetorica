//
//  Language.swift
//  Rhetorica
//
//  Created by Nick Podratz on 27.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import Foundation


/// A wrapper for the interaction with several languages inside an application.
enum Language: Int, CustomStringConvertible {
    case German = 1
    case English
    
    /// The localized language name in english.
    var description: String {
        switch self {
        case .German: return "German"
        case .English: return "English"
        }
    }
    
    /// The localized language name.
    var localizedDescription: String {
        switch self {
        case .German: return NSLocalizedString("german", comment: "")
        case .English: return NSLocalizedString("english", comment: "")
        }
    }
}


// MARK: - Language + Latin Alphabet

extension Language {
    
    /// An array of all the capital letters of the latin alphabet in order.
    static let latinAlphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
}


// MARK: - Language + Language Identifier

extension Language {
    
    /// The two digit identifier used throughout the system to identify a language which belongs to the language set.
    var identifier: String {
        switch self {
        case .German: return "de"
        case .English: return "en"
        }
    }
    
    /// Tries to initialize the instance with the specified language identifier (Currently available: "de", "en").
    /// - Parameter identifier: The two digit identifier used throughout the system to identify a language.
    init?(identifier: String) {
        switch identifier {
        case "de": self = .German
        case "en": self = .English
        default: return nil
        }
    }    
}


// MARK: - Language + Persistence

extension Language {
    
    /// The key under which the custom language identifier is saved
    private static var selectedLanguageIdentifierKey = "selected_language_id"
    
    /// - Returns: The system's default language identifier.
    static func getSystemLanguageIdentifier() -> String {
        return NSBundle.mainBundle().preferredLocalizations.first!
    }
    
    /// - Returns: The user-specified language identifier if it was set or nil.
    static func getSelectedLanguageIdentifier() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(selectedLanguageIdentifierKey)
    }
    
    /// Saves the specified identifier to the user defaults for later retrieval.
    static func setSelectedLanguage(language: Language) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setValue(language.identifier, forKey: selectedLanguageIdentifierKey)
        defaults.synchronize()
    }
}


// MARK: - Language + All Languages Array

extension Language {
    
    /// An array of all languages available.
    static var allLanguages = [Language.German, Language.English]
}