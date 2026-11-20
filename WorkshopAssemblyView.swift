import SwiftUI

struct WorkshopAssemblyView: View {
    @Binding var boxVolume: Double
    @Binding var portArea: Double
    @Binding var portLength: Double
    @Binding var selectedDriver: SubwooferDriver
    
    @State private var currentStep: AssemblyStep = .cutting
    @State private var material = "Фанера 21 мм (Берёза)"
    @State private var finish = "Автомобильный чёрный карпет"
    @State private var assemblyProgress: Double = 0.2
    
    let materials = ["Фанера 21 мм (Берёза)", "МДФ плита 22 мм", "Карбоновый композит"]
    let finishes = ["Автомобильный чёрный карпет", "Чёрный рояльный лак", "Натуральное шлифованное дерево"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Текущий статус сборки в мастерской
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundColor(.orange)
                        Text("МАСТЕРСКАЯ · СБОРКА КОРОБА")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("ШАГ \(currentStep.rawValue)/5")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                    }
                    
                    ProgressView(value: Double(currentStep.rawValue), total: 5.0)
                        .accentColor(.orange)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // MARK: - Интерактивная 3D/2D сцена этапа
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient(colors: [Color(white: 0.12), Color(white: 0.05)], startPoint: .top, endPoint: .bottom))
                            .frame(height: 220)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
                            )
                        
                        VStack(spacing: 12) {
                            switch currentStep {
                            case .cutting:
                                Image(systemName: "ruler.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.orange)
                                Text("Раскрой листов фанеры")
                                    .font(.headline.bold())
                                Text("Точность распила: ±0.5 мм по чертежу на \(Int(boxVolume)) Л")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                            case .gluing:
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.yellow)
                                Text("Склейка Titebond II")
                                    .font(.headline.bold())
                                Text("Двойная промазка швов для исключения утечек воздуха")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                            case .screws:
                                Image(systemName: "screwdriver.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.cyan)
                                Text("Стяжка саморезами 45мм")
                                    .font(.headline.bold())
                                Text("Шаг 5 см по всему периметру для максимальной жёсткости")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                            case .sealing:
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.purple)
                                Text("Полиуретановый герметик")
                                    .font(.headline.bold())
                                Text("Герметизация внутреннего объёма и щелевого порта")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                            case .driverMount:
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.green)
                                Text("Монтаж \(selectedDriver.name)")
                                    .font(.headline.bold())
                                Text("Установка виброизоляции, прикручивание корзины винтами под шестигранник")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Описание текущего шага
                    Text(currentStep.description)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Кнопки навигации по шагам
                    HStack(spacing: 16) {
                        Button(action: prevStep) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Назад")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.25))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(currentStep == .cutting)
                        
                        Button(action: nextStep) {
                            HStack {
                                Text(currentStep == .driverMount ? "Готово к тесту!" : "Следующий шаг")
                                Image(systemName: currentStep == .driverMount ? "checkmark" : "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Материал и отделка
                VStack(alignment: .leading, spacing: 14) {
                    Text("Материалы корпуса:")
                        .font(.headline)
                    
                    Picker("Материал", selection: $material) {
                        ForEach(materials, id: \.self) { m in
                            Text(m).tag(m)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Отделка", selection: $finish) {
                        ForEach(finishes, id: \.self) { f in
                            Text(f).tag(f)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(18)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private func nextStep() {
        if let next = AssemblyStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
    
    private func prevStep() {
        if let prev = AssemblyStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }
}
