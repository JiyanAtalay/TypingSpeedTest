//
//  Urls.swift
//  TypingSpeedTest
//
//  Created by Mehmet Jiyan Atalay on 29.07.2024.
//

import Foundation

struct Urls {
    static func wordsByNumber(number: Int) -> URL{
        return URL(string: "https://random-word-api.herokuapp.com/word?number=\(number)")!
    }
}
