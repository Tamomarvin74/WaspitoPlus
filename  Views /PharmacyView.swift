import SwiftUI

struct WaspitoPharmacyView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showPayment = false
    @State private var paymentSuccess = false
    @State private var patientAge = ""
    @State private var dosageAdvice = ""
    @State private var showFollowUp = false
    @State private var enjoyApp = false
    @State private var phoneNumber = ""
    @State private var showDelivery = false

    var body: some View {
        VStack(spacing: 20) {
            Text("👨‍⚕️ Pharmacist")
                .font(.title)
                .bold()
                .foregroundColor(.green)

            // Step 1: Payment
            if !paymentSuccess {
                Text("Hello, \(authVM.userName). Here is your doctor-prescribed medicine.")
                Text("💊 You need to make a payment first before we proceed.")

                Button(action: { showPayment = true }) {
                    Text("Proceed to Payment")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .scaleEffect(showPayment ? 1.1 : 1)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                   value: showPayment)
                }
                .sheet(isPresented: $showPayment) {
                    PaymentView(paymentSuccess: $paymentSuccess)
                        .environmentObject(authVM)
                }
            }

            // Step 2: After payment
            else {
                Text("✅ We saw your payment, \(authVM.userName).")

                VStack {
                    Text("Please enter your age to determine dosage:")
                    TextField("Enter Age", text: $patientAge)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .keyboardType(.numberPad)

                    Button("Get Dosage Advice") {
                        if let age = Int(patientAge) {
                            if age < 12 {
                                dosageAdvice = "Take 1 spoon in the morning & evening."
                            } else if age < 60 {
                                dosageAdvice = "Take 1 tablet morning, afternoon, and evening."
                            } else {
                                dosageAdvice = "Take 1 tablet morning & evening with water."
                            }
                        }
                    }

                    if !dosageAdvice.isEmpty {
                        Text("💊 Dosage: \(dosageAdvice)")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }

                Divider().padding()

                // Step 3: Follow-up question
                if !showFollowUp {
                    Button("Report Difficulty") {
                        showFollowUp = true
                    }
                } else {
                    Text("👨‍⚕️ Pharmacist: I hope you enjoy our app?")
                    HStack {
                        Button("Yes") { enjoyApp = true }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())

                        Button("No") { dismiss() }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }

                // Step 4: Phone number for delivery
                if enjoyApp {
                    VStack {
                        Text("Please enter your phone number for delivery:")
                        TextField("Phone Number", text: $phoneNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .keyboardType(.phonePad)

                        if !phoneNumber.isEmpty {
                            Button(action: { showDelivery = true }) {
                                Text("Submit")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .sheet(isPresented: $showDelivery) {
                                // ✅ Make sure the DeliveryConfirmationView file is added to your target
                                DeliveryConfirmationView(
                                    patientName: authVM.userName,
                                    phoneNumber: phoneNumber
                                )
                                .environmentObject(authVM)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview
struct WaspitoPharmacyView_Previews: PreviewProvider {
    static var previews: some View {
        WaspitoPharmacyView()
            .environmentObject(AuthViewModel())
    }
}

