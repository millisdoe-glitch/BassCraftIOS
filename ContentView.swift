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
    
    var body: some View {
        TabView {
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
            
            NavigationStack {
                BoxDesignerView(
                    enclosureMode: $enclosureMode,
                    boxVolume: $boxVolume,
                    portArea: $portArea,
                    portLength: $portLength,
                    driver: $selectedDriver
                )
                .navigationTitle("Расчет короба")
            }
            .tabItem {
                Label("Короб", systemImage: "shippingbox.fill")
            }
            
            NavigationStack {
                WiringView(
                    selectedAmp: $selectedAmp,
                    selectedDriver: $selectedDriver,
                    isCoilsSeries: $isCoilsSeries,
                    subsonicFilter: $subsonicFilter,
                    subsonicEnabled: $subsonicEnabled
                )
                .navigationTitle("Коммутация")
            }
            .tabItem {
                Label("Усилитель", systemImage: "bolt.fill")
            }
            
            NavigationStack {
                DriverSelectView(selectedDriver: $selectedDriver)
                    .navigationTitle("Сабвуфер")
            }
            .tabItem {
                Label("Динамик", systemImage: "speaker.wave.2.fill")
            }
        }
        .accentColor(.orange)
    }
}
