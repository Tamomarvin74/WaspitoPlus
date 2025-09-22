import SwiftUI
import MapKit

struct DoctorsMapView: View {
    @EnvironmentObject var doctorManager: DoctorManager
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 4.05, longitude: 9.75),
        span: MKCoordinateSpan(latitudeDelta: 3.5, longitudeDelta: 3.5)
    )
    
    @State private var selectedDoctor: Doctor? = nil
    @State private var showSymptomSheet = false
    @State private var patientSymptom = ""
    
    @State private var showDoctorInteraction = false
    @State private var showMedicationSheet = false
    
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
                    HStack {
                        Spacer()
                        Button(action: {
                            region.center = CLLocationCoordinate2D(latitude: 4.05, longitude: 9.75)
                        }) {
                            Image(systemName: "location.fill")
                                .padding(10)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            .navigationTitle("Doctors Map")
            .sheet(isPresented: $showSymptomSheet) {
                if let doctor = selectedDoctor {
                    SymptomInputSheet(
                        doctor: doctor,
                        patientSymptom: $patientSymptom,
                        showSheet: $showSymptomSheet,
                        showDoctorInteraction: $showDoctorInteraction
                    )
                }
            }
            .sheet(isPresented: $showDoctorInteraction) {
                if let doctor = selectedDoctor {
                    DoctorInteractionSheet(
                        doctor: doctor,
                        showSheet: $showDoctorInteraction,
                        showMedicationSheet: $showMedicationSheet
                    )
                }
            }
            .sheet(isPresented: $showMedicationSheet) {
                MedicationDeliverySheet(showSheet: $showMedicationSheet)
            }
        }
    }
}

// MARK: - Doctor Annotation with glowing pulse
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

