//
//  ChapterCellModel.swift
//  LifeSafetyEducator4
//
//  Created by Akanksha Trivedi on 19/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import Foundation

class ChapterCellModel {
    
    private let chapter: Chapter
    var isSelected = false
    var isHidden: Bool = true
    var navigationType = NavigationType.practiceExam
    
    init(_ chapter: Chapter, 
         _ navigationType: NavigationType?,
         isHidden: Bool?,
         isSelected: Bool,
         selectionType: ExamPrepButtonType?) {
        self.chapter = chapter
        self.navigationType = navigationType ?? .practiceExam
        if selectionType == .enableSelection {
            self.isHidden = false
        } else {
            self.isHidden = isHidden ?? true
        }
        self.isSelected = isSelected
    }
    
    var isAddedToStudyDeck: Bool {
        return self.chapter.studyDeckQuestions == 0
    }
    
    var isAccessible: Bool {
        return self.chapter.purchaseState == PurchaseState.paid.rawValue
    }
    
    var chapterId: String {
        return "Chapter \(self.chapter.chapterId)"
    }
    
    var chapterIntID: Int {
        return self.chapter.chapterId
    }
    
    var chapterName: String {
        return self.chapter.chapterName
    }
    
    var isPurchased: PurchaseState {
        print("states are ", self.chapter.purchaseState)
        return PurchaseState(rawValue: self.chapter.purchaseState)!
    }
    
    var practiceQuestions: [PracticeQuestion] {
        return []
    }
    
    var studyDeckQuestions: [PracticeQuestion] {
        return []
    }
    
    var numberOfQuestions: String {
        var questionsCount = 0
        if self.navigationType == .practiceExam {
            questionsCount = self.numberOfPracticeQuestions
        } else {
            questionsCount = self.numberOfStudyDeckQuestions
        }
        return "Questions: " + String(questionsCount)
    }
    
    var numberOfPracticeQuestions: Int {
        return ExamManager.getQuestionsForChapter(forChapter: self.chapterIntID).count
    }
    
    var numberOfStudyDeckQuestions: Int {
        return ExamManager.getStudyDeckCount(forChapter: self.chapterIntID)
    }
    
    var chapterScore: String {
        let percentage: Double = Double(self.correctAnswers) * 100 / Double(self.numberOfPracticeQuestions)
        return String(format: "%.1f", percentage) + "%"
    }
    
    var chapterProgress: Float {
        let percentage: Double = Double(self.correctAnswers) * 100 / Double(self.numberOfPracticeQuestions)
        return Float(percentage) / 100
    }
    
    private var correctAnswers: Int {
        let questions = ExamManager.getQuestionsForChapter(forChapter: self.chapterIntID)
        return questions.filter { $0.didAnswerCorrect }.count
    }
    
}
