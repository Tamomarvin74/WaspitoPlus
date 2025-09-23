//
//   PharmacyFlowView.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/23/25.
//

import Foundation
import SwiftUI

struct PharmacyFlowView: View {
    @State private var step: Int = 0
    @State private var patientName: String = "Patient"
    @State private var illness: String = "Flu"
    @State private var age: Int? = nil
    @State private var dosage: String = ""
    @State private var paymentCompleted = false
    @State private var difficultyReported = false
    @State private var phoneNumber: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                switch step {
                case 0:
                    PharmacyView(step: $step, patientName: patientName, illness: illness)
                case 1:
                    PharmacyPaymentView { success in
                        if success { step = 2 }
                    }
                case 2:
                    DosageView(step: $step, age: $age, dosage: $dosage, patientName: patientName)
                case 3:
                    FollowUpView(step: $step, difficultyReported: $difficultyReported)
                case 4:
                    DeliveryView(step: $step, phoneNumber: $phoneNumber)
                case 5:
                    HomeRedirectView()
                default:
                    HomeRedirectView()
                }
            }
            .animation(.easeInOut, value: step)
            .padding()
        }
    }
}

// MARK: - HomeRedirectView
struct HomeRedirectView: View {
    @State private var redirect = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Thank you for using our Pharmacy Service ❤️")
                .font(.headline)
            Text("Redirecting you back to Home...")
                .foregroundColor(.gray)
            
            NavigationLink(destination: HomeView(), isActive: $redirect) { EmptyView() }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                redirect = true
            }
        }
    }
}
