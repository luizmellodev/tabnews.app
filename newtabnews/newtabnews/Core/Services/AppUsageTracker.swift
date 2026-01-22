//
//  AppUsageTracker.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/11/25.
//

import Foundation
import Combine
import SwiftUI

class AppUsageTracker: ObservableObject {
    static let shared = AppUsageTracker()
    
    @Published var totalSecondsInApp: Int = 0
    @Published var shouldShowRestFolder: Bool = false
    @Published var shouldShowGameButton: Bool = false
    
    private var timer: Timer?
    private let gameButtonThreshold = 3600 // 1 hora (60 minutos)
    private let restFolderThreshold = 7200 // 2 horas (120 minutos)
    
    private init() {
        loadUsageData()
        startTracking()
    }
    
    func startTracking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.totalSecondsInApp += 1
            self.saveUsageData()
            self.checkThresholds()
        }
    }
    
    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkThresholds() {
        // Mostrar botão de jogo após 1 hora (easter egg raro)
        if totalSecondsInApp >= gameButtonThreshold && !shouldShowGameButton {
            shouldShowGameButton = true
            UserDefaults.standard.set(true, forKey: "hasShownGameButton")
        }
        
        // Mostrar pasta "Descanse" após 2 horas (easter egg muito raro)
        if totalSecondsInApp >= restFolderThreshold && !shouldShowRestFolder {
            shouldShowRestFolder = true
            UserDefaults.standard.set(true, forKey: "hasShownRestFolder")
        }
    }
    
    private func saveUsageData() {
        UserDefaults.standard.set(totalSecondsInApp, forKey: "totalSecondsInApp")
    }
    
    private func loadUsageData() {
        totalSecondsInApp = UserDefaults.standard.integer(forKey: "totalSecondsInApp")
        shouldShowGameButton = UserDefaults.standard.bool(forKey: "hasShownGameButton")
        shouldShowRestFolder = UserDefaults.standard.bool(forKey: "hasShownRestFolder")
    }
    
    func resetUsageForTesting() {
        totalSecondsInApp = 0
        shouldShowGameButton = false
        shouldShowRestFolder = false
        UserDefaults.standard.set(0, forKey: "totalSecondsInApp")
        UserDefaults.standard.set(false, forKey: "hasShownGameButton")
        UserDefaults.standard.set(false, forKey: "hasShownRestFolder")
    }
    
    var formattedTime: String {
        let minutes = totalSecondsInApp / 60
        let seconds = totalSecondsInApp % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

