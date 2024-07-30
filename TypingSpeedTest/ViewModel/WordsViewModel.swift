//
//  WordsViewModel.swift
//  TypingSpeedTest
//
//  Created by Mehmet Jiyan Atalay on 29.07.2024.
//

import Foundation

class WordsViewModel : ObservableObject {
    @Published var words: [String] = []
    
    let webservice = WebService()
    
    
    func downloadWords(url: URL) async {
        do {
            let data = try await webservice.downloadWords(url: url)
            
            DispatchQueue.main.async {
                self.words = data
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
