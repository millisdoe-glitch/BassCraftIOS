import Foundation

// MARK: - Типы акустического оформления
enum EnclosureMode: String, CaseIterable, Identifiable {
    case sealed = "Закрытый ящик (ЗЯ)"
    case ported = "Фазоинвертор (ФИ)"
    
    var id: String { rawValue }
}

// MARK: - Результаты симуляции
struct LabSimulationResult {
    let splDb: Double             // Уровень звукового давления (дБ)
    let coneExcursionMm: Double   // Текущий ход диффузора от пика до пика (мм)
    let excursionPercent: Double  // Процент от Xmax (100% = предел)
    let portVelocityMs: Double    // Скорость воздуха в порту (м/с)
    let isClipping: Bool          // Лампа клиппинга
    let isBottomingOut: Bool      // Превышение механического хода (стук катушки)
    let coilTemperatureC: Double  // Температура звуковой катушки (°C)
    let isThermalOverload: Bool   // Риск возгорания/сползания катушки
    let currentImpedanceOhm: Double // Сопротивление на рабочей частоте (Ом)
    let deliveredPowerWatts: Double // Реально отданная мощность (Вт)
}

// MARK: - Физический движок симуляции автозвука
final class PhysicsEngine {
    
    /// Расчет частоты настройки щелевого или круглого порта (Гц)
    static func calculateFb(netVolumeLiters: Double, portAreaCm2: Double, portLengthCm: Double) -> Double {
        guard netVolumeLiters > 0, portAreaCm2 > 0, portLengthCm > 0 else { return 35.0 }
        
        let c = 344.0 // Скорость звука в воздухе (м/с)
        let vM3 = netVolumeLiters / 1000.0
        let sM2 = portAreaCm2 / 10000.0
        let lM = portLengthCm / 100.0
        
        // Виртуальное удлинение порта (end correction)
        let endCorrection = 0.825 * sqrt(sM2)
        let effectiveLength = lM + endCorrection
        
        let fb = (c / (2.0 * .pi)) * sqrt(sM2 / (vM3 * effectiveLength))
        return min(max(fb, 18.0), 80.0)
    }
    
