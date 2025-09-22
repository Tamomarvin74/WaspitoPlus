import Foundation
import SwiftUI
import CoreLocation

@MainActor
class DoctorManager: ObservableObject {
    @Published private(set) var doctors: [Doctor] = []

    var onlineDoctors: [Doctor] { doctors.filter { $0.isOnline } }

    private var refreshTask: Task<Void, Never>? = nil

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
            Doctor(name: "Dr. Samuel Mbarga", phone: "677123456", isOnline: true, hospitalName: "Yaoundé Central Hospital", specialties: ["Malaria", "Fever", "Infectious Diseases"], coordinate: CLLocationCoordinate2D(latitude: 3.848, longitude: 11.502), city: "Yaoundé", avatar: nil, messengerLink: URL(string: "https://m.me/DrSamuelMbarga")),
            Doctor(name: "Dr. Aisha Ngassa", phone: "699987654", isOnline: false, hospitalName: "Douala General Hospital", specialties: ["Pediatrics", "Flu", "Fever"], coordinate: CLLocationCoordinate2D(latitude: 4.051, longitude: 9.767), city: "Douala", avatar: nil, messengerLink: URL(string: "https://m.me/DrAishaNgassa")),
            Doctor(name: "Dr. Paul Etoundi", phone: "676234567", isOnline: true, hospitalName: "Buea Regional Hospital", specialties: ["Malaria", "Hypertension"], coordinate: CLLocationCoordinate2D(latitude: 4.159, longitude: 9.236), city: "Buea", avatar: nil, messengerLink: URL(string: "https://m.me/DrPaulEtoundi")),
            Doctor(name: "Dr. Rose Tchouakeu", phone: "675112233", isOnline: true, hospitalName: "Bamenda Regional Clinic", specialties: ["General Medicine", "Fever"], coordinate: CLLocationCoordinate2D(latitude: 5.963, longitude: 10.157), city: "Bamenda", avatar: nil, messengerLink: URL(string: "https://m.me/DrRoseT")),
            Doctor(name: "Dr. Daniel Ngwa", phone: "677445566", isOnline: false, hospitalName: "Garoua Central", specialties: ["Pediatrics"], coordinate: CLLocationCoordinate2D(latitude: 9.301, longitude: 13.398), city: "Garoua", avatar: nil, messengerLink: URL(string: "https://m.me/DrDanielNgwa")),
            Doctor(name: "Dr. Marie N.", phone: "699334455", isOnline: true, hospitalName: "Maroua Clinic", specialties: ["Dermatology"], coordinate: CLLocationCoordinate2D(latitude: 10.595, longitude: 14.324), city: "Maroua", avatar: nil, messengerLink: URL(string: "https://m.me/DrMarieN"))
        ]
    }


    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task.detached { [weak self] in
            guard let self = self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(300) * 1_000_000_000) // 300s = 5m
                await self.randomizeOnlineDoctors()
            }
        }
    }

    func refreshOnlineNow() {
        Task { await randomizeOnlineDoctors() }
    }

    private func randomizeOnlineDoctors() {
         var new = doctors
 
        let count = new.count
        guard count > 0 else { return }
        let onlineCount = max(1, Int.random(in: 1...min(4, count)))

        var indices = Array(new.indices)
        indices.shuffle()
        let onlineSet = Set(indices.prefix(onlineCount))
        for i in new.indices {
            new[i].isOnline = onlineSet.contains(i)
        }
        doctors = new
    }
}

