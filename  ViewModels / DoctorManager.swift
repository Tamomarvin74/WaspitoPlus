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
            Doctor(name: "Dr. Smith", phone: "123456789", isOnline: true, hospitalName: "City Hospital", specialties: ["Cardiology"]),
            Doctor(name: "Dr. Jane", phone: "987654321", isOnline: false, hospitalName: "General Hospital", specialties: ["Neurology"])
        ]
    }
}

