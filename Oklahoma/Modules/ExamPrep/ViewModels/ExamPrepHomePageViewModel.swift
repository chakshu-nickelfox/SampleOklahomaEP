//
//  ExamPrepHomePageViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import ReactiveSwift
import FLUtilities

protocol ExamPrepHomePageViewModelDelegate: AnyObject, BaseViewModelProtocol {
    func show(selectedList: ListType)
    func reports(available: Bool)
    func testReports(available: Bool)
    func studyDeckChapters(available: Bool)
}

class ExamPrepHomePageViewModel {
    
    var view: ExamPrepHomePageViewModelDelegate?
    var loading = MutableProperty<Bool>(false)
    var disposable = CompositeDisposable([])
    var allChapters = [Chapter]()
    
    private var cellModel = MutableProperty<[Any]>([])
    
    init(_ view: ExamPrepHomePageViewModelDelegate) {
        self.view = view
        ExamPrepHelper.checkForChaptersInitialisation()
    }
}

extension ExamPrepHomePageViewModel {
    
    func studyDeckAvailable() -> Bool {
        let questions = ExamManager.getAllQuestions().filter { question in
            return question.inStudyDeck
        }
        return !questions.isEmpty
    }
    
}

// MARK: - ExamPrepHomePageViewControllerDelegate
extension ExamPrepHomePageViewModel: ExamPrepHomePageViewControllerDelegate {
    
    func reportsAvailable() -> Bool {
        ExamManager.reportAvailableForChapters()
    }
    
    func clearAllReports() {
        ExamManager.clearTestResults()
    }
    func clearStudyDeck() {
        ExamManager.clearStudyDesk()
    }
    
    func goto(viewController: ListType) {
        switch viewController {
            
        case .reports:
            if ExamManager.reportAvailableForChapters() {
                self.view?.show(selectedList: .reports)
            } else {
                self.view?.showAlert(title: "", message: Constant.ExamPrep.noReports)
            }
            
        case .studyDeckList:
            if self.studyDeckAvailable() {
                self.view?.show(selectedList: .studyDeckList)
            } else {
                self.view?.showAlert(title: "", message: Constant.ExamPrep.studyDeckEmpty)
            }
            
        case .examPrep:
            self.view?.show(selectedList: .examPrep)
            
        }
        
    }
    
}

extension ExamPrepHomePageViewModel {
    func checkReportsAvailable() {
        
        var reportsAvailable = false
        let questions = ExamManager.getAllQuestions()
        for question in questions where ExamPrepHelper.getQuestionType(with: question.questionType) == .attempted {
            reportsAvailable = true
        }
        let chapters = ExamManager.getAllChapters()
        for chapter in chapters where chapter.score > 0 {
            reportsAvailable = true
        }
        if reportsAvailable {
            self.view?.testReports(available: true)
        } else {
            self.view?.testReports(available: false)
        }
    }
    
    func checkChapterInStudyDesk() {
        var studyDeckChaptersAvailable = false
        let questions = ExamManager.getAllQuestions()
        for question in questions where question.inStudyDeck {
            studyDeckChaptersAvailable = true
        }
        if studyDeckChaptersAvailable {
            self.view?.studyDeckChapters(available: true)
        } else {
            self.view?.studyDeckChapters(available: false)
            
        }
    }
    
}
