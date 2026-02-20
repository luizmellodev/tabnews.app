//
//  BetaTesterService.swift
//  newtabnews
//
//  Created by Luiz Mello on 28/12/24.
//

import Foundation
import StoreKit

/// Serviço para detectar e gerenciar status de beta tester
class BetaTesterService {
    static let shared = BetaTesterService()
    
    private let userDefaults = UserDefaults.standard
    private let betaTesterKey = "isBetaTester"
    private let betaTesterDateKey = "betaTesterSinceDate"
    
    private init() {
        checkAndSaveBetaTesterStatus()
    }
    
    /// Verifica se o usuário é beta tester (instalou via TestFlight)
    var isBetaTester: Bool {
        return userDefaults.bool(forKey: betaTesterKey)
    }
    
    /// Data desde quando o usuário é beta tester
    var betaTesterSince: Date? {
        return userDefaults.object(forKey: betaTesterDateKey) as? Date
    }
    
    /// Verifica e salva o status de beta tester
    private func checkAndSaveBetaTesterStatus() {
        if userDefaults.object(forKey: betaTesterKey) != nil {
            return
        }
        
        let earlyAdopterCutoffDate = Calendar.current.date(
            from: DateComponents(year: 2026, month: 7, day: 01)
        ) ?? Date()
        
        if Date() < earlyAdopterCutoffDate {
            userDefaults.set(true, forKey: betaTesterKey)
            userDefaults.set(Date(), forKey: betaTesterDateKey)
        } else {
            if isTestFlightEnvironment() {
                userDefaults.set(true, forKey: betaTesterKey)
                userDefaults.set(Date(), forKey: betaTesterDateKey)
            } else {
                userDefaults.set(false, forKey: betaTesterKey)
            }
        }
    }
    
    /// Detecta se o app está rodando no TestFlight
    private func isTestFlightEnvironment() -> Bool {
        // Método 1: Verifica o receipt do app
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            let receiptPath = receiptURL.path
            
            // No TestFlight, o receipt está em "sandboxReceipt"
            if receiptPath.contains("sandboxReceipt") {
                return true
            }
        }
        
        // Método 2: Verifica se está em ambiente sandbox
        #if DEBUG
        return false // Em debug, não é TestFlight
        #else
        // Verifica se o app tem o perfil de provisioning do TestFlight
        if let provisioningPath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
           let provisioningData = try? Data(contentsOf: URL(fileURLWithPath: provisioningPath)),
           let provisioningString = String(data: provisioningData, encoding: .ascii) {
            
            // TestFlight usa perfil "Beta" ou "TestFlight"
            return provisioningString.contains("beta-reports-active") ||
                   provisioningString.contains("TestFlight")
        }
        #endif
        
        return false
    }
    
    /// Formata quanto tempo a pessoa é beta tester
    func getBetaTesterDuration() -> String? {
        guard let since = betaTesterSince else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: since, to: Date())
        
        if let years = components.year, years > 0 {
            return years == 1 ? "há 1 ano" : "há \(years) anos"
        } else if let months = components.month, months > 0 {
            return months == 1 ? "há 1 mês" : "há \(months) meses"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "há 1 dia" : "há \(days) dias"
        }
        
        return "hoje"
    }
    
    // MARK: - Debug/Testing
    
    /// Força o status de beta tester (apenas para testes)
    func forceBetaTesterStatus(_ isBeta: Bool) {
        userDefaults.set(isBeta, forKey: betaTesterKey)
        if isBeta && betaTesterSince == nil {
            userDefaults.set(Date(), forKey: betaTesterDateKey)
        }
    }
    
    /// Reseta o status de beta tester (apenas para testes)
    func resetBetaTesterStatus() {
        userDefaults.removeObject(forKey: betaTesterKey)
        userDefaults.removeObject(forKey: betaTesterDateKey)
    }
}

