import SwiftUI

struct ContentView: View {
    @State private var selectedDriver: SubwooferDriver = SubwooferDriver.presets[0]
    @State private var selectedAmp: Amplifier = Amplifier.presets[1]
    @State private var enclosureMode: EnclosureMode = .ported
    @State private var boxVolume: Double = 65.0
    @State private var portArea: Double = 220.0
    @State private var portLength: Double = 52.0
    @State private var isCoilsSeries: Bool = false
    @State private var subsonicFilter: Double = 28.0
    @State private var subsonicEnabled: Bool = true
    
    // Глобальные состояния воспроизведения для синхронизации вкладок
    @State private var isPlaying: Bool = false
    @State private var splDb: Double = 142.4
    @State private var isClipping: Bool = false
    @State private var currentFrequency: Double = 35.0
    
    var body: some View {
        TabView {
            // Вкладка 1: Лаборатория (SPL Lab)
            NavigationStack {
                LabView(
                    selectedDriver: $selectedDriver,
                    selectedAmp: $selectedAmp,
                    enclosureMode: $enclosureMode,
                    boxVolume: $boxVolume,
                    portArea: $portArea,
                    portLength: $portLength,
                    isCoilsSeries: $isCoilsSeries,
                    subsonicFilter: $subsonicFilter,
                    subsonicEnabled: $subsonicEnabled
                )
                .navigationTitle("BassCraft Lab")
            }
            .tabItem {
                Label("Лаборатория", systemImage: "waveform.path.ecg")
            }
            
            // Вкладка 2: Автозвук в багажнике (Trunk View & VOLTEX)
            NavigationStack {
                CarTrunkView(
                    selectedDriver: $selectedDriver,
                    selectedAmp: $selectedAmp,
                    boxVolume: $boxVolume,
                    isPlaying: $isPlaying,
                    splDb: $splDb,
                    isClipping: $isClipping
                )
                .navigationTitle("Автозвук")
            }
            .tabItem {
                Label("Багажник", systemImage: "car.rear.fill")
            }
            
            // Вкладка 3: Мастерская сборки (Workshop & Steps)
            NavigationStack {
                WorkshopAssemblyView(
                    boxVolume: $boxVolume,
                    portArea: $portArea,
                    portLength: $portLength,
                    selectedDriver: $selectedDriver
                )
                .navigationTitle("Мастерская")
            }
            .tabItem {
                Label("Сборка", systemImage: "wrench.and.screwdriver.fill")
            }
            
            // Вкладка 4: DJ-Пульт & Атмосфера
            NavigationStack {
                DJConsoleView(
                    isPlaying: $isPlaying,
                    currentFrequency: $currentFrequency
                )
                .navigationTitle("DJ & Атмосфера")
            }
            .tabItem {
                Label("DJ-Пульт", systemImage: "opticaldisc.fill")
            }
            
            // Вкладка 5: Карьера и Заказы (Career)
            NavigationStack {
                CareerView()
                    .navigationTitle("Карьера")
            }
            .tabItem {
                Label("Карьера", systemImage: "trophy.fill")
            }
        }
        .accentColor(.cyan)
        .preferredColorScheme(.dark) // Полная тёмная тема в стиле игры!
    }
}
