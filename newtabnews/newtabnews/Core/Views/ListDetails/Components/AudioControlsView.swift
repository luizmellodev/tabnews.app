//
//  AudioControlsView.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct AudioControlsView: View {
    @ObservedObject var ttsManager: TextToSpeechManager
    let post: PostRequest
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                PlayPauseButton(ttsManager: ttsManager, post: post)
                StopButton(ttsManager: ttsManager)
            }
            
            SpeedControlsView(ttsManager: ttsManager)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

struct PlayPauseButton: View {
    @ObservedObject var ttsManager: TextToSpeechManager
    let post: PostRequest
    
    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            if ttsManager.isPlaying {
                ttsManager.pause()
            } else if ttsManager.isPaused {
                ttsManager.resume()
            } else {
                ttsManager.speak(text: post.body ?? "", title: post.title)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: ttsManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.callout)
                Text(ttsManager.isPlaying ? "Pausar" : (ttsManager.isPaused ? "Retomar" : "Iniciar"))
                    .font(.subheadline)
            }
            .foregroundColor(.blue)
            .frame(height: 44)
            .padding(.horizontal, 16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct StopButton: View {
    @ObservedObject var ttsManager: TextToSpeechManager
    
    var body: some View {
        Button {
            ttsManager.stop()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "stop.fill")
                    .font(.callout)
                Text("Parar")
                    .font(.subheadline)
            }
            .foregroundColor(ttsManager.isPlaying || ttsManager.isPaused ? .red : .gray)
            .frame(height: 44)
            .padding(.horizontal, 16)
            .background((ttsManager.isPlaying || ttsManager.isPaused ? Color.red : Color.gray).opacity(0.1))
            .cornerRadius(10)
        }
        .disabled(!ttsManager.isPlaying && !ttsManager.isPaused)
        .opacity(ttsManager.isPlaying || ttsManager.isPaused ? 1 : 0.5)
    }
}

struct SpeedControlsView: View {
    @ObservedObject var ttsManager: TextToSpeechManager
    
    private let speeds: [Float] = [0.5, 1.0, 1.5, 2.0, 3.0]
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Velocidade:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(speeds, id: \.self) { speed in
                SpeedButton(
                    speed: speed,
                    isSelected: ttsManager.currentRate == speed,
                    action: { ttsManager.setSpeed(speed) }
                )
            }
        }
    }
}

struct SpeedButton: View {
    let speed: Float
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(formatSpeed(speed))
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .blue)
                .frame(minWidth: 44, minHeight: 32)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private func formatSpeed(_ speed: Float) -> String {
        if speed == 1.0 {
            return "1x"
        } else if speed.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(speed))x"
        } else {
            return "\(speed)x"
        }
    }
}

