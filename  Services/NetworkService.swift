//
//  NetworkService.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/16/25.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    func uploadAppointment(payload: [String:Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://your-server.example.com/api/appointments") else {
            completion(.failure(NSError(domain: "BadURL", code: 0)))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error)); return
        }

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { completion(.failure(err)); return }
            completion(.success(()))
        }.resume()
    }

    func uploadSymptomEntry(payload: [String:Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://your-server.example.com/api/symptom_entries") else {
            completion(.failure(NSError(domain: "BadURL", code: 0)))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error)); return
        }

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { completion(.failure(err)); return }
            completion(.success(()))
        }.resume()
    }
}

