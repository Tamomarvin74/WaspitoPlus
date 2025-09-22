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
    @State private var awaitingAgreement: Bool = false
    
    private let medicationsByIllness: [String: [String]] = [
        "Fever": ["Paracetamol 500mg (every 6–8 hours)", "Ibuprofen 200mg (after meals)", "Adequate Rest & Hydration"],
        "Cough": ["Cough Syrup (Dextromethorphan)", "Honey & Lemon Tea", "Steam Inhalation"],
        "Headache": ["Paracetamol 500mg", "Ibuprofen 400mg", "Rest in Quiet/Dark Room"],
        "Skin Rash": ["Topical Hydrocortisone Cream", "Antihistamines (Cetirizine)", "Keep Skin Moisturized"],
        "Malaria": ["Artemisinin-based Combination Therapy (ACT)", "Paracetamol for fever", "Adequate Hydration"],
        "Typhoid": ["Ciprofloxacin 500mg (as prescribed)", "Amoxicillin", "ORS Solution for Rehydration"],
        "Diabetes": ["Metformin 500mg", "Glipizide (oral)", "Low-sugar Diet & Exercise"],
        "Hypertension": ["Amlodipine 5mg", "Losartan 50mg", "Low-salt Diet"],
        "Asthma": ["Salbutamol Inhaler", "Steroid Inhaler (Budesonide)", "Avoid Triggers"],
        "Flu": ["Paracetamol", "Vitamin C Supplements", "Rest & Warm Fluids"],
        "Cold": ["Decongestant (Pseudoephedrine)", "Warm Fluids", "Vitamin C Lozenges"],
        "Stomach Ache": ["Antacids", "Omeprazole 20mg", "Plenty of Water"],
        "Diarrhea": ["ORS Solution", "Metronidazole (if bacterial)", "Probiotics"],
        "Constipation": ["Laxatives (Lactulose)", "High-fiber Diet", "Adequate Water Intake"],
        "Allergies": ["Antihistamines (Loratadine)", "Nasal Spray", "Avoid Allergens"],
        "COVID-19": ["Paracetamol for Fever", "Zinc Supplements", "Rest & Isolation"],
        "Depression": ["SSRIs (Fluoxetine)", "Therapy Sessions", "Exercise & Social Support"],
        "Anxiety": ["Benzodiazepines (as prescribed)", "Cognitive Behavioral Therapy (CBT)", "Relaxation Techniques"],
        "Insomnia": ["Melatonin Supplements", "Sleep Hygiene", "Avoid Caffeine at Night"]
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
                } else if let imageURL = doctor.imageURL {
                     AsyncImage(url: imageURL) { phase in
                        if let img = phase.image {
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                        } else if phase.error != nil {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 110, height: 110)
                                .overlay(Text("No Image").font(.caption))
                        } else {
                            ProgressView()
                                .frame(width: 110, height: 110)
                        }
                    }
                } else {
                     Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 110, height: 110)
                        .overlay(Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40)))
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
                                } else {
                                    Text("No prescriptions available for \(illness).")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
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
             if consultationStep == 4 || awaitingAgreement {
                let patientReply = text.lowercased()
 
                let tokens = patientReply
                    .components(separatedBy: CharacterSet.alphanumerics.inverted)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                let agreementKeywords: Set<String> = ["ok", "yes", "sure", "yeah", "yep", "y", "okay", "okey"]

                if tokens.contains(where: { agreementKeywords.contains($0) }) {
 
                    awaitingAgreement = false
                    showPrescriptionOptions = true
                } else {

                    awaitingAgreement = false
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
        awaitingAgreement = false
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
            awaitingAgreement = true
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
                    hospitalName: "Test Hosp",
                    city: "Yaoundé",
                    specialties: ["Fever"],   
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    isOnline: true
                )


,
                illness: "Fever"
            )
        }
    }
}

