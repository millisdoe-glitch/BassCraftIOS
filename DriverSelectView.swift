import SwiftUI

struct DriverSelectView: View {
    @Binding var selectedDriver: SubwooferDriver
    @State private var isCustomizing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                
                // MARK: - Текущий выбранный динамик
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedDriver.brand.uppercased())
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                            Text(selectedDriver.name)
                                .font(.title2.bold())
                        }
                        Spacer()
                        Text("\(selectedDriver.sizeInches)\"")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Таблица параметров Т-С
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        SpecCell(title: "Fs (Резонанс)", value: "\(String(format: "%.1f", selectedDriver.fs)) Гц")
                        SpecCell(title: "Qts (Добротность)", value: "\(String(format: "%.2f", selectedDriver.qts))")
                        SpecCell(title: "Vas (Объем)", value: "\(Int(selectedDriver.vas)) Л")
                        SpecCell(title: "Xmax (Ход)", value: "\(String(format: "%.1f", selectedDriver.xmax)) мм")
                        SpecCell(title: "RMS Мощность", value: "\(Int(selectedDriver.rmsPower)) Вт")
                        SpecCell(title: "Катушки", value: selectedDriver.coilType.rawValue)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // MARK: - Список доступных динамиков (Presets)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Каталог сабвуферов:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(SubwooferDriver.presets) { driver in
                        Button(action: {
                            selectedDriver = driver
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(driver.brand)
                                        .font(.caption.bold())
                                        .foregroundColor(.secondary)
                                    Text(driver.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                Text("\(Int(driver.rmsPower)) W")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.cyan)
                                if selectedDriver.id == driver.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct SpecCell: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.04))
        .cornerRadius(8)
    }
}
