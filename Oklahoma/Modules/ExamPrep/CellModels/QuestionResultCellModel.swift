//
//  QuestionResultCellModel.swift
//  LifeSafetyEducator4
//
//  Created by Akanksha Trivedi on 19/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//


import Foundation

class QuestionResultCellModel {
    
    private let question: QuestionResponse
    var enableImmediateFeedbackForAnswers: Bool
    
    init(_ question: QuestionResponse,
         _ enableImmediateFeedbackForAnswers: Bool) {
        self.question = question
        self.enableImmediateFeedbackForAnswers = enableImmediateFeedbackForAnswers
    }
    
    var isSkipped: Bool {
        !self.question.isCurrentAttempted
    }
    
    var questionId: Int {
        return self.question.id
    }
    
    var qID: String {
        self.question.qID
    }
    
    var chapterId: Int {
        self.question.chapterId
    }
    
    var questionText: String {
        return self.question.question
    }
    
    var correctAnswer: String {
        var answer = ""
        switch self.question.correctAnswer {
        case 0: answer = self.question.answer0
        case 1: answer = self.question.answer1
        case 2: answer = self.question.answer2
        case 3: answer = self.question.answer3
        default: ()
        }
        return "Correct: \(answer)"
    }
    
    var isAddedToStudyDeck: Bool {
        let question = ExamManager.getQuestionBy(id: self.question.qID)
        return question?.inStudyDeck ?? false
    }
    
    var incorrectAnswer: String {
        
        if self.enableImmediateFeedbackForAnswers {
            let incorrectAnswer = "Incorrect:  \(self.question.incorrectAnswer)"
            return self.question.incorrectAnswer.isEmpty ? "" : incorrectAnswer
        } else {
            if self.question.isAnsweredCorrect || self.question.incorrectAnswer.isEmpty {
                return ""
            } else {
                return "Incorrect:  \(question.incorrectAnswer)"
            }
        }
    }
    
    private var questionRefNumber: String {
        return "q.\(self.question.questionId)"
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
    
}
