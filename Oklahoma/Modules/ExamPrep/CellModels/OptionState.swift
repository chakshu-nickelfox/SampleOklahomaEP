//
//  OptionState.swift
//  LifeSafetyEducator4
//
//  Created by Vaibhav Parmar on 29/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

extension OptionState {
    
    var image: UIImage? {
        switch self {
        case .correct:
            return Image.ExamPrep.correctAnswer.image
        case .incorrect:
            return Image.ExamPrep.incorrectAnswer.image
        case .none, .unknown:
            return nil
        case .incorrectAttempt:
            return Image.ExamPrep.incorrectAnswer.image
        case .immediateCorrectAnswered:
            return nil
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .correct:
            return Colors.greenColor
        case .incorrect:
            return Colors.redColor
        case .unknown, 
                .immediateCorrectAnswered:
            return Colors.disabledGrey
        case .none:
            return UIColor(hex: 0x434342)
        case .incorrectAttempt:
            return .white
        }
    }
    
    var labelColor: UIColor {
        switch self {
        case .correct, 
                .incorrect,
                .unknown,
                .immediateCorrectAnswered:
            return .white
        case .none:
            return .white
        case .incorrectAttempt:
            return .black
        }
    }

}
