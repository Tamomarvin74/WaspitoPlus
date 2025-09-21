//
//   SymptomEntry.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/18/25.
//

import Foundation

struct SymptomEntry: Identifiable {
    var id: String
    var name: String
    var phone: String
    var age: String
    var gender: String
    var symptoms: String
    var result: String
    var date: Date
    var isSynced: Bool
    var isHealthy: Bool
}

