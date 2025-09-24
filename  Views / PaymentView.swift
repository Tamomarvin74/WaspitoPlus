import SwiftUI

struct PaymentView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var paymentSuccess: Bool
    @State private var selectedMethod = ""
    @State private var accountNumber = ""
    @State private var showError = false

    let banks = ["UBA", "Afriland", "Ecobank", "BICEC", "SCB"]
    let mobileMoney = ["MTN MoMo", "Orange Money"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Payment Method")) {
                    Picker("Bank", selection: $selectedMethod) {
                        ForEach(banks + mobileMoney, id: \.self) { method in
                            Text(method)
                        }
                    }
                }

                Section(header: Text("Enter Account / Number")) {
                    TextField("Account / Phone Number", text: $accountNumber)
                        .keyboardType(.numberPad)
                }

                if showError {
                    Text("❌ Invalid details, please try again.")
                        .foregroundColor(.red)
                }

                Button("Confirm Payment") {
                    if accountNumber.count < 5 {
                        showError = true
                    } else {
                        paymentSuccess = true
                        dismiss()
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            .navigationTitle("💳 Payment")
        }
    }
}

