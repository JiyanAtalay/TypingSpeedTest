//
//  WebService.swift
//  TypingSpeedTest
//
//  Created by Mehmet Jiyan Atalay on 29.07.2024.
//

import Foundation

class WebService {
    func downloadWords(url: URL) async throws -> [String] {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let words = try JSONDecoder().decode([String].self, from: data)
                return words
            }
        } catch _ as DecodingError {
            throw WordsError.decodingError
        } catch {
            throw WordsError.networkError(error)
        }
        return []
    }
}

enum WordsError: Error {
    case decodingError
    case networkError(Error)
}
