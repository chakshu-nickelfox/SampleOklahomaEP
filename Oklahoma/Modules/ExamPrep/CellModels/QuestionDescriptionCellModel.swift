//
//  QuestionDescriptionCellModel.swift
//  LifeSafetyEducator4
//
//  Created by Akanksha Trivedi on 19/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import Foundation

class QuestionDescriptionCellModel {
    
    private let question: QuestionResponse
    let questionSubTitle: String
    var attemptLabelHidden = true
    var currentAttempt: Int?
    var enableImmediateFeedbackForAnswers: Bool
    var enableStudyDeckForIncorrectAnswers: Bool
    
    init(_ question: QuestionResponse, 
         _ questionSubTitle: String,
         _ enableImmediateFeedbackForAnswers: Bool,
         _ enableStudyDeckForIncorrectAnswers: Bool) {
        self.question = question
        self.questionSubTitle = questionSubTitle
        self.enableImmediateFeedbackForAnswers = enableImmediateFeedbackForAnswers
        self.enableStudyDeckForIncorrectAnswers = enableStudyDeckForIncorrectAnswers
    }
    
    var index: String {
        return self.question.questionId
    }
    
    var text: String {
        return self.question.question
    }
    
    var options: [String] {
        return [self.question.answer0,
                self.question.answer1,
                self.question.answer2,
                self.question.answer3]
    }
    
    private var questionRefNumber: String {
        return "q.\(self.index)"
    }
    
    private var chapterRefNumber: String {
        return "Ch.\(self.question.chapterId)"
    }
    
    private var pageRefNumber: String {
        return "p.\(self.question.refPage)"
    }
    
    var referenceNumber: String {
        return self.chapterRefNumber + " - " + self.pageRefNumber + " - " + self.questionRefNumber
    }
    
    var correctAnswer: String {
        switch self.question.correctAnswer {
        case 0: return self.question.answer0
        case 1: return self.question.answer1
        case 2: return self.question.answer2
        case 3: return self.question.answer3
        default: return ""
        }
    }
    
    var isAnswered: Bool {
        return self.question.isCurrentAttempted
    }
    
    var isCorrect: Bool? {
        return self.question.isAnsweredCorrect
    }
    
    var isStudyDeckVisible: Bool {
        return self.isAnswered
    }
    
    var isStudyDeckEnabled: Bool {
        if self.enableImmediateFeedbackForAnswers {
            guard let isCorrect = self.isCorrect else {
                return false
            }
            return !isCorrect && self.enableStudyDeckForIncorrectAnswers
        }
        return false
    }
    
}
