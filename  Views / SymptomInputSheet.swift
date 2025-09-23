//
//   SymptomInputSheet.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/22/25.
//

import Foundation
import SwiftUI

struct SymptomInputSheet: View {
    let doctor: Doctor
    @Binding var patientSymptom: String
    @Binding var showSheet: Bool
    @Binding var showDoctorInteraction: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("  symptom for \(doctor.name)")
                    .font(.title2).bold()
                    .multilineTextAlignment(.center)
                
                TextField("e.g., Fever, Cough", text: $patientSymptom)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Find Matching Doctor") {
                    showSheet = false
                    showDoctorInteraction = true
                }
                .disabled(patientSymptom.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background(patientSymptom.isEmpty ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Cancel") {
                    showSheet = false
                }
                .padding()
                .foregroundColor(.red)
            }
            .padding()
        }
    }
}
