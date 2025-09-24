import SwiftUI
import MapKit

struct DoctorsMapView: View {
    @EnvironmentObject var doctorManager: DoctorManager
    @EnvironmentObject var feedVM: FeedViewModel
    @Binding var selectedDoctor: Doctor?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 4.05, longitude: 9.75),
        span: MKCoordinateSpan(latitudeDelta: 3.5, longitudeDelta: 3.5)
    )

    @State private var patientSymptom = ""
    @State private var showSymptomSheet = false
    @State private var showDoctorResponse = false
    @State private var showMedicationSheet = false
    @State private var pharmacyAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: doctorManager.onlineDoctors) { doctor in
                    MapAnnotation(coordinate: doctor.coordinate) {
                        DoctorAnnotationView(
                            doctor: doctor,
                            isActive: patientSymptom.isEmpty || doctor.canTreat(symptom: patientSymptom)
                        )
                        .onTapGesture {
                            if patientSymptom.isEmpty || doctor.canTreat(symptom: patientSymptom) {
                                selectedDoctor = doctor
                                showSymptomSheet = true
                            }
                        }
                    }
                }
                .ignoresSafeArea()

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "pills.fill")
                            .foregroundColor(pharmacyAlert ? .green : .gray)
                            .padding()
                    }
                }
            }
            .navigationTitle("Doctors Map")
             .sheet(isPresented: $showSymptomSheet) {
                if let doctor = selectedDoctor {
                    SymptomInputSheet(
                        doctor: doctor,
                        patientSymptom: $patientSymptom,
                        showSheet: $showSymptomSheet,
                        showDoctorInteraction: $showDoctorResponse
                    )
                }
            }
             .onChange(of: showDoctorResponse) { newValue in
                if newValue, selectedDoctor != nil {
                    showDoctorResponse = false
                    showMedicationSheet = true
                    pharmacyAlert = true
                }
            }
             .sheet(isPresented: $showMedicationSheet, onDismiss: {
                pharmacyAlert = true
                feedVM.showPharmacyNotificationDot = true // updates HomeView
            }) {
                MedicationDeliverySheet(showSheet: $showMedicationSheet)
            }
        }
    }
}

 struct DoctorAnnotationView: View {
    let doctor: Doctor
    let isActive: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            if isActive {
                Circle()
                    .fill(Color.green.opacity(0.25))
                    .frame(width: 70, height: 70)
                    .scaleEffect(pulse ? 1.2 : 1)
                    .opacity(pulse ? 0 : 0.6)
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 1.4).repeatForever(autoreverses: false)) {
                            pulse = true
                        }
                    }
            }

            if let avatar = doctor.avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .opacity(isActive ? 1 : 0.4)
            } else if let url = doctor.imageURL {
                AsyncImage(url: url) { phase in
                    if let img = phase.image {
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .opacity(isActive ? 1 : 0.4)
                    } else {
                        Circle().fill(Color.green).frame(width: 48, height: 48).opacity(isActive ? 1 : 0.4)
                    }
                }
            } else {
                Circle()
                    .fill(Color.green)
                    .frame(width: 48, height: 48)
                    .overlay(Text(String(doctor.name.prefix(1))).foregroundColor(.white))
                    .opacity(isActive ? 1 : 0.4)
            }
        }
    }
}

struct DoctorsMapView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorsMapView(selectedDoctor: .constant(nil))
            .environmentObject(FeedViewModel())
            .environmentObject(DoctorManager())
    }
}
