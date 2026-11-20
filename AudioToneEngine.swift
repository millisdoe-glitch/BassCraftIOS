import Foundation
import AVFoundation

/// Реальный генератор низкочастотного звука (20-90 Гц) для iOS с использованием AVAudioEngine и SourceNode
final class AudioToneEngine: ObservableObject {
    static let shared = AudioToneEngine()
    
    private var audioEngine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    
    @Published var isPlaying: Bool = false
    
    // Потоковые параметры генерации
    private var currentFrequency: Float = 40.0
    private var targetFrequency: Float = 40.0
    private var currentAmplitude: Float = 0.0
    private var targetAmplitude: Float = 0.0
    private var isClipping: Bool = false
    
    private var phase: Float = 0.0
    private let sampleRate: Float = 44100.0
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Ошибка настройки AVAudioSession: \(error)")
        }
    }
    
    func start() {
        guard !isPlaying else { return }
        
        let engine = AVAudioEngine()
        self.audioEngine = engine
        
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!
        
        let node = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            guard let buffer = ablPointer.first, let ptr = buffer.mData?.assumingMemoryBound(to: Float.self) else {
                return noErr
            }
            
            for frame in 0..<Int(frameCount) {
                // Плавная интерполяция частоты и громкости для исключения щелчков
                self.currentFrequency += (self.targetFrequency - self.currentFrequency) * 0.005
                self.currentAmplitude += (self.targetAmplitude - self.currentAmplitude) * 0.005
                
                let phaseIncrement = (2.0 * Float.pi * self.currentFrequency) / self.sampleRate
                var sample = sin(self.phase) * self.currentAmplitude
                
                // Симуляция жесткого клиппинга (Hard Clipping / овердрайв катушки)
                if self.isClipping {
                    sample = max(-0.85, min(0.85, sample * 1.8))
                }
                
                ptr[frame] = sample
                self.phase += phaseIncrement
                if self.phase >= 2.0 * Float.pi {
                    self.phase -= 2.0 * Float.pi
                }
            }
            return noErr
        }
        
        self.sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
            isPlaying = true
        } catch {
            print("Не удалось запустить аудио движок: \(error)")
        }
    }
    
    func stop() {
        audioEngine?.stop()
        audioEngine?.reset()
        audioEngine = nil
        sourceNode = nil
        isPlaying = false
    }
    
    func update(frequency: Double, volume: Double, clipping: Bool) {
        self.targetFrequency = Float(frequency)
        self.targetAmplitude = Float(min(1.0, max(0.0, volume)))
        self.isClipping = clipping
    }
}
