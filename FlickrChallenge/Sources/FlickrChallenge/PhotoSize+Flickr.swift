//
//  File.swift
//  
//
//  Created by Adrian Bilescu on 16.05.2022.
//

import Foundation
import CoreChallenge

extension PhotoSize {
    var longestEdgePixels: Int {
        switch(self) {
            case .thumbnail: return 150
            case .small: return 320
            case .medium: return 800
        }
    }
    
    var suffix: String {
        switch(self) {
            case .thumbnail: return "t"
            case .small: return "n"
            case .medium: return "c"
        }
    }
}
