import Foundation
import SwiftUI

@MainActor
final class SymptomCheckerViewModel: ObservableObject {
    
    @Published var patientName: String = ""
    @Published var age: String = ""
    @Published var gender: String = "Male"
    @Published var symptoms: String = ""
    @Published var details: String = ""
    
    @Published var isHealthy: Bool = true
    @Published var diagnosisMessage: String? = nil
    @Published var diagnosisComplete: Bool = false
    
    private let localDataService = LocalDataService.shared
    
    private let symptomDatabase: [String: (diagnosis: String, advice: String)] = [
        "fever": ("Fever / Possible Infection", "Please contact a doctor for proper evaluation."),
        "headache": ("Mild Headache", "You may take acetaminophen or ibuprofen as per your age."),
        "cough": ("Common Cough", "Drink warm fluids and rest. Contact a doctor if persistent."),
        "cold": ("Common Cold", "Rest, hydrate, and consider over-the-counter cold medicine."),
        "stomach ache": ("Stomach Ache", "Drink water, avoid heavy food. Contact doctor if severe.")
    ]
    
     func resetConversation() {
        patientName = ""
        age = ""
        gender = "Male"
        symptoms = ""
        details = ""
        isHealthy = true
        diagnosisMessage = nil
        diagnosisComplete = false
    }
    
    func setPatientName(_ name: String) {
        patientName = name
    }
    
     func processSymptomInput(_ input: String) -> String {
        let lowercasedInput = input.lowercased()
        
        if lowercasedInput.isEmpty {
            return "Can you tell me more about other symptoms or discomforts you feel?"
        }
        
        for (key, value) in symptomDatabase {
            if lowercasedInput.contains(key) {
                diagnosisMessage = value.advice
                isHealthy = key == "headache" || key == "cold"
                diagnosisComplete = true
                
                saveSymptomEntry(
                    symptomDescription: input,
                    diagnosis: value.diagnosis,
                    details: "Matched keyword: \(key)"
                )
                
                return "Based on your symptoms, you may have: \(value.diagnosis). \(value.advice)"
            }
        }
        
        return "Thanks for sharing! Can you tell me more about other symptoms or discomforts you feel?"
    }
    
     private func saveSymptomEntry(symptomDescription: String, diagnosis: String, details: String) {
        let entry = SymptomEntry(
            id: UUID(),
            name: patientName,
            phone: "",
            title: "Symptom Entry - \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))",
            age: age,
            gender: gender,
            symptoms: symptomDescription,
            result: diagnosis,
            details: details,
            date: Date(),
            isSynced: false,
            isHealthy: isHealthy
        )
        localDataService.saveEntry(entry)
    }
}

