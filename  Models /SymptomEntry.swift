//
//  SymptomEntry.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/19/25.
//

import Foundation

struct SymptomEntry: Identifiable, Codable, Equatable {
    var id: UUID
      var name: String
      var phone: String
      var title: String
      var age: String
      var gender: String
      var symptoms: String
      var result: String
      var details: String
      var date: Date
      var isSynced: Bool
      var isHealthy: Bool
      var doctorNotified: Bool = false
}

