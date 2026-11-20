import Foundation

// MARK: - Аккумулятор автомобиля
enum BatteryType: String, CaseIterable, Identifiable {
    case acid = "Кислота (60 Ач) - 12.4V"
    case agm = "AGM Stinger (100 Ач) - 12.8V"
    case titanate = "LTO Титанат (30 Ач) - 14.8V"
    
    var id: String { rawValue }
    
    var nominalVoltage: Double {
        switch self {
        case .acid: return 12.4
        case .agm: return 12.8
        case .titanate: return 14.8
        }
    }
    
    var internalResistance: Double {
        switch self {
        case .acid: return 0.025
        case .agm: return 0.008
        case .titanate: return 0.0015
        }
    }
}

// MARK: - Силовой кабель
enum WireGauge: String, CaseIterable, Identifiable {
    case gauge8 = "8 Ga (Медь 10 мм²)"
    case gauge4 = "4 Ga (Медь 25 мм²)"
    case gauge0 = "0 Ga / КГ-50 (50 мм²)"
    case gauge00 = "00 Ga / Pride 70 мм²"
    
    var id: String { rawValue }
    
    var resistancePerMeter: Double {
        switch self {
        case .gauge8: return 0.0035
        case .gauge4: return 0.0014
        case .gauge0: return 0.0007
        case .gauge00: return 0.00035
        }
    }
}

// MARK: - Заказ клиента в Карьере
struct ClientOrder: Identifiable, Equatable {
    let id: UUID = UUID()
    let clientName: String
    let carModel: String
    let targetFb: Double
    let targetSpl: Double
    let rewardMoney: Int
    let description: String
    var isCompleted: Bool = false
    
    static let sampleOrders: [ClientOrder] = [
        ClientOrder(
            clientName: "Алексей",
            carModel: "Lada Priora Хэтчбек",
            targetFb: 34.0,
            targetSpl: 142.5,
            rewardMoney: 18000,
            description: "Хочу бодрый повседнев на Pride Bb.3, чтобы валило негров на 33-35 Гц и не воняло."
        ),
        ClientOrder(
            clientName: "Дмитрий",
            carModel: "Toyota Mark II",
            targetFb: 38.0,
            targetSpl: 144.0,
            rewardMoney: 26000,
            description: "Собери плотный ФИ под клубный бас и быстрый рок на Deaf Bonce DB-SA272."
        ),
        ClientOrder(
            clientName: "Артем",
            carModel: "Subaru Impreza WRX",
            targetFb: 32.0,
            targetSpl: 147.0,
            rewardMoney: 45000,
            description: "Нужен соревновательный короб на титанате и моноблоке 3500.1 под лигу 'Город'!"
        )
    ]
}

// MARK: - Шаги сборки короба в Мастерской
enum AssemblyStep: Int, CaseIterable, Identifiable {
    case cutting = 1
    case gluing = 2
    case screws = 3
    case sealing = 4
    case driverMount = 5
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .cutting: return "1. Раскрой и распил"
        case .gluing: return "2. Склейка стенок"
        case .screws: return "3. Закрутка саморезов"
        case .sealing: return "4. Герметизация швов"
        case .driverMount: return "5. Посадка динамика"
        }
    }
    
    var description: String {
        switch self {
        case .cutting: return "Распил листов фанеры 21мм по чертежу на циркулярном станке."
        case .gluing: return "Нанесение столярного клея Titebond II на стыки стенок."
        case .screws: return "Фиксация стенок черными саморезами с шагом 5 см."
        case .sealing: return "Промазка всех внутренних углов полиуретановым герметиком."
        case .driverMount: return "Прокладка уплотнителя, установка терминалов и затяжка винтов корзины."
        }
    }
}
