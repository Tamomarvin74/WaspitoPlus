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

     @Published var notifications: [String] = []

  
    func triggerReminder(message: String) {
        notifications.append(message)
        hasPendingNotification = true
        shouldShakeBell = true
    }

     func markNotificationsAsSeen() {
        hasPendingNotification = false
        shouldShakeBell = false
    }

     init() {
        loadSamplePosts()
        loadSampleDoctors()
        loadOfflineEntries()
    }

     var filteredPosts: [Post] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return posts }
        return posts.filter { post in
            post.title.lowercased().contains(query) ||
            post.content.lowercased().contains(query) ||
            (post.authorName ?? "").lowercased().contains(query)
        }
    }

    var filteredDoctors: [Doctor] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return doctors }
        return doctors.filter { doctor in
            doctor.name.lowercased().contains(query) ||
            doctor.specialties.joined(separator: ", ").lowercased().contains(query) ||
            (doctor.hospitalName ?? "").lowercased().contains(query)
        }
    }

    var filteredOfflineEntries: [SymptomEntry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return offlineEntries }
        return offlineEntries.filter { entry in
            entry.title.lowercased().contains(query) ||
            entry.details.lowercased().contains(query) ||
            entry.symptoms.lowercased().contains(query) ||
            entry.name.lowercased().contains(query)
        }
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
                name: "Dr. Smith",
                phone: "123-456-7890",
                isOnline: true,
                hospitalName: "City Hospital",
                specialties: ["Cardiologist"],
                coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            ),
            Doctor(
                name: "Dr. Jane",
                phone: "987-654-3210",
                isOnline: false,
                hospitalName: "General Clinic",
                specialties: ["Dermatologist"],
                coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            )
        ]
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

    // MARK: - Post actions
    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
    }

    func updatePost(_ post: Post) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[idx] = post
    }

    func toggleLike(for post: Post) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[idx].likes += 1
    }

    // MARK: - Doctor actions
    func addDoctor(_ doc: Doctor) {
        doctors.insert(doc, at: 0)
    }

    // MARK: - User actions
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
}

