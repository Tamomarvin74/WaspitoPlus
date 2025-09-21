//
//  CD_SymptomEntry+CoreDataProperties.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/18/25.
//
//

import Foundation
import CoreData


extension CD_SymptomEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CD_SymptomEntry> {
        return NSFetchRequest<CD_SymptomEntry>(entityName: "CD_SymptomEntry")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var age: String?
    @NSManaged public var gender: String?
    @NSManaged public var symptoms: String?
    @NSManaged public var result: String?
    @NSManaged public var date: Date?
    @NSManaged public var isSynced: Bool
    @NSManaged public var isHealthy: Bool

}

extension CD_SymptomEntry : Identifiable {

}
