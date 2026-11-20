import SwiftUI

struct CareerView: View {
    @State private var playerCash = 45000
    @State private var playerRank = "Лига: ДВОР"
    @State private var orders = ClientOrder.sampleOrders
    @State private var completedAlert = false
    @State private var lastCompletedReward = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Карточка статуса игрока (Баланс и Лига)
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("БАЛАНС МАСТЕРСКОЙ")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("\(playerCash) ₽")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("ТЕКУЩИЙ ТУРНИР")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(playerRank)
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // MARK: - Список заказов клиентов
                VStack(alignment: .leading, spacing: 14) {
                    Text("Заказы клиентов:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(orders.indices, id: \.self) { idx in
                        let order = orders[idx]
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(order.clientName)
                                        .font(.headline.bold())
                                    Text(order.carModel)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("+\(order.rewardMoney) ₽")
                                    .font(.headline.bold())
                                    .foregroundColor(.green)
                            }
                            
                            Text(order.description)
                                .font(.footnote)
                                .foregroundColor(.primary.opacity(0.85))
                            
                            HStack {
                                Label("Настройка: \(Int(order.targetFb)) Гц", systemImage: "waveform")
                                    .font(.caption.bold())
                                    .foregroundColor(.cyan)
                                Spacer()
                                Label("Цель: > \(String(format: "%.1f", order.targetSpl)) дБ", systemImage: "gauge.with.needle.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                            }
                            
                            Button(action: {
                                completeOrder(index: idx)
                            }) {
                                HStack {
                                    Image(systemName: order.isCompleted ? "checkmark.circle.fill" : "hammer.fill")
                                    Text(order.isCompleted ? "ВЫПОЛНЕНО" : "ВЗЯТЬ В РАБОТУ И СДАТЬ")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(order.isCompleted ? Color.gray.opacity(0.3) : Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(order.isCompleted)
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .alert("Заказ сдан!", isPresented: $completedAlert) {
            Button("Отлично", role: .cancel) { }
        } message: {
            Text("Клиент остался доволен басом! На ваш баланс начислено +\(lastCompletedReward) ₽.")
        }
    }
    
    private func completeOrder(index: Int) {
        orders[index].isCompleted = true
        let reward = orders[index].rewardMoney
        playerCash += reward
        lastCompletedReward = reward
        completedAlert = true
        
        let completedCount = orders.filter({ $0.isCompleted }).count
        if completedCount >= 2 {
            playerRank = "Лига: ГОРОД"
        }
    }
}
