import Foundation

// MARK: - Конфигурация катушек
enum CoilType: String, CaseIterable, Identifiable {
    case d1 = "D1 (1+1 Ом)"
    case d2 = "D2 (2+2 Ом)"
    case d4 = "D4 (4+4 Ом)"
    case s4 = "S4 (4 Ом)"
    
    var id: String { rawValue }
    
    var singleCoilResistance: Double {
        switch self {
        case .d1: return 1.0
        case .d2: return 2.0
        case .d4: return 4.0
        case .s4: return 4.0
        }
    }
    
    var isDual: Bool {
        return self != .s4
    }
}

// MARK: - Модель сабвуферного динамика
struct SubwooferDriver: Identifiable, Equatable {
    let id: UUID
    var name: String
    var brand: String
    var sizeInches: Int
    var fs: Double          // Резонансная частота (Гц)
    var qts: Double         // Полная добротность
    var vas: Double         // Эквивалентный объем (Л)
    var xmax: Double        // Линейный ход диффузора в одну сторону (мм)
    var rmsPower: Double    // Номинальная мощность (Вт)
    var sensitivity: Double // Чувствительность (дБ @ 1Вт/1м)
    var coilType: CoilType
    
    init(id: UUID = UUID(), name: String, brand: String, sizeInches: Int, fs: Double, qts: Double, vas: Double, xmax: Double, rmsPower: Double, sensitivity: Double, coilType: CoilType) {
        self.id = id
        self.name = name
        self.brand = brand
        self.sizeInches = sizeInches
        self.fs = fs
        self.qts = qts
        self.vas = vas
        self.xmax = xmax
        self.rmsPower = rmsPower
        self.sensitivity = sensitivity
        self.coilType = coilType
    }
    
    // Предустановленные популярные динамики для автозвука
    static let presets: [SubwooferDriver] = [
        SubwooferDriver(
            name: "Bb.3 12\"",
            brand: "Pride",
            sizeInches: 12,
            fs: 32.0,
            qts: 0.38,
            vas: 42.0,
            xmax: 22.0,
            rmsPower: 1250.0,
            sensitivity: 86.8,
            coilType: .d2
        ),
        SubwooferDriver(
            name: "Apocalypse DB-SA272 12\"",
            brand: "Deaf Bonce",
            sizeInches: 12,
            fs: 34.2,
            qts: 0.42,
            vas: 36.0,
            xmax: 28.0,
            rmsPower: 1700.0,
            sensitivity: 86.2,
            coilType: .d2
        ),
        SubwooferDriver(
            name: "SA-12 v.2 D2",
            brand: "Sundown Audio",
            sizeInches: 12,
            fs: 33.7,
            qts: 0.44,
            vas: 28.4,
            xmax: 19.0,
            rmsPower: 1000.0,
            sensitivity: 84.5,
            coilType: .d2
        ),
        SubwooferDriver(
            name: "Machete Fight S 12\"",
            brand: "Deaf Bonce",
            sizeInches: 12,
            fs: 36.0,
            qts: 0.49,
            vas: 48.0,
            xmax: 15.0,
            rmsPower: 800.0,
            sensitivity: 87.5,
            coilType: .d2
        ),
        SubwooferDriver(
            name: "CompC 12\"",
            brand: "Kicker",
            sizeInches: 12,
            fs: 30.0,
            qts: 0.53,
            vas: 95.0,
            xmax: 10.3,
            rmsPower: 300.0,
            sensitivity: 88.3,
            coilType: .d4
        ),
        SubwooferDriver(
            name: "T15 v.3 15\"",
            brand: "Pride",
            sizeInches: 15,
            fs: 28.0,
            qts: 0.33,
            vas: 80.0,
            xmax: 26.0,
            rmsPower: 2500.0,
            sensitivity: 88.5,
            coilType: .d1
        )
    ]
}

// MARK: - Модель моноблока (Усилителя)
struct Amplifier: Identifiable {
    let id = UUID()
    let name: String
    let ratedPower1Ohm: Double // Вт в 1 Ом
    let ratedPower2Ohm: Double // Вт в 2 Ом
    let ratedPower4Ohm: Double // Вт в 4 Ом
    
    func powerAt(impedance: Double) -> Double {
        if impedance <= 1.1 {
            return ratedPower1Ohm
        } else if impedance <= 2.2 {
            return ratedPower2Ohm
        } else {
            return ratedPower4Ohm
        }
    }
    
    static let presets: [Amplifier] = [
        Amplifier(name: "Monoblock 800W", ratedPower1Ohm: 800, ratedPower2Ohm: 500, ratedPower4Ohm: 300),
        Amplifier(name: "Monoblock 1500W", ratedPower1Ohm: 1500, ratedPower2Ohm: 950, ratedPower4Ohm: 600),
        Amplifier(name: "Monoblock 2500W", ratedPower1Ohm: 2500, ratedPower2Ohm: 1600, ratedPower4Ohm: 1000),
        Amplifier(name: "Monoblock 4000W SPL", ratedPower1Ohm: 4000, ratedPower2Ohm: 2600, ratedPower4Ohm: 1600)
    ]
}
