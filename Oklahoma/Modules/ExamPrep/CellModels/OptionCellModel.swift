//
//  OptionCellModel.swift
//  LifeSafetyEducator4
//
//  Created by Akanksha Trivedi on 19/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

class OptionCellModel {
    
    private let option: String
    var state: OptionState
    var index: Int16
    var isAnimated = true
    
    init(_ option: String, 
         _ state: OptionState,
         _ index: Int16) {
        self.option = option
        self.state = state
        self.index = index
    }
    
    var text: String {
        return self.option
    }
    
    var backgroundColor: UIColor {
        return self.state.backgroundColor
    }
    
    var labelColor: UIColor {
        return self.state.labelColor
    }
    
    var isOptionImageHidden: Bool {
        return (self.state == .none) || (self.state == .unknown) || (self.state == .immediateCorrectAnswered)
    }

    var image: UIImage? {
        return self.state.image
    }
    
}
