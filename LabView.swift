import SwiftUI

struct LabView: View {
    @Binding var selectedDriver: SubwooferDriver
    @Binding var selectedAmp: Amplifier
    @Binding var enclosureMode: EnclosureMode
    @Binding var boxVolume: Double
    @Binding var portArea: Double
    @Binding var portLength: Double
    @Binding var isCoilsSeries: Bool
    @Binding var subsonicFilter: Double
    @Binding var subsonicEnabled: Bool
    
    @State private var frequency: Double = 35.0
    @State private var gainLevel: Double = 0.8
    @State private var isMuted: Bool = true
    @State private var testRunning: Bool = false
    @State private var timerSeconds: Double = 0.0
    @State private var portSmokeOpacity: Double = 0.0
    @State private var damageWarning: String? = nil
    
    @StateObject private var audio = AudioToneEngine.shared
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var simResult: LabSimulationResult {
        PhysicsEngine.runSimulation(
            driver: selectedDriver,
            enclosureMode: enclosureMode,
            boxVolumeLiters: boxVolume,
            portAreaCm2: portArea,
            portLengthCm: portLength,
            subsonicFilterHz: subsonicFilter,
            subsonicEnabled: subsonicEnabled,
            amp: selectedAmp,
            isCoilsSeries: isCoilsSeries,
            gainLevel: testRunning ? gainLevel : 0.0,
            frequencyHz: frequency,
            elapsedTimeSeconds: timerSeconds
        )
    }
    
    // Просадка напряжения на стенде
    var benchVoltage: Double {
        if !testRunning { return 14.4 }
        let sag = (simResult.deliveredPowerWatts / 2500.0) * 2.8
        return max(10.2, 14.4 - sag)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Датчик звукового давления SPL (Term-Lab Sensor)
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: "gauge.with.needle.fill")
                            .foregroundColor(.yellow)
                        Text("SPL LAB SENSOR")
                            .font(.caption.bold())
                            .foregroundColor(.gray)
                        Spacer()
                        // Вольтметр на стенде
                        Text(String(format: "%.1f V", benchVoltage))
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundColor(benchVoltage < 11.5 ? .red : .yellow)
                        Text("·")
                            .foregroundColor(.gray)
                        Text("\(Int(frequency)) Hz")
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                    
                    Text(String(format: "%.1f", testRunning ? simResult.splDb : 0.0))
                        .font(.system(size: 62, weight: .black, design: .monospaced))
                        .foregroundColor(simResult.isClipping ? .red : .green)
                        .shadow(color: simResult.isClipping ? .red.opacity(0.8) : .green.opacity(0.6), radius: 10)
                    
