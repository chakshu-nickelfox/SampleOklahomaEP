//
//  ExamSettingsViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import ReactiveSwift

protocol ExamSettingsViewModelDelegate: AnyObject {
    func updateSliderFor(minCount: Int, maxCount: Int)
    func navigateToQuiz()
}

class ExamSettingsViewModel {
    
    var disposable = CompositeDisposable([])
    var selectedPracticeChapters = [ChapterCellModel]()
    var navigationType = NavigationType.practiceExam
    var questionEntities = [PracticeQuestion]()
    var getTotalQuestions = 0
    var attemptingQuestions = [ChapterCellModel]()
    
    weak var view: ExamSettingsViewModelDelegate!
    
    init(_ view: ExamSettingsViewModelDelegate) {
        self.view = view
    }
    
    func fetchPracticeQuestions() {
        self.getQuestionsAndCount(from: selectedPracticeChapters)
    }
    
    func fetchQuestions() {
        var selectedRows = [Int]()
        self.selectedPracticeChapters.forEach { selectedRows.append($0.chapterIntID) }
        self.fetchAllQuestionEntitiesForNewExam(selectRows: selectedRows,
                                                isExamPrep: self.navigationType == .practiceExam,
                                                questionsCount: DataModel.shared.maximumQuestionsToAttempt)
    }
    
    func fetchAllQuestionEntitiesForNewExam(selectRows: [Int],
                                            isExamPrep: Bool,
                                            questionsCount: Int) {
        DispatchQueue.main.async {
            let totalQuestion = ExamManager.getAllQuestions()
            var questionArray = [PracticeQuestion]()
            if isExamPrep {
                for chapterID in selectRows {
                    for qEntity in totalQuestion where chapterID == qEntity.chapterID {
                        questionArray.append(qEntity)
                    }
                }
            } else {
                // study deck
                for chapterID in selectRows {
                    for qEntity in totalQuestion {
                        if chapterID == qEntity.chapterID && qEntity.inStudyDeck {
                            questionArray.append(qEntity)
                        }
                    }
                }
            }
            
            self.questionEntities = questionArray.shuffled()
            self.view.navigateToQuiz()
            
            var duplicates = [String: Int]()
            self.questionEntities.forEach { quest in
                duplicates[quest.qID] = (duplicates[quest.qID] ?? 0) + 1
            }
        }
    }
    
    func getTotalQuestions(selectRows: Set<Int16>, examPrep: Bool) {
        DispatchQueue.main.async {
            var totalQuestions = 0
            if examPrep {
                for item in ExamManager.getAllChapters() {
                    for id in selectRows where item.chapterId == id {
                        totalQuestions += Int(ExamManager.getQuestionsForChapter(forChapter: item.chapterId).count)
                    }
                }
                
            } else {
                for item in selectRows {
                    for id in ExamManager.getAllQuestions() {
                        if id.chapterID == item && id.inStudyDeck {
                            totalQuestions += 1
                        }
                    }
                }
            }
            DataModel.shared.maximumQuestionsToAttempt = totalQuestions
            self.getTotalQuestions = totalQuestions
            self.view?.updateSliderFor(minCount: self.minQuestionsCount, maxCount: totalQuestions)
        }
        
    }
    
    private func getQuestionsAndCount(from chapters: [ChapterCellModel]) {
        var selectedRows = Set<Int16>()
        chapters.forEach { chap in
            selectedRows.insert(Int16(chap.chapterIntID))
        }
        self.getTotalQuestions(
            selectRows: selectedRows,
            examPrep: self.navigationType == .practiceExam ? true : false)
    }
    
}

// MARK: - ExamSettingsViewControllerDelegate
extension ExamSettingsViewModel: ExamSettingsViewControllerDelegate {
    
    func save(attemptSelected: Int) {
        DataModel.shared.perQuestionAttempt = attemptSelected
    }
    
    var maxQuestionsCount: Int {
        return self.getTotalQuestions
    }
    
    var minQuestionsCount: Int {
        return 1
    }
    
    func didUpdateMaxQuestionCount(_ maxCount: Int) {
        DataModel.shared.maximumQuestionsToAttempt = maxCount
    }
    
    func didUpdateImmediateFeedbackState(_ enable: Bool) {
        DataModel.shared.enableImmediateFeedbackForAnswers = enable
    }
    
    func didUpdateAddToStudyDeckState(_ enable: Bool) {
        DataModel.shared.enableStudyDeckForIncorrectAnswers = enable
    }
    
    var attemptSelected: Int {
        return DataModel.shared.perQuestionAttempt
    }
    
    var enableImmediateFeedback: Bool {
        return DataModel.shared.enableImmediateFeedbackForAnswers
    }
    
    var enableStudyDeck: Bool {
        return DataModel.shared.enableStudyDeckForIncorrectAnswers
    }
    
}
