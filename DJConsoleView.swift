import SwiftUI

struct DJConsoleView: View {
    @Binding var isPlaying: Bool
    @Binding var currentFrequency: Double
    
    @State private var selectedMode = 0 // 0 = DJ Console, 1 = Atmosphere Room
    @State private var deckARotation: Double = 0.0
    @State private var deckBRotation: Double = 0.0
    @State private var crossfader: Double = 0.5 // 0.0 (Deck A) ... 1.0 (Deck B)
    @State private var lowEq: Double = 0.8
    @State private var midEq: Double = 0.5
    @State private var highEq: Double = 0.5
    @State private var laserAngle: Double = 0.0
    
    let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Переключатель режима (DJ Пульт / Атмосфера)
                Picker("Режим", selection: $selectedMode) {
                    Text("DJ-Пульт").tag(0)
                    Text("Атмосфера (Вечеринка)").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedMode == 0 {
                    // MARK: - DJ-ПУЛЬТ НА 2 ДЕКИ
                    VStack(spacing: 16) {
                        
                        // Деки A и B
                        HStack(spacing: 24) {
                            // Deck A
                            DJJogWheelView(
                                deckName: "DECK A",
                                trackTitle: "Bass Drops 33Hz",
                                rotation: deckARotation,
                                color: .cyan,
                                isSpinning: isPlaying && crossfader < 0.8
                            )
                            
                            // Deck B
                            DJJogWheelView(
                                deckName: "DECK B",
                                trackTitle: "Trap Heavy Sub",
                                rotation: deckBRotation,
                                color: .purple,
                                isSpinning: isPlaying && crossfader > 0.2
                            )
                        }
                        .padding(.vertical, 8)
                        
                        // 3-Полосный эквалайзер
                        HStack(spacing: 20) {
                            EQKnobView(title: "LOW BASS", value: $lowEq, color: .red)
                            EQKnobView(title: "MID", value: $midEq, color: .yellow)
                            EQKnobView(title: "HIGH", value: $highEq, color: .cyan)
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Кроссфейдер (Crossfader)
                        VStack(spacing: 6) {
                            HStack {
                                Text("DECK A")
                                    .font(.caption.bold())
                                    .foregroundColor(.cyan)
                                Spacer()
                                Text("CROSSFADER")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("DECK B")
                                    .font(.caption.bold())
                                    .foregroundColor(.purple)
                            }
                            Slider(value: $crossfader, in: 0.0...1.0)
                                .accentColor(.orange)
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // 8 RGB Performance Pads
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(1...8, id: \.self) { idx in
                                Button(action: {}) {
                                    Text("PAD \(idx)")
                                        .font(.caption2.bold())
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(idx <= 4 ? Color.cyan.opacity(0.25) : Color.purple.opacity(0.25))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                } else {
                    // MARK: - РЕЖИМ «АТМОСФЕРА» (Комната с лазерами и PartyBox)
                    VStack(spacing: 16) {
                        ZStack {
                            // Темная комната с неоновыми лазерными лучами
                            RoundedRectangle(cornerRadius: 24)
                                .fill(LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.02, blue: 0.12)], startPoint: .top, endPoint: .bottom))
                                .frame(height: 320)
                            
                            // Лазерные лучи, прорезающие комнату
                            ForEach(0..<6, id: \.self) { i in
                                Rectangle()
                                    .fill(LinearGradient(colors: [Color.pink.opacity(0.8), Color.clear], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 3, height: 180)
                                    .rotationEffect(.degrees(laserAngle + Double(i * 35)))
                                    .blur(radius: 1)
                            }
                            
                            // Акустическая башня PartyBox в центре
                            VStack(spacing: 8) {
                                // Лазерный стробоскоп на верхушке
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 14, height: 14)
                                    .shadow(color: .pink, radius: 10)
                                
                                // Сдвоенные восьмёркообразные RGB световые кольца
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(white: 0.1))
                                        .frame(width: 110, height: 190)
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3), lineWidth: 2))
                                    
                                    VStack(spacing: 12) {
                                        Circle()
                                            .stroke(Color.pink, lineWidth: 6)
                                            .frame(width: 65, height: 65)
                                            .shadow(color: .pink, radius: isPlaying ? 12 : 2)
                                        
                                        Circle()
                                            .stroke(Color.cyan, lineWidth: 6)
                                            .frame(width: 65, height: 65)
                                            .shadow(color: .cyan, radius: isPlaying ? 12 : 2)
                                    }
                                }
                                
                                Text("VOLTEX PARTY TOWER")
                                    .font(.system(size: 8, weight: .black, design: .monospaced))
                                    .foregroundColor(.pink)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("Светомузыка и лазеры синхронизированы с текущим басовым треком!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.vertical)
        }
        .onReceive(timer) { _ in
            if isPlaying {
                deckARotation += 5.0
                deckBRotation += 4.5
                laserAngle += 2.0
            }
        }
    }
}

struct DJJogWheelView: View {
    let deckName: String
    let trackTitle: String
    let rotation: Double
    let color: Color
    let isSpinning: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(deckName)
                .font(.caption.bold())
                .foregroundColor(color)
            
            ZStack {
                // Внешний обод джога
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 130, height: 130)
                    .overlay(Circle().stroke(color.opacity(0.7), lineWidth: 3))
                
                // Виниловая пластинка с насечками
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 100, height: 100)
                
                // Вращающийся маркер угла пластинки
                Rectangle()
                    .fill(color)
                    .frame(width: 4, height: 35)
                    .offset(y: -35)
                    .rotationEffect(.degrees(rotation))
                
                // Центральный дисплей трека
                Circle()
                    .fill(Color.black)
                    .frame(width: 45, height: 45)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(color)
                    )
            }
            
            Text(trackTitle)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
        }
    }
}

struct EQKnobView: View {
    let title: String
    @Binding var value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.secondary)
            
            Circle()
                .fill(Color(white: 0.18))
                .frame(width: 50, height: 50)
                .overlay(
                    Rectangle()
                        .fill(color)
                        .frame(width: 3, height: 18)
                        .offset(y: -12)
                        .rotationEffect(.degrees((value - 0.5) * 140))
                )
                .overlay(Circle().stroke(color.opacity(0.5), lineWidth: 1.5))
            
            Text("\(Int(value * 100))%")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}
