//
//   ScheduleConsultationSheet.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/22/25.
//

import SwiftUI

struct ScheduleConsultationSheet: View {
    let doctor: Doctor
    let defaultDate: Date
    var onSchedule: (Date) -> Void
    
    @State private var selectedDate: Date
    
    init(doctor: Doctor, defaultDate: Date, onSchedule: @escaping (Date) -> Void) {
        self.doctor = doctor
        self.defaultDate = defaultDate
        self.onSchedule = onSchedule
        _selectedDate = State(initialValue: defaultDate)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Schedule Consultation with \(doctor.name)")
                    .font(.headline)
                
                DatePicker("Select Date & Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                Button(action: {
                    onSchedule(selectedDate)
                }) {
                    Text("Confirm")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

