//
//  ExamResultViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import ReactiveSwift

protocol ExamResultViewModelDelegate: AnyObject, BaseViewModelProtocol {
    func reloadUI()
    func quitResults()
}

class ExamResultViewModel {
    
    private var sectionModels = MutableProperty<[SectionModel]>([])
    var disposable = CompositeDisposable([])
    var attemptedPracticeQuestions = [QuestionResponse]()
    var attemptedQuestionsCount = MutableProperty<String>("")
    var correctQuestionsCount = MutableProperty<String>("")
    var incorrectQuestionsCount = MutableProperty<String>("")
    var resultPercentage = MutableProperty<Double>(0.0)
    var correctPercentage = MutableProperty<Double>(0.0)
    var incorrectPercentage = MutableProperty<Double>(0.0)
    var skippedPercentage = MutableProperty<Double>(0.0)
    var selectedQuestions: [QuestionResponse]
    var skippedQuestionsCount = MutableProperty<String>("")

    weak var view: ExamResultViewModelDelegate!
    
    init(_ view: ExamResultViewModelDelegate,
         selectedQuestions: [QuestionResponse]) {
        self.view = view
        self.selectedQuestions = selectedQuestions
    }
    
    private func setupSectionModels() {
        self.sectionModels.value.removeAll()
        let resultsCells = self.selectedQuestions.filter { question in
            return !(!question.isSkipped && !question.isCurrentAttempted)
        }
        let resultCellModels = resultsCells.map {
            QuestionResultCellModel($0, DataModel.shared.enableImmediateFeedbackForAnswers)
        }
        let sectionModel = SectionModel(cellModels: resultCellModels)
        self.sectionModels.value.append(sectionModel)
        self.view.reloadUI()
    }
    
    private func getSelectedQuestions() {
        // Attempted Questions
        self.attemptedPracticeQuestions = self.selectedQuestions.filter({ question in
            return question.isCurrentAttempted
        })
        var filteredQuestions: [QuestionResponse] = []
        self.attemptedPracticeQuestions.forEach { question in
            if !filteredQuestions.contains(where: { $0.qID == question.qID }) {
                filteredQuestions.append(question)
            }
        }
        
        // Skipped Questions
        let skippedQuestions = self.selectedQuestions.filter { question in
            return question.isSkipped
        }
       // self.attemptedPracticeQuestions = filteredQuestions
        DataModel.shared.resultTotalQuestions = self.attemptedPracticeQuestions.count + skippedQuestions.count
        // self.selectedQuestions.count
        self.attemptedQuestionsCount.value = String(self.attemptedPracticeQuestions.count)
        // Correct Questions
        let correctQuestions = self.attemptedPracticeQuestions.filter { question in
            return question.isAnsweredCorrect
        }
        DataModel.shared.resultCorrectQuestions = correctQuestions.count
        self.correctQuestionsCount.value = String(correctQuestions.count)
        // Incorrect Questions
        let incorrectQuestions = self.attemptedPracticeQuestions.filter { question in
            return !question.isAnsweredCorrect
        }
        DataModel.shared.resultIncorrectQuestions = incorrectQuestions.count
        self.incorrectQuestionsCount.value = String(incorrectQuestions.count)
        self.skippedQuestionsCount.value = String(skippedQuestions.count)
        
        let totalInteractedQuestions = skippedQuestions.count + incorrectQuestions.count + correctQuestions.count
        if !self.attemptedPracticeQuestions.isEmpty {
            self.resultPercentage.value = Double(Double(correctQuestions.count * 100)
                                                 / Double(self.attemptedPracticeQuestions.count))
            
            self.correctPercentage.value = Double(Double(correctQuestions.count * 100)
                                                  / Double(totalInteractedQuestions))
            
            
            self.incorrectPercentage.value = Double(Double(incorrectQuestions.count * 100)
                                                    / Double(totalInteractedQuestions))
            
            self.skippedPercentage.value = Double(Double(skippedQuestions.count * 100)
                                                  / Double(totalInteractedQuestions))
            
        } else { // All questions are skipped
            self.resultPercentage.value = 0.0
            self.skippedPercentage.value = Double(Double(skippedQuestions.count * 100)
                                                  / Double(totalInteractedQuestions))
        }
        DataModel.shared.resultPercentage = Double(Double(correctQuestions.count * 100)
                                                    / Double(self.attemptedPracticeQuestions.count))
        
        self.setupSectionModels()
    }

}

extension ExamResultViewModel: ExamResultViewControllerDelegate {
    
    func didTapAddToStudyDeck(for chapterID: Int,
                              qID: String,
                              isStudyDeckEnabled: Bool) {
        ExamManager.addQuestionToStudyDesk(chapterId: chapterID,
                                           qID: qID,
                                           addToStudyDeck: isStudyDeckEnabled)
    }
    
    var sectionCount: Int {
        self.sectionModels.value.count
    }
    
    func rowCount(at section: Int) -> Int {
        self.sectionModels.value[section].cellModels.count
    }
    
    func section(at index: Int) -> SectionModel {
        self.sectionModels.value[index]
    }
    
    func cellModel(at indexPath: IndexPath) -> Any {
        return self.sectionModels.value[indexPath.section].cellModels[indexPath.row]
    }

    func loadExamResults() {
        self.getSelectedQuestions()
        
    }
    
    func didTapQuitResults() {
        self.view?.quitResults()
    }
    
}
