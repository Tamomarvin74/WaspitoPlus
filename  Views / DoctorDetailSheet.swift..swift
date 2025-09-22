//
//   DoctorDetailSheet.swift..swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/22/25.
//

import Foundation
import SwiftUI

struct DoctorDetailSheetView: View {
    let doctor: Doctor
    @State private var askAvailability = false
    @State private var patientPhone: String = ""
    @State private var sendPhone = false
    @EnvironmentObject var doctorManager: DoctorManager

    var body: some View {
        VStack(spacing: 20) {
            if let avatar = doctor.avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }

            Text(doctor.name).font(.title2).bold()
            Text("Hospital: \(doctor.hospitalName ?? "Unknown")").foregroundColor(.secondary)

            if !askAvailability {
                Button("Ask if available") {
                    askAvailability = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else if !sendPhone {
                Text("Doctor is available now ✅")
                TextField("Enter your phone number", text: $patientPhone)
                    .keyboardType(.phonePad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Send Number for Call") {
                    doctorManager.sendPatientRequest(to: doctor, patientPhone: patientPhone, message: nil)
                    sendPhone = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(patientPhone.isEmpty)
            } else {
                Text("☎️ Your number has been sent. Wait for the doctor to call you shortly.")
                    .foregroundColor(.green)
            }

            Button("Try to Call") {
                showCallAlert()
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
    }

    func showCallAlert() {
        let alert = UIAlertController(
            title: "Please Wait",
            message: "The doctor will call you shortly. Do not call directly.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}
