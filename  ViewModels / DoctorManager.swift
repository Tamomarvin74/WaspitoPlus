//
//  DoctorManager.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri on 9/22/25.
//

import Foundation
import SwiftUI
import CoreLocation

@MainActor
class DoctorManager: ObservableObject {
    @Published var doctors: [Doctor] = []
    @Published var onlineDoctors: [Doctor] = []
    
    private var timer: Timer?
    
    init() {
        loadSampleDoctors()
        startAutoRefresh()
    }
    
    func loadSampleDoctors() {
        doctors = [
            Doctor(
                name: "Dr. Javis",
                hospitalName: "Douala General Hospital",
                city: "Douala",
                specialties: ["Fever", "Cold", "Flu"],
                coordinate: CLLocationCoordinate2D(latitude: 4.05, longitude: 9.75),
                avatar: nil,
                imageURL: URL(string: "https://randomuser.me/api/portraits/men/43.jpg"),
                isOnline: Bool.random()
            ),
            Doctor(
                name: "Dr. Amina",
                hospitalName: "Yaoundé Central",
                city: "Yaoundé",
                specialties: ["Headache", "Allergy"],
                coordinate: CLLocationCoordinate2D(latitude: 3.87, longitude: 11.52),
                avatar: nil,
                imageURL: URL(string: "https://randomuser.me/api/portraits/women/32.jpg"),
                isOnline: Bool.random()
            ),
            Doctor(
                name: "Dr. Samuel",
                hospitalName: "Bamenda Clinic",
                city: "Bamenda",
                specialties: ["Stomach Pain", "Cold", "Flu"],
                coordinate: CLLocationCoordinate2D(latitude: 5.96, longitude: 10.15),
                avatar: nil,
                imageURL: URL(string: "https://randomuser.me/api/portraits/men/56.jpg"),
                isOnline: Bool.random()
            ),
            Doctor(
                name: "Dr. Grace",
                hospitalName: "Kribi Health Center",
                city: "Kribi",
                specialties: ["Skin Rash", "Fever"],
                coordinate: CLLocationCoordinate2D(latitude: 2.95, longitude: 9.91),
                avatar: nil,
                imageURL: URL(string: "https://randomuser.me/api/portraits/women/65.jpg"),
                isOnline: Bool.random()
            )
        ]
        
         onlineDoctors = doctors.filter { $0.isOnline }
    }
    
    func refreshOnlineNow() {
         doctors.indices.forEach { idx in
            doctors[idx].isOnline.toggle()
        }
        onlineDoctors = doctors.filter { $0.isOnline }
    }
    
    func startAutoRefresh() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshOnlineNow()
            }
        }
    }
    
    func doctorsFor(symptom: String) -> [Doctor] {
        doctors.filter { $0.specialties.contains { $0.localizedCaseInsensitiveContains(symptom) } && $0.isOnline }
    }
    
    func sendPatientRequest(to doctor: Doctor, patientPhone: String, message: String?) {
        print("Patient request sent to \(doctor.name): \(message ?? "No message")")
    }
    
    func doctorIsAvailable(_ doctor: Doctor) -> Bool {
        return doctor.isOnline
    }
}

