import SwiftUI

struct SymptomCheckerView: View {
    @StateObject private var viewModel = SymptomCheckerViewModel()
    
    @State private var messages: [Message] = []
    @State private var userInput: String = ""
    @State private var showAlert = false
    @State private var patientName: String = ""
    @State private var askedName: Bool = false
    
    @Binding var searchText: String

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.green.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                        .shadow(radius: 1)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .id(message.id)
                        }
                    }
                }
                .background(Color.green.opacity(0.1).ignoresSafeArea())
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        scrollProxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField(askedName ? "Describe your symptoms..." : "Enter your name...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)

                Button(action: sendUserMessage) {
                    Text("Send")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()

            if viewModel.diagnosisComplete {
                Button("Reset Conversation") {
                    resetConversation()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .foregroundColor(.green)
                .cornerRadius(8)
                .shadow(radius: 1)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Symptom Checker")
        .onAppear { startConversation() }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(viewModel.isHealthy ? "Good News 🎉" : "Attention 🚨"),
                message: Text(viewModel.diagnosisMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func startConversation() {
        messages = []
        messages.append(Message(text: "Hello 👋! Welcome to WaspitoPlus.", isUser: false))
        messages.append(Message(text: "Before we start, may I know your name?", isUser: false))
        askedName = false
        viewModel.resetConversation()
    }

    private func sendUserMessage() {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }

        messages.append(Message(text: trimmedInput, isUser: true))
        userInput = ""

        if !askedName {
            patientName = trimmedInput
            askedName = true
            messages.append(Message(text: "Hello \(patientName) 👋! How are you feeling today? You can describe your symptoms or ask any health-related question.", isUser: false))
            return
        }

         let response = viewModel.processSymptomInput(trimmedInput)
        messages.append(Message(text: response, isUser: false))

        if viewModel.diagnosisComplete {
            showAlert = true
        }
    }

    private func resetConversation() {
        startConversation()
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct SymptomCheckerView_Previews: PreviewProvider {
    static var previews: some View {
         SymptomCheckerView(searchText: .constant("fever"))
    }
}

