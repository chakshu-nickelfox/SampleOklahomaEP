//
//  ExamPrepButtonType.swift
//  LifeSafetyEducator4
//
//  Created by Vaibhav Parmar on 29/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import Foundation

enum ExamPrepButtonType {
    case buy, unselect, selectAll, enableSelection
    
    var buttonTitle: String {
        switch self {
        case .buy: return " Buy All"
        case .unselect: return "Unselect All"
        case .selectAll: return "Select All"
        case .enableSelection: return "SelectAll"
        }
    }
}
