//
//  PharmacyData.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri on 9/23/25.
//

import Foundation

struct Medicine: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let stock: Int
    let icon: String = "pills"
}

struct PharmacyData {
    static let medicines: [Medicine] = [
        Medicine(name: "Paracetamol", description: "Pain relief and fever reducer.", price: 2.50, stock: 50),
        Medicine(name: "Ibuprofen", description: "Anti-inflammatory and pain relief.", price: 3.00, stock: 40),
        Medicine(name: "Amoxicillin", description: "Antibiotic for bacterial infections.", price: 8.00, stock: 30),
        Medicine(name: "Cetirizine", description: "Relieves allergy symptoms.", price: 4.50, stock: 25),
        Medicine(name: "Vitamin C", description: "Boosts immune system.", price: 6.00, stock: 60),
        Medicine(name: "Azithromycin", description: "Used to treat bacterial infections.", price: 12.00, stock: 18),
        Medicine(name: "Metformin", description: "Helps control blood sugar.", price: 10.00, stock: 22),
        Medicine(name: "Amlodipine", description: "Treats high blood pressure.", price: 9.50, stock: 35),
        Medicine(name: "Losartan", description: "Used for hypertension treatment.", price: 11.00, stock: 28),
        Medicine(name: "Atorvastatin", description: "Lowers cholesterol levels.", price: 13.00, stock: 32),
        Medicine(name: "Omeprazole", description: "Reduces stomach acid.", price: 7.00, stock: 45),
        Medicine(name: "Loratadine", description: "Antihistamine for allergies.", price: 5.50, stock: 40),
        Medicine(name: "Prednisone", description: "Reduces inflammation.", price: 15.00, stock: 20),
        Medicine(name: "Hydroxychloroquine", description: "Used for malaria and autoimmune conditions.", price: 20.00, stock: 12),
        Medicine(name: "Clarithromycin", description: "Macrolide antibiotic.", price: 14.00, stock: 17),
        Medicine(name: "Salbutamol", description: "Relieves asthma symptoms.", price: 8.50, stock: 33),
        Medicine(name: "Folic Acid", description: "Supports pregnancy health.", price: 4.00, stock: 55),
        Medicine(name: "Zinc Sulphate", description: "Boosts immunity.", price: 5.00, stock: 48),
        Medicine(name: "Doxycycline", description: "Antibiotic for infections.", price: 9.00, stock: 30),
        Medicine(name: "Insulin", description: "Manages diabetes.", price: 25.00, stock: 15),
    
    ]
}