    /// Основная симуляция одного такта лаборатории
    static func runSimulation(
        driver: SubwooferDriver,
        enclosureMode: EnclosureMode,
        boxVolumeLiters: Double,
        portAreaCm2: Double,
        portLengthCm: Double,
        subsonicFilterHz: Double,
        subsonicEnabled: Bool,
        amp: Amplifier,
        isCoilsSeries: Bool,
        gainLevel: Double, // 0.0 ... 1.0 (положение гейна)
        frequencyHz: Double, // 20 ... 90 Гц
        elapsedTimeSeconds: Double // для симуляции нагрева
    ) -> LabSimulationResult {
        
        // 1. Расчет импеданса катушек в покое
        let baseImpedance = driver.coilType.isDual ?
            (isCoilsSeries ? driver.coilType.singleCoilResistance * 2.0 : driver.coilType.singleCoilResistance / 2.0) :
            driver.coilType.singleCoilResistance
        
        // 2. Максимальная мощность моноблока на данном импедансе
        let ampMaxPower = amp.powerAt(impedance: baseImpedance)
        
        // 3. Затребованная мощность (положение регулятора громкости/гейна)
        let requestedPower = ampMaxPower * pow(gainLevel, 2.0)
        
        // Клиппинг наступает, когда гейн превышает 88% при высокой нагрузке
        let clipThreshold = ampMaxPower * 0.92
        let isClipping = requestedPower > clipThreshold
        
        // Фактическая мощность (с учетом насыщения)
        let deliveredPower = min(requestedPower, ampMaxPower * 1.1)
        
        // 4. Расчет акустического отклика и хода в зависимости от оформления
        var acousticGainDb: Double = 0.0
        var excursionMm: Double = 0.0
        var portVelocity: Double = 0.0
        var workingImpedance: Double = baseImpedance
        
        let powerRatio = sqrt(max(1.0, deliveredPower) / max(1.0, driver.rmsPower))
        
        switch enclosureMode {
        case .sealed:
            // ЗЯ: Резонанс в коробе
            let fc = driver.fs * sqrt((driver.vas / boxVolumeLiters) + 1.0)
            let qtc = driver.qts * sqrt((driver.vas / boxVolumeLiters) + 1.0)
            
            // Рост импеданса в пике резонанса
            let resonanceProximity = 1.0 / (1.0 + pow((frequencyHz - fc) / 6.0, 2.0))
            workingImpedance = baseImpedance * (1.0 + resonanceProximity * (qtc * 2.5))
            
            // Спад 12 дБ/октава ниже Fc
            if frequencyHz < fc {
                let octaves = log2(fc / max(10.0, frequencyHz))
                acousticGainDb = -octaves * 12.0
            } else {
                acousticGainDb = min(3.0, (qtc - 0.7) * 3.0)
            }
            
            // В ЗЯ воздух держит диффузор, но ниже резонанса ход растет
            let excursionFactor = pow(fc / max(15.0, frequencyHz), 1.2)
            excursionMm = driver.xmax * 0.55 * powerRatio * excursionFactor
            
        case .ported:
            let fb = calculateFb(netVolumeLiters: boxVolumeLiters, portAreaCm2: portAreaCm2, portLengthCm: portLengthCm)
            
            // Фазоинвертор: двугорбая кривая импеданса вокруг Fb (на Fb импеданс проваливается к минимуму)
            let deltaFb = abs(frequencyHz - fb)
            if deltaFb < 2.5 {
                workingImpedance = baseImpedance * 1.15
            } else {
                workingImpedance = baseImpedance * (1.0 + 2.0 / (1.0 + pow(deltaFb / 8.0, 2.0)))
            }
            
            // Акустический подъем в районе Fb
            let bandWidth = 14.0
            let bell = exp(-pow((frequencyHz - fb) / (bandWidth / 2.0), 2.0))
            acousticGainDb = bell * 5.5
            
            // Поведение хода диффузора:
            // На частоте настройки Fb диффузор РАЗГРУЖАЕТСЯ (почти стоит, играет порт!)
            if abs(frequencyHz - fb) < 3.0 {
                excursionMm = driver.xmax * 0.22 * powerRatio
                // Воздух в порту движется с максимальной скоростью
                portVelocity = (deliveredPower / 100.0) * (300.0 / portAreaCm2) * 12.0
            } else if frequencyHz > fb {
                // Выше настройки ход умеренный
                let freqRatio = frequencyHz / fb
                excursionMm = driver.xmax * 0.6 * powerRatio * (1.0 / sqrt(freqRatio))
                portVelocity = max(0.0, 15.0 - (frequencyHz - fb) * 0.5)
            } else {
                // НИЖЕ настройки порта: диффузор уходит в акустическое короткое замыкание (превышение хода!)
                let belowRatio = fb / max(10.0, frequencyHz)
                var rawExcursion = driver.xmax * 0.7 * powerRatio * pow(belowRatio, 2.2)
                
                // Если включен сабсоник (Subsonic Filter), он срезает опасные инфранизкие частоты
                if subsonicEnabled && frequencyHz < subsonicFilterHz {
                    let subOctaves = log2(subsonicFilterHz / max(10.0, frequencyHz))
                    rawExcursion *= max(0.05, 1.0 - (subOctaves * 0.6))
                    acousticGainDb -= subOctaves * 18.0 // Крутизна фильтра 18-24 дБ/окт
                }
                
                excursionMm = rawExcursion
                let oct = log2(fb / max(10.0, frequencyHz))
                acousticGainDb -= oct * 24.0
            }
        }
        
        // 5. Салонный подъем (Cabin Gain / Transfer Function автомобиля)
        // В седане/хэтчбеке подъем начинается с ~55-60 Гц и дает до +10...+14 дБ на 35 Гц
        let cabinGainDb: Double
        if frequencyHz < 65.0 {
            cabinGainDb = min(14.0, (65.0 - frequencyHz) * 0.35)
        } else {
            cabinGainDb = 0.0
        }
        
        // 6. Итоговый SPL (дБ)
        let powerDb = 10.0 * log10(max(1.0, deliveredPower))
        var totalSpl = driver.sensitivity + powerDb + acousticGainDb + cabinGainDb
        
        // Искажения клиппинга добавляют "грязные" гармоники к давлению
        if isClipping {
            totalSpl += 1.2
        }
        
        // 7. Механический предел (Стук катушки о нижний фланец)
        let isBottomingOut = excursionMm >= driver.xmax * 1.15
        let excursionPercent = (excursionMm / driver.xmax) * 100.0
        
        // 8. Модель термического нагрева катушки
        // Если летит клип и мощность превышает RMS, температура резко растет
        let heatFactor = (deliveredPower / driver.rmsPower) * (isClipping ? 1.8 : 1.0)
        let ambientTemp = 25.0
        let targetTemp = ambientTemp + (heatFactor * 130.0) // При перегрузке до 200+ °C
        let simulatedTemp = min(260.0, ambientTemp + (targetTemp - ambientTemp) * min(1.0, elapsedTimeSeconds / 15.0))
        let isThermalOverload = simulatedTemp > 185.0
        
        return LabSimulationResult(
            splDb: max(50.0, totalSpl),
            coneExcursionMm: excursionMm,
            excursionPercent: excursionPercent,
            portVelocityMs: min(50.0, portVelocity),
            isClipping: isClipping,
            isBottomingOut: isBottomingOut,
            coilTemperatureC: simulatedTemp,
            isThermalOverload: isThermalOverload,
            currentImpedanceOhm: workingImpedance,
            deliveredPowerWatts: deliveredPower
        )
    }
}
