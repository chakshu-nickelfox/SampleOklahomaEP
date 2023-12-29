//
//  QuestionResponse.swift
//  LifeSafetyEducator4
//
//  Created by Akanksha Trivedi on 19/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import Foundation

class QuestionResponse: Comparable {
    
    static func < (lhs: QuestionResponse, rhs: QuestionResponse) -> Bool {
        return lhs.qID == rhs.qID
    }
    
    var id: Int
    var isStudyDeckEnabled: Bool
    var isCurrentAttempted: Bool
    var isAnsweredCorrect: Bool
    var incorrectAnswer: String
    var question: String
    var correctAnswer: Int
    var chapterId: Int
    var refPage: String
    var questionId: String
    var answer0: String
    var answer1: String
    var answer2: String
    var answer3: String
    var isSkipped: Bool
    var qID: String
    
    init(id: Int,
         isStudyDeckEnabled: Bool,
         isCurrentAttempted: Bool,
         isAnsweredCorrect: Bool,
         incorrectAnswer: String,
         question: String,
         correctAnswer: Int,
         chapterId: Int,
         refPage: String,
         questionId: String,
         answer0: String,
         answer1: String,
         answer2: String,
         answer3: String,
         isSkipped: Bool,
         qID: String) {
        self.id = id
        self.isStudyDeckEnabled = isStudyDeckEnabled
        self.isCurrentAttempted = isCurrentAttempted
        self.isAnsweredCorrect = isAnsweredCorrect
        self.incorrectAnswer = incorrectAnswer
        self.question = question
        self.correctAnswer = correctAnswer
        self.chapterId = chapterId
        self.refPage = refPage
        self.questionId = questionId
        self.answer0 = answer0
        self.answer1 = answer1
        self.answer2 = answer2
        self.answer3 = answer3
        self.isSkipped = isSkipped
        self.qID = qID
    }
    
    static func == (lhs: QuestionResponse, rhs: QuestionResponse) -> Bool {
        return lhs.qID == rhs.qID
    }
    
}
