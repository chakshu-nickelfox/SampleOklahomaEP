//
//  QuestionActionType.swift
//  LifeSafetyEducator4
//
//  Created by Vaibhav Parmar on 29/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

enum QuestionActionType {
    
    case skip
    case next
    case finish
    
    var title: String {
        switch self {
        case .skip:
            return "Skip"
        case .next:
            return "Next"
        case .finish:
            return "Finish"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .skip:
            return Colors.primaryYellow
        case .next, .finish:
            return Colors.primaryYellow
        }
    }
    
    var borderColor: UIColor {
        return Colors.primaryColor
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .skip:
            return 0.0
        case .next, .finish:
            return 0.0
        }
    }
    
}
