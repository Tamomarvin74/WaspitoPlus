import Foundation
import SwiftUI
import CoreLocation

struct Doctor: Identifiable, Codable {
    let id: UUID
    var name: String
    var phone: String
    var isOnline: Bool
    var hospitalName: String?
    var specialties: [String]
    var coordinate: CLLocationCoordinate2D
    var city: String
    var avatar: UIImage? = nil
    var messengerLink: URL? = nil   

    init(
        id: UUID = UUID(),
        name: String,
        phone: String,
        isOnline: Bool,
        hospitalName: String? = nil,
        specialties: [String] = [],
        coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        city: String = "",
        avatar: UIImage? = nil,
        messengerLink: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.isOnline = isOnline
        self.hospitalName = hospitalName
        self.specialties = specialties
        self.coordinate = coordinate
        self.city = city
        self.avatar = avatar
        self.messengerLink = messengerLink
    }

    enum CodingKeys: String, CodingKey {
        case id, name, phone, isOnline, hospitalName, specialties, latitude, longitude, city, messengerLink
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        phone = try container.decode(String.self, forKey: .phone)
        isOnline = try container.decode(Bool.self, forKey: .isOnline)
        hospitalName = try container.decodeIfPresent(String.self, forKey: .hospitalName)
        specialties = try container.decode([String].self, forKey: .specialties)
        city = try container.decode(String.self, forKey: .city)
        messengerLink = try container.decodeIfPresent(URL.self, forKey: .messengerLink)

        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        avatar = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(phone, forKey: .phone)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encodeIfPresent(hospitalName, forKey: .hospitalName)
        try container.encode(specialties, forKey: .specialties)
        try container.encode(city, forKey: .city)
        try container.encodeIfPresent(messengerLink, forKey: .messengerLink)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}

