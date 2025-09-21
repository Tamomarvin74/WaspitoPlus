import SwiftUI
import PhotosUI
import CoreLocation
import FirebaseAuth
import AVKit

struct HomeView: View {
    @StateObject private var feedVM = FeedViewModel()
    @StateObject private var doctorManager = DoctorManager()
    
    @State private var selectedTab = 0
    @State private var showSignOutAlert = false
    
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    @State private var pickedItems: [PhotosPickerItem] = []
    
    @State private var avatarPickerItem: PhotosPickerItem? = nil
    
    var body: some View {
        TabView(selection: $selectedTab) {
            homeTab
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            
            NavigationView {
                SymptomCheckerView(searchText: $feedVM.searchText)
            }
            .tabItem { Label("Check", systemImage: "stethoscope") }
            .tag(1)
            
            NavigationView {
                OfflineEntriesView(searchText: feedVM.searchText)
            }
            .tabItem { Label("Offline", systemImage: "tray.and.arrow.down") }
            .tag(2)
            
            NavigationView {
                ConsultDoctorView()
                    .environmentObject(feedVM)
            }
            .tabItem { Label("Consult", systemImage: "cross.case.fill") }
            .tag(3)
            
            settingsTab
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(4)
        }
        .accentColor(.green)
        .onAppear {
            feedVM.loadSamplePosts()
            doctorManager.loadSampleDoctors()
            feedVM.loadOfflineEntries()
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $pickedItems, matching: .images)
        .photosPicker(isPresented: $showingVideoPicker, selection: $pickedItems, matching: .videos)
        .onChange(of: pickedItems) { newItems in handlePickedItems(newItems) }
        .onChange(of: avatarPickerItem) { newItem in
            Task {
                guard let it = newItem,
                      let data: Data = try? await it.loadTransferable(type: Data.self),
                      let ui = UIImage(data: data) else { return }
                feedVM.setCurrentUserAvatar(ui)
            }
        }
    }
    
