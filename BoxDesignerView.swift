import SwiftUI

struct BoxDesignerView: View {
    @Binding var enclosureMode: EnclosureMode
    @Binding var boxVolume: Double
    @Binding var portArea: Double
    @Binding var portLength: Double
    @Binding var driver: SubwooferDriver
    
    var fb: Double {
        PhysicsEngine.calculateFb(
            netVolumeLiters: boxVolume,
            portAreaCm2: portArea,
            portLengthCm: portLength
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Переключатель типа короба
                Picker("Тип оформления", selection: $enclosureMode) {
                    ForEach(EnclosureMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // MARK: - Превью короба
                VStack(spacing: 8) {
                    ZStack {
                        // Контур короба
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.7), lineWidth: 4)
                            .frame(width: 240, height: 160)
                            .background(Color.brown.opacity(0.15))
                        
                        // Отверстие под динамик
                        Circle()
                            .stroke(Color.primary, lineWidth: 3)
                            .frame(width: 90, height: 90)
                            .offset(x: enclosureMode == .ported ? -40 : 0)
                        
                        // Порт (если ФИ)
                        if enclosureMode == .ported {
                            VStack(spacing: 0) {
                                Rectangle()
                                    .fill(Color.cyan.opacity(0.3))
                                    .frame(width: 32, height: 140)
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.cyan, lineWidth: 2)
                                    )
                            }
                            .offset(x: 85)
                        }
                    }
                    .frame(height: 190)
                    
                    if enclosureMode == .ported {
                        HStack {
                            Image(systemName: "tuningfork")
                                .foregroundColor(.cyan)
                            Text("Настройка порта (Fb):")
                                .font(.headline)
                            Text(String(format: "%.1f Гц", fb))
                                .font(.headline.bold())
                                .foregroundColor(.cyan)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // MARK: - Регулировка параметров короба
                VStack(spacing: 18) {
                    
                    // Чистый объем
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Чистый объем (Vb):")
                                .font(.subheadline.bold())
                            Spacer()
                            Text("\(Int(boxVolume)) Л")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        Slider(value: $boxVolume, in: 25...160, step: 1)
                            .accentColor(.orange)
                    }
                    
                    if enclosureMode == .ported {
                        // Площадь порта
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Площадь сечения порта:")
                                    .font(.subheadline.bold())
                                Spacer()
                                Text("\(Int(portArea)) см²")
                                    .font(.headline)
                                    .foregroundColor(.cyan)
                            }
                            Slider(value: $portArea, in: 80...450, step: 10)
                                .accentColor(.cyan)
                            Text("Рекомендуется: ~180-260 см² для 12\" динамика")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Длина порта
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Длина порта (Lp):")
                                    .font(.subheadline.bold())
                                Spacer()
                                Text("\(Int(portLength)) см")
                                    .font(.headline)
                                    .foregroundColor(.cyan)
                            }
                            Slider(value: $portLength, in: 25...95, step: 1)
                                .accentColor(.cyan)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // MARK: - Советы по расчёту
                VStack(alignment: .leading, spacing: 8) {
                    Label("Рекомендации мастера", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    if enclosureMode == .ported {
                        Text("• Настройка 30–33 Гц — для глубоких ветреных «негров» (низов).\n• Настройка 36–39 Гц — для быстрого клубного баса и рока.\n• Держите скорость воздуха в порту до 22 м/с во избежание струйных шумов и свиста.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("• Закрытый ящик обеспечивает ровную АЧХ, музыкальность и максимальный контроль хода диффузора, но проигрывает 3-4 дБ по пиковому давлению.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}
