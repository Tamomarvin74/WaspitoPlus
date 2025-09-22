//
//   MedicationDeliverySheet.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/22/25.
//

import Foundation
import SwiftUI

struct MedicationDeliverySheet: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Medication Delivery")
                .font(.title2).bold()
            
            Text("Your medication request has been sent to the pharmacy.")
                .multilineTextAlignment(.center)
            
            Button("Close") {
                showSheet = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
