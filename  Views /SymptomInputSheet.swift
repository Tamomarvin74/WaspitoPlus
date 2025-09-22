//
//  SymptomInputSheet.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/22/25.
//

 import SwiftUI

import SwiftUI

struct SymptomInputSheet: View {
    let doctor: Doctor
    @Binding var patientSymptom: String
    @Binding var showSheet: Bool
    @Binding var showDoctorInteraction: Bool
    
    var body: some View {
        VStack {
            Text("Enter symptom for \(doctor.name)")
            TextField("Symptom", text: $patientSymptom)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Next") {
                showSheet = false
                showDoctorInteraction = true
            }
            .padding()
        }
        .padding()
    }
}