    // MARK: - Home Tab
    private var homeTab: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search symptoms, posts, doctors...", text: $feedVM.searchText)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    profileAndPostMenu
                    onlineDoctorsSection
                    postsAndSearchSection
                    
                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("WaspitoLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("WaspitoPlus")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                topToolbar
            }
        }
    }
    
    // MARK: - Profile & Post Menu
    private var profileAndPostMenu: some View {
        HStack(spacing: 12) {
            PhotosPicker(selection: $avatarPickerItem, matching: .images, photoLibrary: .shared()) {
                if let image = feedVM.currentUserAvatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.green, lineWidth: 2))
                } else {
                    ZStack {
                        Circle().fill(Color(.systemGray6)).frame(width: 64, height: 64)
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Menu {
                Button("Upload Photo") { showingImagePicker = true }
                Button("Upload Video") { showingVideoPicker = true }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Create Post")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Online Doctors Section
    private var onlineDoctorsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Available Doctors")
                .font(.headline)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(doctorManager.onlineDoctors) { doc in
                        DoctorTopCard(doctor: doc)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Posts Section
    private var postsAndSearchSection: some View {
        VStack(spacing: 16) {
            ForEach(feedVM.filteredPosts, id: \.id) { filteredPost in
                if let binding = bindingForPost(filteredPost) {
                    PostCardView(post: binding)
                        .padding(.horizontal)
                } else {
                    PostCardView(post: .constant(filteredPost))
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private func bindingForPost(_ post: Post) -> Binding<Post>? {
        guard let idx = feedVM.posts.firstIndex(where: { $0.id == post.id }) else { return nil }
        return Binding(get: { feedVM.posts[idx] }, set: { feedVM.posts[idx] = $0 })
    }
    
    // MARK: - Toolbar
    private var topToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { feedVM.showNotifications.toggle() }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    if feedVM.hasPendingNotification {
                        Circle().fill(Color.red).frame(width: 10, height: 10).offset(x: 8, y: -8)
                    }
                }
            }
            
            Button(action: { feedVM.showLocation.toggle() }) {
                Image(systemName: "globe")
                    .foregroundColor(.green)
                    .scaleEffect(feedVM.showLocationHeartbeat ? 1.2 : 1)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: feedVM.showLocationHeartbeat)
            }

            if let avatar = feedVM.currentUserAvatarImage {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.green, lineWidth: 1))
            } else {
                Image(systemName: "person.crop.circle.fill").foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Handle Picked Media
    private func handlePickedItems(_ newItems: [PhotosPickerItem]) {
        guard let item = newItems.first else { return }
        Task {
            if item.supportedContentTypes.contains(.image),
               let data = try? await item.loadTransferable(type: Data.self),
               let ui = UIImage(data: data) {
                let newPost = Post(authorName: feedVM.currentUserName ?? "You",
                                   title: "",
                                   content: "",
                                   image: ui,
                                   likes: 0,
                                   commentsCount: 0,
                                   views: 0,
                                   date: Date(),
                                   comments: [])
                feedVM.addPost(newPost)
            } else if item.supportedContentTypes.contains(.movie) || item.supportedContentTypes.contains(.video),
                      let url = try? await item.loadTransferable(type: URL.self) {
                let newPost = Post(authorName: feedVM.currentUserName ?? "You",
                                   title: "",
                                   content: "",
                                   videoURL: url,
                                   likes: 0,
                                   commentsCount: 0,
                                   views: 0,
                                   date: Date(),
                                   comments: [])
                feedVM.addPost(newPost)
            }
            pickedItems = []
        }
    }
    
    // MARK: - Settings Tab
    private var settingsTab: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button(action: { showSignOutAlert = true }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .alert(isPresented: $showSignOutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) { try? Auth.auth().signOut() },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DoctorTopCard: View {
    let doctor: Doctor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Avatar
            if let avatar = doctor.avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(doctor.name.prefix(1))
                            .foregroundColor(.white)
                            .font(.title2)
                    )
            }

            // Name & Hospital
            Text(doctor.name.isEmpty ? "Unknown Doctor" : doctor.name)
                .font(.headline)
            Text(doctor.hospitalName?.isEmpty == false ? doctor.hospitalName! : "Unknown Hospital")
                .font(.subheadline)
                .foregroundColor(.gray)

            // City
            Text(doctor.city.isEmpty ? "City: Unknown" : "City: \(doctor.city)")
                .font(.caption)
                .foregroundColor(.blue)

            // Specialties
            if !doctor.specialties.isEmpty {
                Text(doctor.specialties.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Online Status
            HStack {
                Circle()
                    .fill(doctor.isOnline ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(doctor.isOnline ? "Online" : "Offline")
                    .font(.caption)
                    .foregroundColor(doctor.isOnline ? .green : .red)
            }

            // Messenger Button
            if let link = doctor.messengerLink, doctor.isOnline {
                Button(action: {
                    if UIApplication.shared.canOpenURL(link) {
                        UIApplication.shared.open(link)
                    }
                }) {
                    Text("Message")
                        .font(.caption)
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .frame(width: 180)
    }
}


// MARK: - PostCardView
struct PostCardView: View {
    @Binding var post: Post
    @State private var newComment: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Author
            Text(post.authorName ?? "Unknown")
                .font(.headline)
            if !post.title.isEmpty {
                Text(post.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            if !post.content.isEmpty {
                Text(post.content)
                    .font(.body)
            }


            // Image
            if let img = post.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            }

            // Video
            if let videoURL = post.videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 200)
                    .cornerRadius(8)
            }

            // Likes / Comments / Views
            HStack {
                Button(action: { post.likes = (post.likes ?? 0) + 1 }) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup.fill")
                        Text("\(post.likes ?? 0)")
                    }
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble")
                    Text("\(post.comments.count)")
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "eye")
                    Text("\(post.views ?? 0)")
                }
            }
            .font(.caption)
            .foregroundColor(.gray)

            // Add Comment
            HStack {
                TextField("Add a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Post") {
                    guard !newComment.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    post.comments.append(newComment)
                    newComment = ""
                }
                .padding(.horizontal, 6)
            }
            .padding(.top, 4)

            // Show Comments
            if !post.comments.isEmpty {
                ForEach(post.comments, id: \.self) { comment in
                    Text(comment)
                        .font(.caption)
                        .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

