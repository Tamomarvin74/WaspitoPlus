import SwiftUI
import CoreLocation

struct DoctorProfileDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let doctor: Doctor
    let illness: String
    
    @State private var messages: [(String, Bool)] = []
    @State private var inputText: String = ""
    @State private var consultationStep: Int = 0
    @State private var showPrescriptionOptions: Bool = false
    @State private var prescribedMedications: [String] = []
    @State private var selectedMedications: [String] = []

    private let medicationsByIllness: [String: [String]] = [
        "Fever": ["Paracetamol 500mg", "Ibuprofen 200mg"],
        "Cough": ["Cough Syrup", "Honey & Lemon Tea"],
        "Headache": ["Paracetamol 500mg", "Rest & Hydration"],
        "Skin Rash": ["Topical Ointment", "Antihistamines"]
    ]
    
    var body: some View {
        VStack {
             HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
            
             VStack(spacing: 12) {
                if let avatar = doctor.avatar {
                    Image(uiImage: avatar)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    AsyncImage(url: URL(string: "https://randomuser.me/api/portraits/med/lego/\(abs(doctor.name.hashValue) % 10).jpg")) { phase in
                        if let img = phase.image {
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                        } else {
                            Circle().fill(Color.gray.opacity(0.2))
                                .frame(width: 110, height: 110)
                        }
                    }
                }
                
                Text(doctor.name).font(.title2).bold()
                if let hosp = doctor.hospitalName {
                    Text(hosp).font(.subheadline).foregroundColor(.secondary)
                }
                Text(doctor.specialties.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            .padding(.bottom, 8)
            
            Divider()
            
             ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { idx, msg in
                            HStack {
                                if msg.1 { Spacer() }
                                Text(msg.0)
                                    .padding(10)
                                    .background(msg.1 ? Color.gray.opacity(0.2) : Color.green.opacity(0.9))
                                    .foregroundColor(msg.1 ? .primary : .white)
                                    .cornerRadius(12)
                                if !msg.1 { Spacer() }
                            }
                            .padding(.horizontal)
                            .id(idx)
                        }
                        
                        // MARK: - Prescription Options
                        if showPrescriptionOptions {
                            VStack(spacing: 8) {
                                Text("Doctor's Prescription:").bold()
                                
                                if let meds = medicationsByIllness[illness] {
                                    ForEach(meds, id: \.self) { med in
                                        Button(action: {
                                            if selectedMedications.contains(med) {
                                                selectedMedications.removeAll { $0 == med }
                                            } else {
                                                selectedMedications.append(med)
                                            }
                                        }) {
                                            Text(med)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(selectedMedications.contains(med) ? Color.green : Color.blue)
                                                .cornerRadius(8)
                                        }
                                    }
                                    
                                    if !selectedMedications.isEmpty {
                                        Button(action: confirmMedications) {
                                            Text("Confirm Medications")
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.orange)
                                                .cornerRadius(8)
                                        }
                                        .padding(.top, 5)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .onChange(of: messages.count) { _ in
                        if let last = messages.indices.last {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }
            
             HStack {
                TextField("Message \(doctor.name)...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    sendMessage()
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            startConsultation()
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

         messages.append((text, true))
        inputText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if consultationStep == 4 {
                let patientReply = text.lowercased()
                let agreementKeywords = ["ok", "yes", "sure"]
                
                 
                if agreementKeywords.contains(where: { patientReply.contains($0) }) {
                    showPrescriptionOptions = true
                } else {
                    doctorRespond()
                }
            } else {
                doctorRespond()
            }
        }
    }

    
     private func startConsultation() {
        messages.append(("Hello! I see you selected \(illness). Can you describe your main symptoms?", false))
        consultationStep = 1
    }
    
    private func doctorRespond() {
        switch consultationStep {
        case 1:
            messages.append(("Thanks for sharing. How long have you had these symptoms?", false))
            consultationStep = 2
        case 2:
            messages.append(("Based on what you've told me, you may have \(illness.lowercased()). It's important to visit the hospital for proper tests.", false))
            consultationStep = 3
        case 3:
            messages.append(("In the meantime, I can prescribe some basic medications to help relieve your symptoms. Do you want me to?", false))
            consultationStep = 4
        case 4:
             break
        default:
            messages.append(("Remember to visit \(doctor.hospitalName ?? "the hospital") for a thorough check-up.", false))
        }
    }
    
     private func confirmMedications() {
        for med in selectedMedications {
            messages.append(("Patient acknowledges: \(med)", true))
            prescribedMedications.append(med)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages.append(("Great! \(selectedMedications.joined(separator: ", ")) should help with your symptoms. Take as directed.", false))
        }
        
        selectedMedications.removeAll()
        showPrescriptionOptions = false
    }
}

struct DoctorProfileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DoctorProfileDetailView(
                doctor: Doctor(
                    name: "Dr Test",
                    phone: "555",
                    isOnline: true,
                    hospitalName: "Test Hosp",
                    specialties: ["Fever"],
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    city: "Yaoundé"
                ),
                illness: "Fever"
            )
        }
    }
}