                    Text("DECIBELS (dB)")
                        .font(.caption2.weight(.heavy))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(simResult.isClipping ? Color.red : Color.cyan.opacity(0.4), lineWidth: 2)
                )
                
                // MARK: - Динамик и эффект дыма / воздуха из порта
                ZStack {
                    // Корзина сабвуфера
                    Circle()
                        .stroke(Color.gray.opacity(0.35), lineWidth: 16)
                        .frame(width: 210, height: 210)
                    
                    // Неоновый Halo обод
                    Circle()
                        .stroke(simResult.isClipping ? Color.red : Color.cyan, lineWidth: 4)
                        .frame(width: 195, height: 195)
                        .shadow(color: simResult.isClipping ? Color.red : Color.cyan, radius: testRunning ? 10 : 2)
                    
                    // Подвес (Surround)
                    Circle()
                        .fill(RadialGradient(colors: [Color.black, Color(white: 0.22)], center: .center, startRadius: 40, endRadius: 95))
                        .frame(width: 185, height: 185)
                    
                    // Диффузор (Cone)
                    Circle()
                        .fill(RadialGradient(colors: [Color(white: 0.18), Color.black], center: .center, startRadius: 10, endRadius: 65))
                        .frame(width: 140, height: 140)
                        .scaleEffect(testRunning ? (1.0 + CGFloat(min(0.35, simResult.excursionPercent / 420.0))) : 1.0)
                        .animation(.easeInOut(duration: 0.07).repeatForever(autoreverses: true), value: testRunning ? simResult.excursionPercent : 0)
                    
                    // Колпак
                    Circle()
                        .fill(LinearGradient(colors: [Color(white: 0.28), Color.black], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 65, height: 65)
                        .overlay(
                            Text(selectedDriver.brand.uppercased())
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(simResult.isClipping ? .red : .white.opacity(0.85))
                        )
                    
                    // Анимация дыма при перегреве катушки
                    if simResult.isThermalOverload {
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 90, height: 90)
                            .blur(radius: 12)
                            .offset(y: -40)
                    }
                }
                .padding(.vertical, 8)
                
                // MARK: - Предупреждения об авариях
                if simResult.isBottomingOut {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("ОПАСНОСТЬ: ПРЕВЫШЕНИЕ ХОДА (СТУК КАТУШКИ)!")
                            .font(.caption.bold())
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                if simResult.isThermalOverload {
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("КРИТИЧЕСКИЙ ПЕРЕГРЕВ: КАТУШКА ДЫМИТ!")
                            .font(.caption.bold())
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                // MARK: - Аварийные индикаторы
                HStack(spacing: 12) {
                    IndicatorBadge(title: "CLIP", active: simResult.isClipping, color: .red)
                    IndicatorBadge(title: "XMAX", active: simResult.isBottomingOut, color: .orange)
                    IndicatorBadge(title: "TEMP \(Int(simResult.coilTemperatureC))°C", active: simResult.isThermalOverload, color: .purple)
                }
                
                // Показатели мощности и нагрузки
                HStack(spacing: 16) {
                    VStack {
                        Text("Мощность")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(Int(simResult.deliveredPowerWatts)) Вт")
                            .font(.headline)
                    }
                    Divider().frame(height: 30)
                    VStack {
                        Text("Импеданс")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f Ом", simResult.currentImpedanceOhm))
                            .font(.headline)
                    }
                    Divider().frame(height: 30)
                    VStack {
                        Text("Ход Xmax")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f мм", simResult.coneExcursionMm))
                            .font(.headline)
                            .foregroundColor(simResult.isBottomingOut ? .red : .primary)
                    }
                }
                .padding(.vertical, 4)
                
                // MARK: - Элементы управления
                VStack(spacing: 16) {
                    // Быстрые пресеты частот
                    HStack(spacing: 8) {
                        ForEach([25, 30, 35, 40, 50], id: \.self) { hz in
                            Button("\(hz)Hz") {
                                frequency = Double(hz)
                            }
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Int(frequency) == hz ? Color.cyan : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Слайдер частоты синуса
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Частота сигнала:")
                                .font(.subheadline.bold())
                            Spacer()
                            Text("\(Int(frequency)) Гц")
                                .font(.subheadline.bold())
                                .foregroundColor(.cyan)
                        }
                        Slider(value: $frequency, in: 20...90, step: 1)
                            .accentColor(.cyan)
                    }
                    
                    // Регулятор Gain / Громкость
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Уровень Gain / Громкость:")
                                .font(.subheadline.bold())
                            Spacer()
                            Text("\(Int(gainLevel * 100))%")
                                .font(.subheadline.bold())
                                .foregroundColor(simResult.isClipping ? .red : .green)
                        }
                        Slider(value: $gainLevel, in: 0.05...1.0, step: 0.01)
                            .accentColor(simResult.isClipping ? .red : .green)
                    }
                    
                    // Кнопки запуска
                    HStack(spacing: 14) {
                        Button(action: toggleTest) {
                            HStack {
                                Image(systemName: testRunning ? "stop.fill" : "play.fill")
                                Text(testRunning ? "СТОП ЗАМЕР" : "СТАРТ ЗАМЕРА")
                                    .fontWeight(.heavy)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(testRunning ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        
                        Button(action: toggleAudio) {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                                .font(.title3)
                                .frame(width: 54, height: 50)
                                .background(isMuted ? Color.gray.opacity(0.3) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(20)
            }
            .padding()
        }
        .onReceive(timer) { _ in
            if testRunning {
                timerSeconds += 0.1
                if !isMuted {
                    audio.update(frequency: frequency, volume: gainLevel * 0.7, clipping: simResult.isClipping)
                }
            } else {
                timerSeconds = max(0, timerSeconds - 0.2)
            }
        }
        .onDisappear {
            audio.stop()
        }
    }
    
    private func toggleTest() {
        testRunning.toggle()
        if testRunning {
            if !isMuted {
                audio.start()
                audio.update(frequency: frequency, volume: gainLevel * 0.7, clipping: simResult.isClipping)
            }
        } else {
            audio.stop()
        }
    }
    
    private func toggleAudio() {
        isMuted.toggle()
        if !isMuted && testRunning {
            audio.start()
            audio.update(frequency: frequency, volume: gainLevel * 0.7, clipping: simResult.isClipping)
        } else {
            audio.stop()
        }
    }
}
