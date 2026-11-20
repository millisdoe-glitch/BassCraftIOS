import SwiftUI

struct WiringView: View {
    @Binding var selectedAmp: Amplifier
    @Binding var selectedDriver: SubwooferDriver
    @Binding var isCoilsSeries: Bool
    @Binding var subsonicFilter: Double
    @Binding var subsonicEnabled: Bool
    
    var calculatedImpedance: Double {
        if selectedDriver.coilType.isDual {
            return isCoilsSeries ?
                (selectedDriver.coilType.singleCoilResistance * 2.0) :
                (selectedDriver.coilType.singleCoilResistance / 2.0)
        } else {
            return selectedDriver.coilType.singleCoilResistance
        }
    }
    
    var powerOutput: Double {
        selectedAmp.powerAt(impedance: calculatedImpedance)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Выбор усилителя
                VStack(alignment: .leading, spacing: 10) {
                    Text("Усилитель (Моноблок):")
                        .font(.headline)
                    
                    Picker("Моноблок", selection: $selectedAmp.name) {
                        ForEach(Amplifier.presets, id: \.name) { amp in
                            Text(amp.name).tag(amp.name)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedAmp.name) { newName in
                        if let found = Amplifier.presets.first(where: { $0.name == newName }) {
                            selectedAmp = found
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Итоговый импеданс:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f Ом", calculatedImpedance))
                                .font(.title2.bold())
                                .foregroundColor(.green)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Отдаваемая мощность:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(powerOutput)) Вт RMS")
                                .font(.title2.bold())
                                .foregroundColor(.cyan)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(18)
                .padding(.horizontal)
                
                // MARK: - Коммутация катушек сабвуфера
                if selectedDriver.coilType.isDual {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Схема подключения катушек:")
                            .font(.headline)
                        
                        Picker("Подключение", selection: $isCoilsSeries) {
                            Text("Параллельное (\(String(format: "%.1f", selectedDriver.coilType.singleCoilResistance / 2.0)) Ом)").tag(false)
                            Text("Последовательное (\(String(format: "%.1f", selectedDriver.coilType.singleCoilResistance * 2.0)) Ом)").tag(true)
                        }
                        .pickerStyle(.segmented)
                        
                        // Схематичная визуализация
                        HStack(spacing: 20) {
                            VStack {
                                Text("Катушка 1")
                                    .font(.caption2.bold())
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: 80, height: 45)
                                    .overlay(Text("\(Int(selectedDriver.coilType.singleCoilResistance)) Ом").font(.caption.bold()))
                            }
                            
                            Image(systemName: isCoilsSeries ? "arrow.right" : "equal")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            VStack {
                                Text("Катушка 2")
                                    .font(.caption2.bold())
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: 80, height: 45)
                                    .overlay(Text("\(Int(selectedDriver.coilType.singleCoilResistance)) Ом").font(.caption.bold()))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(18)
                    .padding(.horizontal)
                }
                
                // MARK: - Сабсоник фильтр (Subsonic / HPF)
                VStack(alignment: .leading, spacing: 14) {
                    Toggle(isOn: $subsonicEnabled) {
                        VStack(alignment: .leading) {
                            Text("Сабсоник фильтр (HPF)")
                                .font(.headline)
                            Text("Защищает диффузор от разрыва ниже частоты настройки")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if subsonicEnabled {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Частота среза:")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(subsonicFilter)) Гц")
                                    .font(.headline.bold())
                                    .foregroundColor(.blue)
                            }
                            Slider(value: $subsonicFilter, in: 20...45, step: 1)
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
