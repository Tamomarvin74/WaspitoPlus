import SwiftUI

struct WaspitoPharmacyView: View {
    @State private var patientName: String = "Patient"
    @State private var illness: String = "Flu"
    @State private var patientAge: String = ""
    @State private var dosageAdvice: String = ""
    @State private var selectedMedicines: [Medicine] = []

    @State private var showPayment = false
    @State private var showDosageForm = false
    @State private var difficulty: Bool? = nil
    @State private var showDeliveryAlert = false
    @State private var returnHome = false

    let waspitoGreen = Color("WaspitoGreen")
    let waspitoLight = Color("WaspitoLight")

    let medicines = PharmacyData.medicines

    var totalPrice: Double {
        selectedMedicines.reduce(0) { $0 + $1.price * Double($1.stock) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if returnHome {
                    Text("Redirecting to Home…")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                             VStack(spacing: 10) {
                                Text("💊 Hello, \(patientName)!")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(waspitoGreen)

                                Text("Prescribed medicines for your illness: \(illness)")
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(waspitoLight.opacity(0.3))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)

                             VStack(spacing: 15) {
                                ForEach(medicines) { med in
                                    MedicineCardView(
                                        medicine: med,
                                        isSelected: selectedMedicines.contains(where: { $0.id == med.id })
                                    )
                                    .onTapGesture {
                                        if !selectedMedicines.contains(where: { $0.id == med.id }) {
                                            selectedMedicines.append(med)
                                        } else {
                                            selectedMedicines.removeAll(where: { $0.id == med.id })
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)

                             VStack(spacing: 15) {
                                Text("Total: $\(String(format: "%.2f", totalPrice))")
                                    .font(.title2)
                                    .bold()

                                Button(action: { showPayment = true }) {
                                    Text("Proceed to Payment")
                                        .bold()
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(waspitoGreen)
                                        .foregroundColor(.white)
                                        .cornerRadius(15)
                                        .shadow(color: waspitoGreen.opacity(0.5), radius: 8, x: 0, y: 4)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }

                         if showDosageForm {
                            VStack(spacing: 15) {
                                Text("💊 Dosage Advice")
                                    .font(.title2)
                                    .bold()
                                    .padding(.bottom, 5)

                                Text("Please enter your age to determine the correct dosage:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                TextField("Age", text: $patientAge)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .frame(maxWidth: 150)

                                Button("Get Dosage Advice") {
                                    dosageAdvice = calculateDosage()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(waspitoGreen)
                                .foregroundColor(.white)
                                .cornerRadius(12)

                                if !dosageAdvice.isEmpty {
                                    VStack(spacing: 5) {
                                        Text("Pharmacist advises:")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(dosageAdvice)
                                            .bold()
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.top, 5)
                                }

                                if let diff = difficulty {
                                    if diff {
                                        Text("Pharmacist: We'll follow up with you shortly.")
                                            .font(.subheadline)
                                    } else {
                                        Text("Pharmacist: Thank you for using WaspitoPlus Pharmacy!")
                                            .font(.subheadline)

                                        HStack(spacing: 20) {
                                            Button("Yes") { showDeliveryAlert = true }
                                            Button("No") { returnHome = true }
                                        }
                                    }
                                } else if !dosageAdvice.isEmpty {
                                    HStack(spacing: 20) {
                                        Button("I had difficulty") { difficulty = true }
                                        Button("No problem") { difficulty = false }
                                    }
                                    .padding()
                                }
                            }
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("WaspitoPlus Pharmacy")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPayment, onDismiss: { showDosageForm = true }) {
                PaymentView(onPaymentSuccess: {
                    showPayment = false
                    showDosageForm = true
                })
            }
            .alert(isPresented: $showDeliveryAlert) {
                Alert(
                    title: Text("Delivery Info"),
                    message: Text("Please enter your phone number for delivery."),
                    primaryButton: .default(Text("OK"), action: { returnHome = true }),
                    secondaryButton: .cancel()
                )
            }
            .background(Color.white.ignoresSafeArea())
        }
    }

    private func calculateDosage() -> String {
        guard let age = Int(patientAge) else { return "Invalid age" }
        switch age {
        case 0..<12:
            return "Morning: 1 pill, Afternoon: 1 pill, Evening: 1 pill"
        case 12..<18:
            return "Morning: 1 pill, Afternoon: 1 pill, Evening: 2 pills"
        default:
            return "Morning: 2 pills, Afternoon: 2 pills, Evening: 2 pills"
        }
    }
}

// MARK: - MedicineCardView
struct MedicineCardView: View {
    let medicine: Medicine
    var isSelected: Bool

    var icon: String {
        switch medicine.name.lowercased() {
        case "paracetamol", "ibuprofen", "aspirin": return "pills.fill"
        case "vitamin c": return "capsule.fill"
        case "cough syrup": return "drop.fill"
        default: return "pills"
        }
    }

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color("WaspitoGreen"))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 5) {
                Text(medicine.name)
                    .bold()
                    .foregroundColor(.black)
                Text("Stock: \(medicine.stock)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("$\(String(format: "%.2f", medicine.price * Double(medicine.stock)))")
                .bold()
                .foregroundColor(.black)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color("WaspitoGreen").opacity(0.3) : Color(.systemGray6))
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct WaspitoPharmacyView_Previews: PreviewProvider {
    static var previews: some View {
        WaspitoPharmacyView()
    }
}

