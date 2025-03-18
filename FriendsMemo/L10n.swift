//
//  L10n.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 18/03/25.
//


import Foundation
import SwiftUI

// A localization manager to provide type-safe string localization
enum L10n {
    // MARK: - Main Views
    enum MainViews {
        static let memoryLibrary = NSLocalizedString("Memory Library", comment: "Main title for the memory library screen")
        static let noMemoriesYet = NSLocalizedString("No memories yet", comment: "Text shown when no memories exist")
        static let addMemory = NSLocalizedString("Add Memory", comment: "Button to add new memory")
        static let edit = NSLocalizedString("Edit", comment: "Edit mode button")
        static let done = NSLocalizedString("Done", comment: "Done button text")
    }
    
    // MARK: - Book Management
    enum Books {
        static let newMemory = NSLocalizedString("New Memory", comment: "Title for creating a new memory")
        static let bookTitle = NSLocalizedString("Book Title", comment: "Placeholder for book title")
        static let enterBookName = NSLocalizedString("Enter Book Name", comment: "Placeholder for book name input")
        static let bookCover = NSLocalizedString("Book Cover", comment: "Label for book cover selection")
        static let title = NSLocalizedString("TITLE", comment: "Title label")
    }
    
    // MARK: - Page Management
    enum Pages {
        static let page = NSLocalizedString("Page", comment: "Page label")
        static func pageNumber(_ number: Int) -> String {
            return String(format: NSLocalizedString("Page %@", comment: "Page number format"), "\(number)")
        }
        static let tapToAddFirstPage = NSLocalizedString("Tap + to add your first page", comment: "Instruction to add first page")
        static let clearPageContent = NSLocalizedString("Clear Page Content", comment: "Alert title for clearing page")
        static let clearPageConfirmation = NSLocalizedString("Are you sure you want to clear all content from this page?", comment: "Confirmation message for clearing page")
    }
    
    // MARK: - Alerts and Buttons
    enum Common {
        static let delete = NSLocalizedString("Delete", comment: "Delete button")
        static let cancel = NSLocalizedString("Cancel", comment: "Cancel button")
        static let clear = NSLocalizedString("Clear", comment: "Clear button")
        static let deleteConfirmation = NSLocalizedString("Are you sure you want to delete this book?", comment: "Delete confirmation")
    }
    
    // MARK: - Onboarding
    enum Onboarding {
        static let skip = NSLocalizedString("Skip", comment: "Skip onboarding")
        static let continue_ = NSLocalizedString("Continue", comment: "Continue to next screen")
        static let getStarted = NSLocalizedString("Get Started", comment: "Get started button")
        
        // Titles
        static let createMemoryBooks = NSLocalizedString("Create Memory Books", comment: "Onboarding title 1")
        static let addPagesToBooks = NSLocalizedString("Add Pages to Your Books", comment: "Onboarding title 2")
        static let drawMemories = NSLocalizedString("Draw Your Memories", comment: "Onboarding title 3")
        static let addTextAndImages = NSLocalizedString("Add Text and Images", comment: "Onboarding title 4")
        
        // Descriptions
        static let createMemoryBooksDesc = NSLocalizedString("Design personalized memory books with custom colors to organize your special moments", comment: "Onboarding description 1")
        static let addPagesToBooksDesc = NSLocalizedString("Build your collection by adding new pages to capture every important memory", comment: "Onboarding description 2")
        static let drawMemoriesDesc = NSLocalizedString("Express yourself through drawing directly on your memory pages", comment: "Onboarding description 3")
        static let addTextAndImagesDesc = NSLocalizedString("Enhance your memories with photos and text to tell your complete story", comment: "Onboarding description 4")
    }
}

// Extension to support language switching at runtime
extension L10n {
    // Get the current app language
    static var currentLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: "AppLanguage") ?? Locale.current.language.languageCode?.identifier ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "AppLanguage")
            UserDefaults.standard.synchronize()
            
            // Update the app's language
            Bundle.setLanguage(newValue)
            
            // Post notification about language change
            NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        }
    }
    
    // Get available languages (you can expand this list)
    static var availableLanguages: [(code: String, name: String)] {
        return [
            ("en", "English"),
            ("tr", "Türkçe")
        ]
    }
}

// Extension to Bundle to support language switching
extension Bundle {
    private static var bundle: Bundle?
    
    // Set the app's language
    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            bundle = Bundle.main
            return
        }
        
        bundle = Bundle(path: path)
    }
    
    // Override the localized string methods
    static func localizedString(forKey key: String, value: String?, table: String?) -> String {
        return bundle?.localizedString(forKey: key, value: value, table: table) ?? 
               Bundle.main.localizedString(forKey: key, value: value, table: table)
    }
}

// Initialize the bundle with the saved language when the app launches
extension Bundle {
    static func initializeLanguage() {
        let language = L10n.currentLanguage
        Bundle.setLanguage(language)
    }
}