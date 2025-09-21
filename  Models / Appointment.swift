//
//  Appointment.swift
//  WaspitoPlus
//

import Foundation

struct Appointment: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var location: String?
    var isDone: Bool

    init(id: UUID = UUID(), title: String, date: Date, location: String? = nil, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.location = location
        self.isDone = isDone
    }
}

