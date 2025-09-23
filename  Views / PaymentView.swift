import SwiftUI

struct PaymentView: View {
    @State private var selectedMethod: String = "UBA"
    @State private var accountNumber: String = ""
    @State private var phoneNumber: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    let paymentMethods = ["UBA", "Afriland", "Ecobank", "BICEC", "SCB", "MTN MoMo", "Orange Money"]
    
    var onPaymentSuccess: () -> Void
    
     let waspitoGreen = Color("WaspitoGreen")
    let waspitoLight = Color("WaspitoLight")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    
                    Text("💰 Payment")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(waspitoGreen)
                    
                     VStack(alignment: .leading, spacing: 10) {
                        Text("Select Payment Method")
                            .bold()
                            .foregroundColor(.gray)
                        
                        Picker("Select Payment Method", selection: $selectedMethod) {
                            ForEach(paymentMethods, id: \.self) { method in
                                HStack {
                                    Image(systemName: "creditcard")
                                    Text(method)
                                }
                                .tag(method)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(waspitoLight)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    
                     VStack(spacing: 15) {
                        if selectedMethod.contains("MoMo") {
                            TextField("Mobile Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(waspitoLight)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                                .overlay(
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(waspitoGreen)
                                            .padding(.leading, 10)
                                        Spacer()
                                    }
                                )
                        } else {
                            TextField("Account Number", text: $accountNumber)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(waspitoLight)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                                .overlay(
                                    HStack {
                                        Image(systemName: "banknote.fill")
                                            .foregroundColor(waspitoGreen)
                                            .padding(.leading, 10)
                                        Spacer()
                                    }
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                     Button(action: {
                        if validatePayment() {
                            onPaymentSuccess()
                        }
                    }) {
                        Text("Pay Now")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(waspitoGreen)
                            .cornerRadius(15)
                            .shadow(color: waspitoGreen.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .scaleEffect(showError ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showError)
                    .padding(.horizontal)
                    
                     if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(), value: showError)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .background(Color.white.ignoresSafeArea())
        }
    }
    
    private func validatePayment() -> Bool {
        if selectedMethod.contains("MoMo") {
            guard !phoneNumber.isEmpty, phoneNumber.count >= 8 else {
                errorMessage = "Please enter a valid mobile number."
                showError = true
                return false
            }
        } else {
            guard !accountNumber.isEmpty, accountNumber.count >= 8 else {
                errorMessage = "Please enter a valid account number."
                showError = true
                return false
            }
        }
        showError = false
        return true
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView {
            print("Payment success triggered")
        }
    }
}

