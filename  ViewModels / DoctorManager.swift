import Foundation
import SwiftUI
import CoreLocation

@MainActor
class DoctorManager: ObservableObject {
    @Published private(set) var doctors: [Doctor] = []

    var onlineDoctors: [Doctor] { doctors.filter { $0.isOnline } }

    func addDoctor(_ doctor: Doctor) {
        doctors.append(doctor)
    }

    func updateDoctor(_ doctor: Doctor) {
        guard let index = doctors.firstIndex(where: { $0.id == doctor.id }) else { return }
        doctors[index] = doctor
    }

    func removeDoctor(_ doctor: Doctor) {
        doctors.removeAll { $0.id == doctor.id }
    }

    func loadSampleDoctors() {
        doctors = [
            Doctor(
                name: "Dr. Samuel Mbarga",
                phone: "677123456",
                isOnline: true,
                hospitalName: "Yaoundé Central Hospital",
                specialties: ["Malaria", "Fever", "Infectious Diseases"],
                coordinate: CLLocationCoordinate2D(latitude: 3.848, longitude: 11.502),
                city: "Yaoundé",
                messengerLink: URL(string: "https://m.me/DrSamuelMbarga")
            ),
            Doctor(
                name: "Dr. Aisha Ngassa",
                phone: "699987654",
                isOnline: false,
                hospitalName: "Douala General Hospital",
                specialties: ["Pediatrics", "Flu", "Fever"],
                coordinate: CLLocationCoordinate2D(latitude: 4.051, longitude: 9.767),
                city: "Douala",
                messengerLink: URL(string: "https://m.me/DrAishaNgassa")
            ),
            Doctor(
                name: "Dr. Paul Etoundi",
                phone: "676234567",
                isOnline: true,
                hospitalName: "Buea Regional Hospital",
                specialties: ["Malaria", "Hypertension"],
                coordinate: CLLocationCoordinate2D(latitude: 4.159, longitude: 9.236),
                city: "Buea",
                messengerLink: URL(string: "https://m.me/DrPaulEtoundi")
            )
        ]
    }
}

