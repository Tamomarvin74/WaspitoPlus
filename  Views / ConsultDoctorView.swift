import SwiftUI
import MapKit
import UserNotifications

struct ConsultDoctorView: View {
    @EnvironmentObject var feedVM: FeedViewModel

    @State private var selectedIllness: String = ""
    @State private var showDoctorList: Bool = false
    @State private var chosenDoctor: Doctor? = nil
    @State private var scheduledDate = Date().addingTimeInterval(60 * 5)
    @State private var showConfirmation = false

    private let illnesses = [
        "Fever", "Cough", "Headache", "Skin Rash", "Stomach Pain", "Back Pain", "Shortness of Breath"
    ]
    private let allDoctors: [Doctor] = [
        Doctor(
            id: UUID(),
            name: "Dr. Alice Smith",
            phone: "679093234",
            hospitalName: "Douala General Hospital",
            city: "Douala",
            specialties: ["Fever", "Cough"],
            coordinate: CLLocationCoordinate2D(latitude: 4.0511, longitude: 9.7679),
            avatar: nil,
            imageURL: nil,
            isOnline: true
        ),
        Doctor(
            id: UUID(),
            name: "Dr. James",
            phone: "645321276",
            hospitalName: "Laquintinie Hospital",
            city: "Douala",
            specialties: ["Headache", "Back Pain"],
            coordinate: CLLocationCoordinate2D(latitude: 4.0530, longitude: 9.7386),
            avatar: nil,
            imageURL: nil,
            isOnline: true
        )
    ]



    var body: some View {
        VStack(spacing: 16) {
            Text("Request a Consultation")
                .font(.title2).bold()
                .padding(.top, 10)

            Picker("Select Illness", selection: $selectedIllness) {
                Text("Select illness").tag("")
                ForEach(illnesses, id: \.self) { ill in
                    Text(ill).tag(ill)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color.green.opacity(0.08))
            .cornerRadius(8)
            .padding(.horizontal)

            Button(action: findDoctors) {
                Text("Find Available Doctors")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedIllness.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(selectedIllness.isEmpty)

            if showDoctorList {
                let available = matchedDoctors()
                if available.isEmpty {
                    Text("No doctors currently available for \(selectedIllness). Try again later.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(available) { doc in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(doc.name).bold()
                                Text(doc.specialties.joined(separator: ", "))
                                    .font(.caption).foregroundColor(.secondary)
                                Text(doc.hospitalName ?? "")
                                    .font(.caption2).foregroundColor(.gray)
                            }
                            Spacer()
                            Text(doc.isOnline ? "Online" : "Offline")
                                .font(.caption2)
                                .padding(6)
                                .background(doc.isOnline ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                                .cornerRadius(6)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if doc.isOnline { chosenDoctor = doc }
                        }
                    }
                    .listStyle(.plain)
                }
            }

            Spacer()
        }
        .navigationTitle("Consult Doctor")
        .sheet(item: $chosenDoctor) { doc in
            ScheduleConsultationSheet(doctor: doc, defaultDate: scheduledDate) { date in
                scheduleConsultation(with: doc, at: date)
                showConfirmation = true
            }
            .environmentObject(feedVM)
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Scheduled"),
                message: Text("Your consultation with \(chosenDoctor?.name ?? "doctor") is scheduled."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func findDoctors() {
        let available = matchedDoctors()
        if let firstOnline = available.first {
            chosenDoctor = firstOnline
        } else {
            showDoctorList = true
        }
    }

    private func matchedDoctors() -> [Doctor] {
        allDoctors.filter { $0.specialties.contains(where: { $0.caseInsensitiveCompare(selectedIllness) == .orderedSame }) && $0.isOnline }
    }

    private func scheduleConsultation(with doctor: Doctor, at date: Date) {
         NotificationService.shared.scheduleNotification(
            id: UUID().uuidString,
            title: "Doctor Consultation Reminder",
            body: "Your consultation with \(doctor.name) is coming up!",
            date: date
        )

         DispatchQueue.main.async {
            feedVM.markConsultationScheduled()
            feedVM.showLocationHeartbeat = true
            feedVM.triggerReminder(message: "Your consultation with \(doctor.name) is scheduled for \(formattedDate(date)).")
            chosenDoctor = doctor
        }
    }
    
     private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

