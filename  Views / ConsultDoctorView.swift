import SwiftUI
import MapKit

// MARK: - ConsultDoctorView
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
        Doctor(id: UUID(), name: "Dr. Alice Smith", phone: "679093234", isOnline: true, hospitalName: "Buea Regional Hospital", specialties: ["Fever", "Cough"], coordinate: CLLocationCoordinate2D(latitude: 4.1482, longitude: 9.23653)),
        Doctor(id: UUID(), name: "Dr. James", phone: "645321276", isOnline: true, hospitalName: "Saint Luke's Medical Center", specialties: ["Headache", "Back Pain"], coordinate: CLLocationCoordinate2D(latitude: 4.165686, longitude: 9.273408))
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Request a Consultation")
                .font(.title2)
                .bold()
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
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(doc.hospitalName ?? "")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
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
        DispatchQueue.main.async {
            // Call your feedVM functions
            // Make sure these exist in FeedViewModel
            // Example:
            // feedVM.markConsultationScheduled()
            // feedVM.showLocationHeartbeat = true
        }
    }
}

// MARK: - ScheduleConsultationSheet
struct ScheduleConsultationSheet: View {
    var doctor: Doctor
    var defaultDate: Date
    @EnvironmentObject var feedVM: FeedViewModel
    @Environment(\.dismiss) var dismiss
    @State private var date: Date
    @State private var region: MKCoordinateRegion
    var onSchedule: (Date) -> Void

    init(doctor: Doctor, defaultDate: Date, onSchedule: @escaping (Date) -> Void) {
        self.doctor = doctor
        self.defaultDate = defaultDate
        self.onSchedule = onSchedule
        _date = State(initialValue: defaultDate)
        _region = State(initialValue: MKCoordinateRegion(center: doctor.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Doctor")) {
                    Text(doctor.name).bold()
                    Text(doctor.specialties.joined(separator: ", "))
                        .font(.caption)
                }
                Section(header: Text("Choose time")) {
                    DatePicker("Appointment time", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }
                Section(header: Text("Location")) {
                    Map(coordinateRegion: $region, annotationItems: [doctor]) { d in
                        MapAnnotation(coordinate: d.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Schedule") {
                        onSchedule(date)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview
struct ConsultDoctorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsultDoctorView()
                .environmentObject(FeedViewModel())
        }
    }
}

