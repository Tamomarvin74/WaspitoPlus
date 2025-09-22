//
//   HomePost.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/19/25.
//
 
import SwiftUI

import Foundation
import UIKit

struct HomePost: Identifiable {
    let id: UUID
    var authorName: String?
    var title: String?
    var content: String?
    var image: UIImage?
    var videoURL: URL?
    var likes: Int
    var commentsCount: Int
    var views: Int
    var comments: [String]

    init(id: UUID = UUID(),
         authorName: String? = nil,
         title: String? = nil,
         content: String? = nil,
         image: UIImage? = nil,
         videoURL: URL? = nil,
         likes: Int = 0,
         commentsCount: Int = 0,
         views: Int = 0,
         comments: [String] = []) {
        self.id = id
        self.authorName = authorName
        self.title = title
        self.content = content
        self.image = image
        self.videoURL = videoURL
        self.likes = likes
        self.commentsCount = commentsCount
        self.views = views
        self.comments = comments
    }
}

