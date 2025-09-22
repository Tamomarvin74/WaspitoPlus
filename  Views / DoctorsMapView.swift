//
//   DoctorsMapView.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/22/25.
//

 
import SwiftUI
import MapKit

struct DoctorsMapView: View {
    @EnvironmentObject var doctorManager: DoctorManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 3.848, longitude: 11.5021), 
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
    )
    @State private var selectedDoctor: Doctor? = nil
    @State private var showingDoctorSheet = false

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: doctorManager.onlineDoctors) { doctor in
                MapAnnotation(coordinate: doctor.coordinate) {
                    DoctorMapAnnotation(doctor: doctor)
                        .onTapGesture {
                            selectedDoctor = doctor
                            showingDoctorSheet = true
                        }
                }
            }
            .ignoresSafeArea()
        }
        .sheet(item: $selectedDoctor) { doc in
            DoctorDetailSheet(doctor: doc)
        }
    }
}


struct DoctorMapAnnotation: View {
    let doctor: Doctor
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green.opacity(0.6), lineWidth: 2)
                .frame(width: 60, height: 60)
                .scaleEffect(animate ? 1.4 : 1)
                .opacity(animate ? 0 : 0.6)
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                        animate = true
                    }
                }

            if let avatar = doctor.avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.green, lineWidth: 2))
            } else {
                Circle()
                    .fill(Color.green)
                    .frame(width: 40, height: 40)
                    .overlay(Text(String(doctor.name.prefix(1))).foregroundColor(.white))
            }
        }
    }
}


struct DoctorDetailSheet: View {
    let doctor: Doctor
    @State private var askAvailability = false
    @State private var patientPhone: String = ""
    @State private var sendPhone = false

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
                    sendPhone = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Text("☎️ Your number has been sent. Expect a call shortly.")
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
    }
}
