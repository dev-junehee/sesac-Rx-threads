//
//  String+.swift
//  SeSACRxThreads
//
//  Created by junehee on 8/14/24.
//

import Foundation

extension String {
    
    func localized(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(string: String, number: Int) -> String {
        return String(format: self.localized(), string, number)
    }
    
    
}
