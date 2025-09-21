//
//  PostModel.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri on 9/16/25.
//

import Foundation

struct PostModel: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var author: String? = nil
    var createdAt: Date = Date()
}

