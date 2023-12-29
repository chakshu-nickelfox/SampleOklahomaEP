//
//  QuestionActionCellModel.swift
//  LifeSafetyEducator4
//
//  Created by Akanksha Trivedi on 19/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

class QuestionActionCellModel {
    
    var actionType: QuestionActionType
    
    init(_ actionType: QuestionActionType) {
        self.actionType = actionType
    }
    
    var backgroundColor: UIColor {
        return self.actionType.backgroundColor
    }
    
    var borderWidth: CGFloat {
        return self.actionType.borderWidth
    }
    
    var borderColor: UIColor {
        return self.actionType.borderColor
    }
    
    var title: String {
        return self.actionType.title
    }
    
}
