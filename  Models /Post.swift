import Foundation
import SwiftUI

struct Post: Identifiable, Codable {
    let id: UUID
    var authorName: String?
    var authorImage: UIImage?
    var title: String
    var content: String
    var image: UIImage?
    var videoURL: URL?
    var likes: Int
    var commentsCount: Int
    var views: Int
    var date: Date
    var comments: [String]

    init(
        id: UUID = UUID(),
        authorName: String? = nil,
        authorImage: UIImage? = nil,
        title: String,
        content: String,
        image: UIImage? = nil,
        videoURL: URL? = nil,
        likes: Int = 0,
        commentsCount: Int = 0,
        views: Int = 0,
        date: Date = Date(),
        comments: [String] = []
    ) {
        self.id = id
        self.authorName = authorName
        self.authorImage = authorImage
        self.title = title
        self.content = content
        self.image = image
        self.videoURL = videoURL
        self.likes = likes
        self.commentsCount = commentsCount
        self.views = views
        self.date = date
        self.comments = comments
    }

     enum CodingKeys: String, CodingKey {
        case id, authorName, title, content, videoURL,
             likes, commentsCount, views, date, comments
    }
}

