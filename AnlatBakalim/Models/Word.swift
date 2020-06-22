//
//  Word.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation

class WordType: Codable, Identifiable {
    let id  = UUID()
    var wordId: Int? = 1
    var word: String = ""
    var forbiddenWords: [String] = []
    
    // All your properties should be included
    enum CodingKeys: String, CodingKey {
        case id
        case word
        case wordId
        case forbiddenWords   // this one was missing
    }
}
