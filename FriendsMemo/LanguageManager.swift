//
//  LanguageManager.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 18/03/25.
//


import Foundation
import SwiftUI

// Dil Yönetimi Yardımcı Sınıfı
class LanguageManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            UserDefaults.standard.synchronize()
        }
    }
    
    static let shared = LanguageManager()
    
    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? 
                               Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    // Dil değiştirme işlevi
    func changeLanguage(_ languageCode: String) {
        self.currentLanguage = languageCode
        // Dil değiştiğinde uygulamanın dil kaynaklarını yenilemesi için bildirim gönder
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
    }
    
    // Uygulama içinde kullanılabilecek dillerin listesi
    static let availableLanguages = [
        ("en", "English"),
        ("tr", "Türkçe")
    ]
}