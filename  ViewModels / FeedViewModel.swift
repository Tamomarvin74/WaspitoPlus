import Foundation
import SwiftUI
import CoreLocation

@MainActor
final class FeedViewModel: ObservableObject {

    @Published var posts: [Post] = []
    @Published var doctors: [Doctor] = []
    @Published var offlineEntries: [SymptomEntry] = []

    @Published var searchText: String = ""
    @Published var currentUserAvatarImage: UIImage? = nil
    @Published var currentUserName: String? = "You"

    @Published var showNotifications: Bool = false
    @Published var hasPendingNotification: Bool = false
    @Published var shouldShakeBell: Bool = false

    @Published var showLocation: Bool = false
    @Published var showLocationHeartbeat: Bool = false
    @Published var selectedDoctor: Doctor? = nil  

    @Published var notifications: [String] = []

    @Published var searchResults: [SearchResult] = []
    
    @Published var showPharmacyNotificationDot: Bool = false
    @Published var hasConsultedDoctor: Bool = false


    init() {
        loadSamplePosts()
        loadSampleDoctors()
        loadOfflineEntries()
    }

    var filteredPosts: [Post] {
        if searchText.isEmpty { return posts }
        return posts.filter {
            $0.title.lowercased().contains(searchText.lowercased()) ||
            $0.content.lowercased().contains(searchText.lowercased())
        }
    }

    func performSearch(doctors externalDoctors: [Doctor]? = nil) {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        let matchingPosts = posts.filter { post in
            post.title.lowercased().contains(query) ||
            post.content.lowercased().contains(query) ||
            (post.authorName?.lowercased().contains(query) ?? false)
        }

        let matchingDoctors = (externalDoctors ?? doctors).filter { doctor in
            doctor.name.lowercased().contains(query) ||
            doctor.specialties.joined(separator: ", ").lowercased().contains(query) ||
            (doctor.hospitalName?.lowercased().contains(query) ?? false)
        }

        let matchingEntries = offlineEntries.filter { entry in
            entry.title.lowercased().contains(query) ||
            entry.details.lowercased().contains(query) ||
            entry.symptoms.lowercased().contains(query) ||
            entry.name.lowercased().contains(query)
        }

        searchResults = matchingPosts.map { .post($0) } +
                        matchingDoctors.map { .doctor($0) } +
                        matchingEntries.map { .entry($0) }
    }

    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
        performSearch()
    }

    func updatePost(_ post: Post) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[idx] = post
        performSearch()
    }

    func toggleLike(for post: Post) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[idx].likes += 1
        performSearch()
    }

    func addDoctor(_ doc: Doctor) {
        doctors.insert(doc, at: 0)
        performSearch()
    }

    func loadOfflineEntries() {
        offlineEntries = [
            SymptomEntry(
                id: UUID(),
                name: "Alice",
                phone: "555",
                title: "Entry 1",
                age: "30",
                gender: "Female",
                symptoms: "Cough and fever",
                result: "Suspected infection",
                details: "Cough + fever for 2 days",
                date: Date(),
                isSynced: false,
                isHealthy: false
            )
        ]
    }

    func loadSamplePosts() {
        posts = [
            Post(
                authorName: "Admin",
                title: "Healthy Living Tips",
                content: "Stay hydrated, eat fruits, and sleep well.",
                likes: 10,
                commentsCount: 2,
                views: 50
            ),
            Post(
                authorName: "Dr. John",
                title: "Skin Care Advice",
                content: "Always use sunscreen.",
                likes: 5,
                commentsCount: 1,
                views: 20
            )
        ]
    }

    func loadSampleDoctors() {
        doctors = [
            Doctor(
                id: UUID(),
                name: "Dr. Smith",
                phone: "123-456-7890",
                hospitalName: "City Hospital",
                city: "Cityville",
                specialties: ["Cardiologist"],
                coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                avatar: nil,
                imageURL: nil,
                isOnline: true
            ),
            Doctor(
                id: UUID(),
                name: "Dr. Jane",
                phone: "987-654-3210",
                hospitalName: "General Clinic",
                city: "Townsville",
                specialties: ["Dermatologist"],
                coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                avatar: nil,
                imageURL: nil,
                isOnline: false
            )
        ]
    }

    func setCurrentUserAvatar(_ image: UIImage) {
        currentUserAvatarImage = image
    }

    func markNotificationPending(_ pending: Bool = true) {
        hasPendingNotification = pending
    }

    func markConsultationScheduled() {
        showLocationHeartbeat = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.showLocationHeartbeat = false
        }
    }

    func triggerReminder(message: String) {
        notifications.append(message)
        hasPendingNotification = true
        shouldShakeBell = true
    }

    func markNotificationsAsSeen() {
        hasPendingNotification = false
        shouldShakeBell = false
    }
}

enum SearchResult: Identifiable {
    case post(Post)
    case doctor(Doctor)
    case entry(SymptomEntry)

    var id: String {
        switch self {
        case .post(let p): return p.id.uuidString
        case .doctor(let d): return d.id.uuidString
        case .entry(let e): return e.id.uuidString
        }
    }
}

