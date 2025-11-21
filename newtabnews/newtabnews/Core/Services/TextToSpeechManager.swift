//
//  TextToSpeechManager.swift
//  newtabnews
//
//  Created by Luiz Mello on 19/11/25.
//

import Foundation
import AVFoundation
import Combine

class TextToSpeechManager: NSObject, ObservableObject {
    static let shared = TextToSpeechManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentRate: Float = 1.0 // Velocidade do usuário (0.5x, 1x, 1.5x, 2x)
    
    private override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // Converter velocidade do usuário (0.5x, 1x, 2x) para escala do AVSpeech (0.0-1.0)
    private func avSpeechRate(from userSpeed: Float) -> Float {
        // AVSpeechUtteranceDefaultSpeechRate ≈ 0.5 (velocidade normal)
        // Mapear: 1x do usuário = 0.5 do AVSpeech (normal)
        //         0.5x do usuário = 0.25 do AVSpeech (metade)
        //         2x do usuário = 1.0 do AVSpeech (dobro/máximo)
        let normalRate = AVSpeechUtteranceDefaultSpeechRate
        let mappedRate = normalRate * userSpeed
        
        // Limitar entre mínimo e máximo permitido
        return min(max(mappedRate, AVSpeechUtteranceMinimumSpeechRate), AVSpeechUtteranceMaximumSpeechRate)
    }
    
    func speak(text: String, title: String? = nil) {
        // Salvar para poder reiniciar se mudar velocidade
        currentText = text
        currentTitle = title
        
        // Parar qualquer reprodução anterior
        if synthesizer.isSpeaking {
            stop()
        }
        
        // Limpar markdown básico
        let cleanText = text
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "`", with: "")
        
        // Adicionar título se fornecido
        var fullText = cleanText
        if let title = title {
            fullText = "\(title). \(cleanText)"
        }
        
        let utterance = AVSpeechUtterance(string: fullText)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = avSpeechRate(from: currentRate)
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        print("🔊 [TTS] Iniciando reprodução")
        print("   Velocidade usuário: \(currentRate)x")
        print("   Velocidade AVSpeech: \(utterance.rate)")
        
        synthesizer.speak(utterance)
        isPlaying = true
        isPaused = false
    }
    
    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .word)
        isPaused = true
        isPlaying = false
    }
    
    func resume() {
        guard synthesizer.isPaused else { return }
        synthesizer.continueSpeaking()
        isPaused = false
        isPlaying = true
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        isPaused = false
        // Não limpar currentText/currentTitle aqui, pois pode estar mudando velocidade
    }
    
    func togglePlayPause(text: String, title: String? = nil) {
        if isPlaying {
            pause()
        } else if isPaused {
            resume()
        } else {
            speak(text: text, title: title)
        }
    }
    
    private var currentText: String?
    private var currentTitle: String?
    
    func setSpeed(_ speed: Float) {
        // Speed vem em formato de usuário: 0.5x, 1x, 1.5x, 2x
        let newRate = speed
        
        // Se a velocidade mudou e está tocando, reiniciar
        if newRate != currentRate && (isPlaying || isPaused) {
            print("🔄 [TTS] Mudando velocidade de \(currentRate)x para \(newRate)x")
            
            currentRate = newRate
            
            // Salvar estado atual
            let wasPlaying = isPlaying
            
            // Parar reprodução atual
            stop()
            
            // Se estava tocando, reiniciar com nova velocidade
            if wasPlaying, let text = currentText {
                print("   ↻ Reiniciando áudio com nova velocidade...")
                speak(text: text, title: currentTitle)
            }
        } else {
            currentRate = newRate
            print("🔄 [TTS] Velocidade configurada: \(newRate)x")
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TextToSpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isPaused = false
            // Limpar cache quando terminar naturalmente
            self.currentText = nil
            self.currentTitle = nil
            print("✅ [TTS] Reprodução finalizada")
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isPaused = false
            // Não limpar cache aqui (pode estar mudando velocidade)
        }
    }
}

