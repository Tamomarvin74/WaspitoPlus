//
//   DoctorInteractionSheet.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/22/25.
//

import Foundation
import SwiftUI

struct DoctorInteractionSheet: View {
    let doctor: Doctor
    @Binding var showSheet: Bool
    @Binding var showMedicationSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Interact with \(doctor.name)")
                .font(.title2).bold()
            
            Button("Request Medication") {
                showMedicationSheet = true
                showSheet = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Close") {
                showSheet = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .padding()
    }
}
