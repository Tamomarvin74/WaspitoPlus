//
//  SymptomEntry+CoreDataProperties.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/18/25.
//
//

import Foundation
import CoreData


extension SymptomEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SymptomEntry> {
        return NSFetchRequest<SymptomEntry>(entityName: "SymptomEntry")
    }

    @NSManaged public var age: String?
    @NSManaged public var date: Date?
    @NSManaged public var gender: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isSynced: Bool
    @NSManaged public var result: String?
    @NSManaged public var symptoms: String?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?

}

extension SymptomEntry : Identifiable {

}
