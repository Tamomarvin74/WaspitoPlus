//
//   HomePost.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/19/25.
//
 
import SwiftUI

struct HomePost: Identifiable {
    let id = UUID()
    let localId: UUID           
    var authorName: String?
    var authorImage: UIImage?
    var title: String?
    var content: String?
    var image: UIImage?
    var videoURL: URL?
    var likes: Int
    var commentsCount: Int
    var views: Int
    var date: Date
    var comments: [String]
}

