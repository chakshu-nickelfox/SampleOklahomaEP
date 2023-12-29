//
//  SheetActionType.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import ReactiveSwift

enum SheetActionType: String {
    
    case deleteAll = "Delete All"
    case downloadAll = "Download All"
    case clearTestResults = "Clear Test Results"
    case clearStudyDeck = "Clear Study Deck"
    
    var isAccessible: Bool {
        switch self {
        case .downloadAll:
            return true
        default:
            return true
        }
    }
    
}

struct SheetOption {
    static let audiobookOptions = [SheetActionType.downloadAll,
                                   SheetActionType.deleteAll]
    static let examPrepOptions = [SheetActionType.clearTestResults,
                                  SheetActionType.clearStudyDeck]
}

protocol MenuSheetViewModelDelegate: AnyObject {
    func reloadSheet()
    func didTapDeleteAll()
    func didTapDownloadAll()
    func reports(available: Bool)
    func studyDeckChapters(available: Bool)
}

class MenuSheetViewModel {
    
    private var sectionModels = MutableProperty<[SectionModel]>([])
    weak var view: MenuSheetViewModelDelegate!
    var disposable = CompositeDisposable([])
    var menuOptions: [SheetActionType]
    
    init(_ view: MenuSheetViewModelDelegate,
         menuOptions: [SheetActionType]) {
        self.view = view
        self.menuOptions = menuOptions
//        self.setupObservers()
    }
    
    private func setupCellModels() {
        let menuCellModels = self.menuOptions.map({MenuTableViewCellModel($0)})
        let sectionModel = SectionModel(cellModels: menuCellModels)
        self.sectionModels.value.append(sectionModel)
        self.view?.reloadSheet()
    }
    
//    private func setupObservers() {
//        // look for change is connection
//        ReachabilityNotifier.isReachable.signal.observeValues { _ in
//            self.view?.reloadSheet()
//        }
//    }
    
}

// MARK: - MenuSheetViewControllerDelegate
extension MenuSheetViewModel: MenuSheetViewControllerDelegate {
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
    
    func didSelectRow(at indexPath: IndexPath) {
        let sheetTitle = self.menuOptions[indexPath.row].rawValue
        let actionType = SheetActionType(rawValue: sheetTitle)
        switch actionType {
        case .deleteAll:
            self.view?.didTapDeleteAll()
        case .downloadAll:
            self.view?.didTapDownloadAll()
        case .clearTestResults:
            self.checkReportsAvailable()
        case .clearStudyDeck:
            self.checkChapterInStudyDesk()
        case .none:
            return
        }
    }
    
    func loadSheetOptions() {
        self.setupCellModels()
    }
    
    func clearAllReports() {
        ExamManager.clearTestResults()
    }
    func clearStudyDeck() {
        ExamManager.clearStudyDesk()
    }
}

// MARK: - exam prep menu actions


extension MenuSheetViewModel {
    func checkReportsAvailable() {
        
        var reportsAvailable = false
        let questions = ExamManager.getAllQuestions()
        for question in questions where ExamPrepHelper.getQuestionType(with: question.questionType) == .attempted {
            reportsAvailable = true
        }
        
        if reportsAvailable {
            self.view?.reports(available: true)
        } else {
            self.view?.reports(available: false)
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

class MenuTableViewCellModel {
    
    private var option: SheetActionType
    
    init(_ option: SheetActionType) {
        self.option = option
    }
    
    var  title: String {
        return self.option.rawValue
    }
    
    var isAccessible: Bool {
        return self.option.isAccessible
    }
    
}
