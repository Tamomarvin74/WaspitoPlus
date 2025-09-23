//  HomeView.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri on 9/16/25.
//

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
    @State private var showingCreatePostSheet = false
    @State private var newPostText: String = ""
    @State private var newPostUIImage: UIImage? = nil
    @State private var newPostVideoURL: URL? = nil
    
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
            doctorManager.startAutoRefresh()
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
        .sheet(isPresented: $showingCreatePostSheet) {
            NavigationView {
                VStack {
                    ScrollView {
                        VStack(spacing: 12) {
                            TextEditor(text: $newPostText)
                                .frame(height: 120)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4)))
                                .padding()
                            
                            if let img = newPostUIImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 220)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            } else if let videoURL = newPostVideoURL {
                                VideoPlayer(player: AVPlayer(url: videoURL))
                                    .frame(height: 220)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            
                            HStack {
                                Button { showingImagePicker = true } label: {
                                    Label("Add Photo", systemImage: "photo")
                                }
                                Spacer()
                                Button { showingVideoPicker = true } label: {
                                    Label("Add Video", systemImage: "video")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .navigationTitle("New Post")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Post") { createPost() }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            clearCreatePost()
                            showingCreatePostSheet = false
                        }
                    }
                }
            }
        }
    }
    
    private func handleSearchTap(_ result: SearchResult) {
        switch result {
        case .post(let post):
             print("Tapped post: \(post.title)")
        case .doctor(let doctor):
             print("Tapped doctor: \(doctor.name)")
        case .entry(let entry):
             print("Tapped entry: \(entry.title)")
        }
    }

    
    private var searchResultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(feedVM.searchResults) { result in
                    Button(action: { handleSearchTap(result) }) {
                        HStack {
                            switch result {
                            case .post(let post):
                                HStack {
                                    Image(systemName: "doc.text")
                                    Text(post.title.isEmpty ? String(post.content.prefix(50)) + "..." : post.title)
                                        .lineLimit(1)
                                }
                            case .doctor(let doc):
                                HStack {
                                    Image(systemName: "stethoscope")
                                    Text(doc.name)
                                        .lineLimit(1)
                                }
                            case .entry(let entry):
                                HStack {
                                    Image(systemName: "pencil")
                                    Text(entry.title)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .foregroundColor(.primary)

                    Divider()
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 4)
            .padding(.horizontal)
        }
        .frame(maxHeight: 250)
    }

    private var homeTab: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                 HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search symptoms, posts, doctors...", text: $feedVM.searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: feedVM.searchText) { _ in
                            feedVM.performSearch(doctors: doctorManager.doctors)
                        }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                if !feedVM.searchResults.isEmpty && !feedVM.searchText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(feedVM.searchResults) { result in
                                Button(action: {
                                    handleSearchTap(result)
                                }) {
                                    HStack {
                                        switch result {
                                        case .post(let post):
                                            Image(systemName: "doc.text")
                                            Text(post.title.isEmpty ? post.content.prefix(50) + "..." : post.title)
                                                .lineLimit(1)
                                        case .doctor(let doc):
                                            Image(systemName: "stethoscope")
                                            Text(doc.name)
                                        case .entry(let entry):
                                            Image(systemName: "pencil")
                                            Text(entry.title)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                }
                                .foregroundColor(.primary)
                                Divider()
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 250)
                }

                 ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        profileAndPostMenu
                        onlineDoctorsSection
                        postsAndSearchSection
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.top)
                }
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
                Button("Write Post") { showingCreatePostSheet = true }
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
    
     private var onlineDoctorsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Available Doctors").font(.headline)
                Spacer()
                Button(action: { doctorManager.refreshOnlineNow() }) {
                    Image(systemName: "arrow.clockwise").font(.caption)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(doctorManager.onlineDoctors) { doc in
                        NavigationLink(destination: DoctorProfileDetailView(
                            doctor: doc,
                            illness: doc.specialties.first ?? "General"
                        )) {
                            DoctorTopCard(doctor: doc)
                        }

                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
     private var postsAndSearchSection: some View {
        VStack(spacing: 16) {
            ForEach(feedVM.filteredPosts, id: \.id) { filteredPost in
                if let binding = bindingForPost(filteredPost) {
                    PostCardView(post: binding).padding(.horizontal)
                } else {
                    PostCardView(post: .constant(filteredPost)).padding(.horizontal)
                }
            }
        }
    }
    
    private func bindingForPost(_ post: Post) -> Binding<Post>? {
        guard let idx = feedVM.posts.firstIndex(where: { $0.id == post.id }) else { return nil }
        return Binding(get: { feedVM.posts[idx] }, set: { feedVM.posts[idx] = $0 })
    }
    
     private var topToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
             Button(action: {
                withAnimation {
                    feedVM.showNotifications.toggle()
                }
                
                if feedVM.showNotifications {
                    feedVM.markNotificationsAsSeen()  
                }
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .rotationEffect(.degrees(feedVM.shouldShakeBell ? 10 : 0))
                        .animation(
                            feedVM.shouldShakeBell
                                ? Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true)
                                : .default,
                            value: feedVM.shouldShakeBell
                        )
                    
                    if feedVM.hasPendingNotification {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 8, y: -8)
                    }
                }
            }



            Button(action: {
                feedVM.showLocation.toggle()
            }) {
                Image(systemName: "globe")
                    .foregroundColor(.green)
                    .scaleEffect(feedVM.showLocationHeartbeat ? 1.2 : 1)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                               value: feedVM.showLocationHeartbeat)
            }
            .sheet(isPresented: $feedVM.showLocation) {
                DoctorsMapView().environmentObject(doctorManager)
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
    
     private func handlePickedItems(_ newItems: [PhotosPickerItem]) {
        guard let item = newItems.first else { return }
        Task {
            if item.supportedContentTypes.contains(.image),
               let data = try? await item.loadTransferable(type: Data.self),
               let ui = UIImage(data: data) {
                if showingCreatePostSheet {
                    newPostUIImage = ui
                } else {
                    let newPost = Post(authorName: feedVM.currentUserName,
                                       title: "",
                                       content: "",
                                       image: ui,
                                       likes: 0,
                                       commentsCount: 0,
                                       views: 0,
                                       date: Date(),
                                       comments: [])
                    feedVM.addPost(newPost)
                }
            } else if let url = try? await item.loadTransferable(type: URL.self) {
                if showingCreatePostSheet {
                    newPostVideoURL = url
                } else {
                    let newPost = Post(authorName: feedVM.currentUserName,
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
            }
            pickedItems = []
        }
    }
    
    private func createPost() {
        let newPost = Post(authorName: feedVM.currentUserName,
                           title: newPostText.isEmpty ? "" : newPostText,
                           content: newPostText.isEmpty ? "" : newPostText,
                           image: newPostUIImage,
                           likes: 0,
                           commentsCount: 0,
                           views: 0,
                           date: Date(),
                           comments: [])
        feedVM.addPost(newPost)
        clearCreatePost()
        showingCreatePostSheet = false
    }
    
    private func clearCreatePost() {
        newPostText = ""
        newPostUIImage = nil
        newPostVideoURL = nil
    }
    
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
    
    private func avatarURL(for doctor: Doctor) -> URL? {
        let sampleURLs = [
            "https://randomuser.me/api/portraits/women/65.jpg",
            "https://randomuser.me/api/portraits/men/43.jpg",
            "https://randomuser.me/api/portraits/women/32.jpg",
            "https://randomuser.me/api/portraits/men/56.jpg",
            "https://randomuser.me/api/portraits/women/20.jpg",
            "https://randomuser.me/api/portraits/men/14.jpg"
        ]
        let idx = abs(doctor.name.hashValue) % sampleURLs.count
        return URL(string: sampleURLs[idx])
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Doctor Avatar
            if let avatar = doctor.avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else if let url = avatarURL(for: doctor) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Circle().fill(Color.gray.opacity(0.2)).frame(width: 60, height: 60)
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    case .failure:
                        Circle().fill(Color.gray).frame(width: 60, height: 60)
                    @unknown default:
                        Circle().fill(Color.gray).frame(width: 60, height: 60)
                    }
                }
            } else {
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: 60, height: 60)
                    .overlay(Text(doctor.name.prefix(1)).foregroundColor(.white).font(.title2))
            }
            
            // Doctor Info
            Text(doctor.name.isEmpty ? "Unknown Doctor" : doctor.name).font(.headline)
            Text((doctor.hospitalName?.isEmpty == false ? doctor.hospitalName! : "Unknown Hospital"))
                .font(.subheadline).foregroundColor(.gray)
            Text(doctor.city.isEmpty ? "City: Unknown" : "City: \(doctor.city)")
                .font(.caption).foregroundColor(.blue)
            
            if !doctor.specialties.isEmpty {
                Text(doctor.specialties.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Online Status
            HStack {
                Circle().fill(doctor.isOnline ? Color.green : Color.red).frame(width: 8, height: 8)
                Text(doctor.isOnline ? "Online" : "Offline")
                    .font(.caption)
                    .foregroundColor(doctor.isOnline ? .green : .red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .frame(width: 180)
    }
}


struct PostCardView: View {
    @Binding var post: Post
    @State private var newComment: String = ""
    @State private var isLikedLocal: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
 
            HStack(alignment: .top) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green.opacity(0.25))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String((post.authorName ?? "U").prefix(1)))
                                .foregroundColor(.green)
                                .bold()
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.authorName ?? "Unknown")
                            .font(.headline)
                        Text(dateFormatted(post.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                }
                Spacer()
                Button(action: { sharePost(post) }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.green)
                }
            }

             if !post.title.isEmpty {
                Text(post.title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

             if !post.content.isEmpty {
                Text(post.content)
                    .font(.body)
            }

             if let img = post.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(8)
            }

             if let videoURL = post.videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 220)
                    .cornerRadius(8)
            }

             HStack {
                Button(action: toggleLike) {
                    HStack(spacing: 6) {
                        Image(systemName: isLikedLocal ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .foregroundColor(isLikedLocal ? .green : .primary)
                        Text("\(post.likes)")
                            .foregroundColor(isLikedLocal ? .green : .primary)
                    }
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "text.bubble")
                    Text("\(post.commentsCount)")
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "eye")
                    Text("\(post.views)")
                }
            }
            .font(.caption)
            .padding(.vertical, 6)
            .foregroundColor(.gray)

             HStack {
                TextField("Write a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Post") { addComment() }
                    .padding(.horizontal, 6)
            }

             if !post.comments.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(post.comments.enumerated()), id: \.offset) { _, comment in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 28, height: 28)
                                .overlay(Text(String(comment.prefix(1))).foregroundColor(.green))
                            Text(comment)
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear { post.views += 1 }
    }

     private func dateFormatted(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: d)
    }

    private func toggleLike() {
        if isLikedLocal {
            post.likes = max(post.likes - 1, 0)
        } else {
            post.likes += 1
        }
        isLikedLocal.toggle()
    }

    private func addComment() {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        post.comments.append(trimmed)
        post.commentsCount += 1
        newComment = ""
    }

    private func sharePost(_ post: Post) {
        var items: [Any] = []
        if !post.content.isEmpty { items.append(post.content) }
        if !post.title.isEmpty { items.append(post.title) }
        if let img = post.image { items.append(img) }

        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let root = UIApplication.shared.windows.first?.rootViewController {
            root.present(av, animated: true, completion: nil)
        }
    }
}


 struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

