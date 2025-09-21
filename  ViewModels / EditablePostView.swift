import SwiftUI

struct EditablePostView: View {
    let title: String
    let content: String
    
    init(postTitle: String, postContent: String) {
        self.title = postTitle
        self.content = postContent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(content).font(.body).foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

