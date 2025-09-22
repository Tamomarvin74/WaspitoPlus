import Foundation
import CoreLocation
import SwiftUI

struct Doctor: Identifiable, Codable {
    var id = UUID()
      var name: String
      var phone: String
      var hospitalName: String? = nil
      var city: String = ""
      var isOnline: Bool = false
      var specialties: [String] = []
      var coordinate: CLLocationCoordinate2D
      var imageURL: URL? = nil
      var avatar: UIImage? = nil
    init(
        id: UUID = UUID(),
        name: String,
        phone: String = "",
        hospitalName: String? = nil,
        city: String = "",
        specialties: [String] = [],
        coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0),
        avatar: UIImage? = nil,
        imageURL: URL? = nil,
        isOnline: Bool = false         
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.hospitalName = hospitalName
        self.city = city
        self.specialties = specialties
        self.coordinate = coordinate
        self.avatar = avatar
        self.imageURL = imageURL
        self.isOnline = isOnline
    }

     enum CodingKeys: String, CodingKey {
        case id, name, phone, hospitalName, city, specialties, latitude, longitude, imageURL, isOnline
    }

     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        phone = try container.decode(String.self, forKey: .phone)
        hospitalName = try container.decodeIfPresent(String.self, forKey: .hospitalName)
        city = try container.decode(String.self, forKey: .city)
        specialties = try container.decode([String].self, forKey: .specialties)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        isOnline = try container.decode(Bool.self, forKey: .isOnline)

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
        try container.encodeIfPresent(hospitalName, forKey: .hospitalName)
        try container.encode(city, forKey: .city)
        try container.encode(specialties, forKey: .specialties)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }

     func canTreat(symptom: String) -> Bool {
        guard isOnline else { return false }
        return specialties.contains { $0.lowercased().contains(symptom.lowercased()) }
    }
}

