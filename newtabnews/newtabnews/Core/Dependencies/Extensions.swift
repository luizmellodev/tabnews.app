//
//  Extensions.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import Foundation
import SwiftUI

public func getFormattedDate(value: String) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "pt_br")
    dateFormat.dateFormat = "EEEE, dd MMMM"
    let stringDate = dateFormat.string(from: Date())
    return stringDate
}



enum Theme: Int {
    case light
    case dark
    
    var colorScheme: ColorScheme {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
