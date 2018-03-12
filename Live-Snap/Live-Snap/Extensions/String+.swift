//
//  String+.swift
//  Live-Snap
//
//  Created by Baby on 3/13/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    func contains(substring: String) -> Bool{
        return self.range(of: substring) != nil
    }
    
    func containsIgnoringCase(substring: String) -> Bool{
        return self.range(of: substring, options: .caseInsensitive) != nil
    }
    
    func stringBetweenSubstrings(beginSubstring: String, endSubstring: String) -> String? {
        if let range1 = self.range(of: beginSubstring) {
            let substring = self[range1.lowerBound...]
            if let range2 = substring.range(of: endSubstring) {
                return String(self[range1.upperBound..<range2.lowerBound])
            }
        }
        
        return nil
    }
}

extension Character {
    
    func isDigit() -> Bool {

        let digits = CharacterSet.decimalDigits
        
        for uni in unicodeScalars {
            if digits.contains(uni) {
                return true
            }
        }
        
        return false
    }
    
    func isLetter() -> Bool {
        let letters = CharacterSet.letters
        
        
        for uni in unicodeScalars {
            if letters.contains(uni) {
                return true
            }
        }
        
        return false
    }
}
