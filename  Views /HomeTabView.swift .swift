import SwiftUI

struct HomeTabView: View {
    @ObservedObject var feedVM: FeedViewModel
    @Binding var showSignOutAlert: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(feedVM.posts) { post in
                        EditablePostView(post: post)
                            .padding(.horizontal)
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .searchable(text: $feedVM.searchText, prompt: "Search posts, doctors, entries...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") { showSignOutAlert = true }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 10) {
                        Image("WaspitoLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                        Text("WaspitoPlus")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { feedVM.showLocation.toggle() }) {
                        Image(systemName: "globe")
                            .foregroundColor(.green)
                            .scaleEffect(feedVM.showLocationHeartbeat ? 1.2 : 1)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: feedVM.showLocationHeartbeat)
                    }
                    Button(action: { feedVM.showNotifications.toggle() }) {
                        ZStack {
                            Image(systemName: "bell.fill").foregroundColor(.green)
                            if feedVM.hasPendingNotification {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    Button(action: { feedVM.showProfile.toggle() }) {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .alert(isPresented: $showSignOutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        try? Auth.auth().signOut()
                        feedVM.isUserLoggedIn = false
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

