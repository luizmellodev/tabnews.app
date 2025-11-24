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
    
    private var isRestarting = false // Flag para indicar que está reiniciando (mudança de velocidade)
    private var audioSessionConfigured = false
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        
        // Pré-configura a sessão de áudio para evitar delay na primeira reprodução
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        guard !audioSessionConfigured else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
            audioSessionConfigured = true
            print("🔊 [TTS] Sessão de áudio pré-configurada no init")
        } catch {
            print("❌ [TTS] Erro ao pré-configurar áudio: \(error)")
        }
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
        print("💾 [TTS] Cache salvo - currentText: \(text.prefix(50))...")
        
        // Parar qualquer reprodução anterior
        if synthesizer.isSpeaking {
            print("⏸ [TTS] Parando reprodução anterior")
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Ativa a sessão de áudio (já pré-configurada no init)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true, options: [])
        } catch {
            print("❌ [TTS] Erro ao ativar áudio: \(error)")
        }
        
        // Limpar markdown completo
        let cleanText = cleanMarkdown(text)
        
        // Adicionar título se fornecido
        var fullText = cleanText
        if let title = title {
            fullText = "\(title). \(cleanText)"
        }
        
        // Validar que há texto para falar
        guard !fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ [TTS] Texto vazio após limpeza, não há nada para falar")
            return
        }
        
        let utterance = AVSpeechUtterance(string: fullText)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = avSpeechRate(from: currentRate)
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        print("🔊 [TTS] Iniciando reprodução")
        print("   Velocidade usuário: \(currentRate)x")
        print("   Velocidade AVSpeech: \(utterance.rate)")
        
        // Configurar estados ANTES de começar a falar (previne race condition)
        isPlaying = true
        isPaused = false
        
        synthesizer.speak(utterance)
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
        print("🛑 [TTS] Stop chamado")
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
    
    // Remove markdown e deixa só o texto limpo
    private func cleanMarkdown(_ text: String) -> String {
        var cleaned = text
        
        // Remove imagens: ![alt](url) -> ""
        cleaned = cleaned.replacingOccurrences(
            of: #"!\[([^\]]*)\]\(([^\)]+)\)"#,
            with: "",
            options: .regularExpression
        )
        
        // Remove links mas mantém o texto: [texto](url) -> texto
        cleaned = cleaned.replacingOccurrences(
            of: #"\[([^\]]+)\]\(([^\)]+)\)"#,
            with: "$1",
            options: .regularExpression
        )
        
        // Remove URLs automáticas
        cleaned = cleaned.replacingOccurrences(
            of: #"https?://[^\s<>]+"#,
            with: "",
            options: .regularExpression
        )
        
        // Remove bold: **texto** -> texto
        cleaned = cleaned.replacingOccurrences(
            of: #"\*\*([^*]+)\*\*"#,
            with: "$1",
            options: .regularExpression
        )
        
        // Remove itálico: *texto* -> texto
        cleaned = cleaned.replacingOccurrences(
            of: #"(?<!\*)\*([^*]+)\*(?!\*)"#,
            with: "$1",
            options: .regularExpression
        )
        
        // Remove headers: # Título -> Título
        cleaned = cleaned.replacingOccurrences(
            of: #"^#{1,6}\s+"#,
            with: "",
            options: .regularExpression
        )
        
        // Remove dividers: ---
        cleaned = cleaned.replacingOccurrences(
            of: #"^---+\s*$"#,
            with: "",
            options: .regularExpression
        )
        
        // Remove listas: - item -> item
        cleaned = cleaned.replacingOccurrences(
            of: #"^-\s+"#,
            with: "",
            options: .regularExpression
        )
        
        // Remove code inline: `código` -> código
        cleaned = cleaned.replacingOccurrences(
            of: #"`([^`]+)`"#,
            with: "$1",
            options: .regularExpression
        )
        
        // Remove comentários HTML
        cleaned = cleaned.replacingOccurrences(
            of: #"<!--[\s\S]*?-->"#,
            with: "",
            options: .regularExpression
        )
        
        // Remove múltiplos espaços e quebras de linha extras
        cleaned = cleaned.replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )
        
        cleaned = cleaned.replacingOccurrences(
            of: #"\s{2,}"#,
            with: " ",
            options: .regularExpression
        )
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func setSpeed(_ speed: Float) {
        let newRate = speed
        
        // Se a velocidade mudou
        if newRate != currentRate {
            print("🔄 [TTS] Mudando velocidade de \(currentRate)x para \(newRate)x")
            print("   isPlaying: \(isPlaying), isPaused: \(isPaused)")
            
            let wasPlaying = isPlaying
            let wasPaused = isPaused
            
            currentRate = newRate
            
            // Se está tocando ou pausado, reiniciar com nova velocidade
            if (wasPlaying || wasPaused) && currentText != nil {
                print("   ↻ Reiniciando áudio com nova velocidade...")
                
                // Marca que está reiniciando (para não limpar estados no delegate)
                isRestarting = true
                
                // Para o áudio diretamente (sem limpar estados com stop())
                synthesizer.stopSpeaking(at: .immediate)
                
                // Aguarda para o stop completar (reduzido para 0.1s)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print("   🔄 Tempo de espera completado, verificando estados...")
                    print("      isRestarting: \(self.isRestarting)")
                    print("      currentRate: \(self.currentRate)x")
                    print("      currentText existe: \(self.currentText != nil)")
                    
                    // Reinicia com nova velocidade
                    if let text = self.currentText {
                        self.speak(text: text, title: self.currentTitle)
                        
                        // Desmarca flag após o speak iniciar E o didFinish do antigo disparar
                        // Tempo aumentado para 1s para proteger contra mudanças rápidas
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.isRestarting = false
                            print("   ✅ Flag isRestarting desmarcada")
                        }
                    } else {
                        self.isRestarting = false
                        print("   ⚠️ currentText é nil, não é possível reiniciar")
                    }
                }
            } else {
                print("🔄 [TTS] Velocidade configurada para próxima reprodução: \(newRate)x")
            }
        } else {
            print("🔄 [TTS] Velocidade já está em \(newRate)x, ignorando")
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TextToSpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            // Garante que os estados estão corretos quando começa a falar
            print("▶️ [TTS] Iniciou a reprodução (rate: \(utterance.rate), currentRate: \(self.currentRate)x)")
            self.isPlaying = true
            self.isPaused = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            print("✅ [TTS] Reprodução finalizada naturalmente")
            print("   isRestarting: \(self.isRestarting)")
            
            // Se está reiniciando, NÃO limpar os estados nem o cache
            if !self.isRestarting {
                self.isPlaying = false
                self.isPaused = false
                // Limpar cache quando terminar naturalmente
                self.currentText = nil
                self.currentTitle = nil
                print("   ✓ Cache limpo (não estava reiniciando)")
            } else {
                print("   ✓ Cache preservado (está reiniciando)")
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            print("⏹ [TTS] Reprodução cancelada")
            print("   isRestarting: \(self.isRestarting)")
            print("   isPlaying antes: \(self.isPlaying)")
            
            // Se está reiniciando (mudando velocidade), não limpar os estados
            // pois o speak() já vai configurar os estados corretos
            if !self.isRestarting {
                self.isPlaying = false
                self.isPaused = false
                print("   ✓ Estados limpos (não estava reiniciando)")
            } else {
                print("   ✓ Estados preservados (está reiniciando)")
            }
            // Não limpar cache aqui (pode estar mudando velocidade)
        }
    }
}

