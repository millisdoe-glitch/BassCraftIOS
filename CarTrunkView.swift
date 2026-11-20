import SwiftUI

struct CarTrunkView: View {
    @Binding var selectedDriver: SubwooferDriver
    @Binding var selectedAmp: Amplifier
    @Binding var boxVolume: Double
    @Binding var isPlaying: Bool
    @Binding var splDb: Double
    @Binding var isClipping: Bool
    
    @State private var batteryType: BatteryType = .agm
    @State private var wireGauge: WireGauge = .gauge0
    @State private var haloColorIndex = 0
    @State private var headUnitTrack = "Bass Mekanik - 35Hz Drop"
    @State private var bassRemoteLevel: Double = 0.85
    @State private var trunkOpen = true
    
    let haloColors: [Color] = [.cyan, .green, .pink, .orange, .blue]
    
    // Моделирование просадки напряжения (Voltage Drop)
    var currentVoltage: Double {
        let nominal = batteryType.nominalVoltage
        if !isPlaying { return nominal }
        
        let powerRatio = bassRemoteLevel * (isClipping ? 1.25 : 0.9)
        let cableLoss = wireGauge.resistancePerMeter * 5.0 * 25.0 * powerRatio
        let battSag = batteryType.internalResistance * 180.0 * powerRatio
        
        return max(9.8, nominal - cableLoss - battSag)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Вид на открытый багажник автомобиля (Trunk View)
                ZStack {
                    // Кузов автомобиля (спорт-хэтчбек / седан)
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(colors: [Color(white: 0.08), Color(white: 0.14), Color.black], startPoint: .top, endPoint: .bottom))
                        .frame(height: 290)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.cyan.opacity(0.4), lineWidth: 2)
                        )
                    
                    VStack(spacing: 12) {
                        // Верхняя кромка багажника и задние фонари
                        HStack {
                            Circle().fill(Color.red.opacity(0.8)).frame(width: 14, height: 14).blur(radius: 2)
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 3)
                            Text("BASS CRAFT TRUNK")
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(.cyan)
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 3)
                            Circle().fill(Color.red.opacity(0.8)).frame(width: 14, height: 14).blur(radius: 2)
                        }
                        .padding(.horizontal, 24)
                        
                        // Сдвоенный короб с сабвуферами и неоновыми LED Halo-кольцами
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [Color(white: 0.18), Color(white: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 280, height: 140)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 3)
                                )
                            
                            HStack(spacing: 26) {
                                // Левый сабвуфер с LED ореолом
                                SubwooferSpeakerUnit(
                                    driver: selectedDriver,
                                    haloColor: haloColors[haloColorIndex],
                                    isPlaying: isPlaying,
                                    isClipping: isClipping
                                )
                                
                                // Правый сабвуфер с LED ореолом
                                SubwooferSpeakerUnit(
                                    driver: selectedDriver,
                                    haloColor: haloColors[haloColorIndex],
                                    isPlaying: isPlaying,
                                    isClipping: isClipping
                                )
                            }
                            
                            // Центральный щелевой порт с эффектом воздуха
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 18, height: 100)
                                .overlay(
                                    Rectangle().stroke(Color.cyan.opacity(0.8), lineWidth: 1)
                                )
                                .offset(x: 0)
                        }
                        
                        // Моноблок MONO-3500.1 и силовая проводка
                        HStack(spacing: 16) {
                            // Золотистый усилитель MONO-3500.1
                            VStack(spacing: 2) {
                                Text("MONO-3500.1")
                                    .font(.system(size: 9, weight: .black, design: .monospaced))
                                    .foregroundColor(.black)
                                Text("CLASS D SUB AMPLIFIER")
                                    .font(.system(size: 6, weight: .bold))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            .frame(width: 130, height: 38)
                            .background(
                                LinearGradient(colors: [Color(red: 0.9, green: 0.75, blue: 0.3), Color(red: 0.75, green: 0.55, blue: 0.15)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(6)
                            
                            // Блок предохранителя ANL и проводка 0 Ga
                            HStack(spacing: 6) {
                                Circle().fill(Color.red).frame(width: 8, height: 8) // + 12V
                                Rectangle().fill(Color.yellow.opacity(0.8)).frame(width: 26, height: 10).cornerRadius(2) // ANL Fuse
                                Circle().fill(Color.black).frame(width: 8, height: 8) // GND
                            }
                            .padding(6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Цифровой вольтметр (Просадка в реальном времени)
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("НАПРЯЖЕНИЕ СЕТИ")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f V", currentVoltage))
                            .font(.system(size: 34, weight: .black, design: .monospaced))
                            .foregroundColor(currentVoltage < 11.5 ? .red : (currentVoltage < 12.8 ? .yellow : .green))
                    }
                    
                    Spacer()
                    
                    // Выносной регулятор баса (Bass Remote)
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("BASS REMOTE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isClipping ? Color.red : Color.green)
                                .frame(width: 10, height: 10)
                                .shadow(color: isClipping ? .red : .green, radius: 4)
                            Text(isClipping ? "CLIP" : "NORM")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(isClipping ? .red : .green)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(18)
                .padding(.horizontal)
                
                // MARK: - Магнитола VOLTEX в салоне
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "radio.fill")
                            .foregroundColor(.red)
                        Text("ГОЛОВНОЕ УСТРОЙСТВО · VOLTEX-1DIN")
                            .font(.caption.bold())
                        Spacer()
                        Circle().fill(Color.blue).frame(width: 8, height: 8) // USB indicator
                        Text("USB FLASHDRIVE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    // Цифровой экран магнитолы
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.red)
                        Text(headUnitTrack)
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .foregroundColor(.red)
                        Spacer()
                        Text("VOL 42")
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .foregroundColor(.red)
                    }
                    .padding(10)
                    .background(Color.black)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.5), lineWidth: 1))
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(18)
                .padding(.horizontal)
                
                // MARK: - Настройки питания и кастомизация LED-подсветки
                VStack(alignment: .leading, spacing: 14) {
                    Text("Конфигурация питания и стиль:")
                        .font(.headline)
                    
                    // Выбор АКБ
                    Picker("Аккумулятор", selection: $batteryType) {
                        ForEach(BatteryType.allCases) { b in
                            Text(b.rawValue).tag(b)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Выбор силового кабеля
                    Picker("Сечение провода", selection: $wireGauge) {
                        ForEach(WireGauge.allCases) { w in
                            Text(w.rawValue).tag(w)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Цвет подсветки диффузоров
                    HStack {
                        Text("Цвет подсветки (LED Halo):")
                            .font(.subheadline)
                        Spacer()
                        HStack(spacing: 10) {
                            ForEach(0..<haloColors.count, id: \.self) { idx in
                                Circle()
                                    .fill(haloColors[idx])
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: haloColorIndex == idx ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        haloColorIndex = idx
                                    }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(18)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct SubwooferSpeakerUnit: View {
    let driver: SubwooferDriver
    let haloColor: Color
    let isPlaying: Bool
    let isClipping: Bool
    
    var body: some View {
        ZStack {
            // Неоновое кольцо подсветки (Halo Ring)
            Circle()
                .stroke(haloColor, lineWidth: 5)
                .frame(width: 105, height: 105)
                .shadow(color: haloColor, radius: isPlaying ? 8 : 2)
            
            // Подвес
            Circle()
                .fill(RadialGradient(colors: [Color.black, Color(white: 0.25)], center: .center, startRadius: 15, endRadius: 48))
                .frame(width: 95, height: 95)
            
            // Диффузор с динамическим ходом
            Circle()
                .fill(RadialGradient(colors: [Color(white: 0.2), Color.black], center: .center, startRadius: 5, endRadius: 35))
                .frame(width: 72, height: 72)
                .scaleEffect(isPlaying ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 0.08).repeatForever(autoreverses: true), value: isPlaying)
            
            // Колпак с логотипом
            Circle()
                .fill(Color(white: 0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Text("BC")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(haloColor)
                )
        }
    }
}
