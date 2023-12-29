//
//  ChapterListViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import ReactiveSwift

protocol ChapterListViewModelDelegate: AnyObject {
    func reloadData()
    func updateSelectedChaptersCount(count: String)
    func updateTotalChaptersCount(count: String)
    func didUpdateSelectionTitle( _ title: String)
}

class ChapterListViewModel {
    
    private var sectionModels = MutableProperty<[SectionModel]>([])
    var disposable = CompositeDisposable([])
    var navigationType = NavigationType.practiceExam
    var isSomeChapterSelected = MutableProperty(false)
    var isAllChaptersSelected = MutableProperty(false)
    var chapterCellModels = [ChapterCellModel]()
    var attemptingSelectedChapters = [ChapterCellModel]()
    var selectedChaptersCount = 0
    var chapters = ExamManager.getAllChapters()
    var selectionModel = MutableProperty<ExamPrepButtonType?>(.none)
    
    weak var view: ChapterListViewModelDelegate!
    
    init(_ view: ChapterListViewModelDelegate) {
        self.view = view
    }
    
    private func setupCellModels() {
        var allChapters: [Any] = []
        self.sectionModels.value.removeAll()
        
        switch self.navigationType {
        case .practiceExam:
            self.chapterCellModels = chapters.map {
                ChapterCellModel($0,
                                 self.navigationType,
                                 isHidden: true,
                                 isSelected: false,
                                 selectionType: self.selectionModel.value)
            }
        case .studyDeck:
            for chapter in chapters {
                let questions = ExamManager.getAllQuestions()
                let attemptedQuestions = questions.filter { $0.chapterID == chapter.chapterId }
                let studyDeckQuestionsCount = attemptedQuestions.filter { $0.inStudyDeck }.count
                if studyDeckQuestionsCount > 0 {
                    let chapterCellModel = ChapterCellModel(chapter, self.navigationType,
                                                            isHidden: true,
                                                            isSelected: false,
                                                            selectionType: .unselect)
                    self.chapterCellModels.append(chapterCellModel)
                }
            }
        }
        self.view.updateTotalChaptersCount(count: "\(self.chapterCellModels.count)")
        
        let paidChapters = self.chapterCellModels.filter({$0.isPurchased == .paid})
        let unpaidChapters = self.chapterCellModels.filter({$0.isPurchased == .notPaid})
        
        if unpaidChapters.isEmpty {
            allChapters.append(ChapterHeaderCellModel(totalCount: self.chapterCellModels.count,
                                                      selectedCount: self.selectedChaptersCount,
                                                      type: selectionModel.value))
            allChapters.append(contentsOf: paidChapters)
        } else {
            allChapters.append(contentsOf: paidChapters)
            allChapters.append(ChapterHeaderCellModel(totalCount: unpaidChapters.count,
                                                      selectedCount: self.selectedChaptersCount,
                                                      type: .buy))
            allChapters.append(contentsOf: unpaidChapters)
        }
        self.sectionModels.value.append(SectionModel(cellModels: allChapters))
        self.view?.reloadData()
    }
    
    func updatePurchaseStatus() {
        ExamManager.updateChapterPurchaseStatus()
    }
}

// MARK: ChapterListViewController Delegate Methods
extension ChapterListViewModel: ChapterListViewControllerDelegate {
    
    func didTapEnableSection() {
        self.selectionModel.value = .enableSelection
        self.didTapSelectAll(false)
    }
    
    func didFinishPurchasingOrRestoring() {
        ExamManager.updateChapterPurchaseStatus()
        self.loadChapters()
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
    
    fileprivate func setHeaderChapterCountLabelsText(_ selectedChapters: [ChapterCellModel], _ model: ChapterHeaderCellModel) {
        let selectedChaptersCount = String(format: "%d %@", selectedChapters.count, Constant.selected)
        let selectedChaptersString = self.isAllChaptersSelected.value ? Constant.allSelected : selectedChaptersCount
        model.selectedCount = selectedChapters.isEmpty ? "" : selectedChaptersString
    }
    
    fileprivate func setModelType(_ selectedChapters: [ChapterCellModel],
                                  _ model: ChapterHeaderCellModel) {
        // Note: Added to hide All selected label
        switch self.navigationType {
        case .practiceExam:
            if !DataModel.shared.isExamPrepPurchased && selectedChapters.count == 1 {
                model.selectedCount = ""
            } else {
                self.setHeaderChapterCountLabelsText(selectedChapters, model)
            }
            
            if isAllChaptersSelected.value {
                model.type = DataModel.shared.isExamPrepPurchased ? .unselect : .buy
            } else if !isAllChaptersSelected.value && !self.isSomeChapterSelected.value {
                model.type = DataModel.shared.isExamPrepPurchased ? .selectAll : .buy
            } else if !self.isSomeChapterSelected.value {
                model.type = DataModel.shared.isExamPrepPurchased ? .unselect : .buy
            } else {
                model.type = DataModel.shared.isExamPrepPurchased ? .selectAll : .buy
            }
        case .studyDeck:
            self.setHeaderChapterCountLabelsText(selectedChapters, model)
            
            if isAllChaptersSelected.value {
                model.type = .unselect
            } else if !isAllChaptersSelected.value && !self.isSomeChapterSelected.value {
                model.type = .selectAll
            } else if !self.isSomeChapterSelected.value {
                model.type = .unselect
            } else {
                model.type = .selectAll
            }
        }
    }
    
    func didSelect(at indexPath: IndexPath) {
        
        // Filter out purchased chapters
        guard let model = self.cellModel(at: indexPath) as? ChapterCellModel,
              let chapterCellModels = self.sectionModels.value.first?.cellModels
            .filter({ ($0 as? ChapterCellModel)?.isPurchased == .paid }) as? [ChapterCellModel]
        else { return }
        
        model.isSelected = !model.isSelected
        
        // if chapter is alreday added to selected chapters list, remove it else add it
        if let index = self.attemptingSelectedChapters.firstIndex(where: {$0.chapterId == model.chapterId}) {
            self.attemptingSelectedChapters.remove(at: index)
        } else {
            if !self.attemptingSelectedChapters.contains(where: {$0.chapterId == model.chapterId}) {
                self.attemptingSelectedChapters.append(model)
            }
        }
        
        // update all and some selected count based on selected chapters
        let selectedChapters = chapterCellModels.filter({$0.isSelected})
        self.isSomeChapterSelected.value =  !selectedChapters.isEmpty
        self.isAllChaptersSelected.value = selectedChapters.count == chapterCellModels.count
        
        chapterCellModels.forEach {
            $0.isHidden = false // isSelected ? false : true
        }
        self.view.updateSelectedChaptersCount(count: "\(selectedChapters.count)")
        if let model = self.sectionModels.value.first?.cellModels.filter({ $0 is ChapterHeaderCellModel }).first as? ChapterHeaderCellModel {
            self.setModelType(selectedChapters, model)
        }
        self.view?.reloadData()
    }
    
    func didTapSelectAll(_ selected: Bool) {
        self.attemptingSelectedChapters.removeAll()
        guard let chapterCellModels = self.sectionModels.value.first?.cellModels
            .filter({ ($0 as? ChapterCellModel)?.isPurchased == .paid}) as? [ChapterCellModel]
        else { return }
        
        chapterCellModels.forEach({ chapter in
            if chapter.isAccessible == true {
                chapter.isSelected = selected
                chapter.isHidden = false
            }
        })
        self.view.updateSelectedChaptersCount(count: "\(chapterCellModels.count)")
        // if button state is 'selected' true, added all to selected chapters list, else remove all from the list
        if selected {
            self.attemptingSelectedChapters.append(contentsOf: chapterCellModels)
        } else {
            self.attemptingSelectedChapters.removeAll()
        }
        self.isSomeChapterSelected.value = selected
        self.isAllChaptersSelected.value = selected
        
        if let model = self.sectionModels.value.first?.cellModels.filter({ $0 is ChapterHeaderCellModel }).first as? ChapterHeaderCellModel {
            if self.selectionModel.value == .enableSelection {
                model.selectedCount = ""
                model.type = .selectAll
                self.selectionModel.value = .selectAll
            } else {
                model.selectedCount = !selected ? "" :
                (self.isAllChaptersSelected.value ? Constant.allSelected :
                    "\(attemptingSelectedChapters.count) \(Constant.selected)")
                if model.type == .selectAll {
                    model.type = .unselect
                } else {
                    model.type = .selectAll
                }
            }
        }
        self.view?.reloadData()
    }
    
    func loadChapters() {
        self.attemptingSelectedChapters.removeAll()
        self.selectionModel.value = .none
        self.isSomeChapterSelected.value = false
        self.isAllChaptersSelected.value = false
        self.chapterCellModels.removeAll()
        self.updatePurchaseStatus()
        self.setupCellModels()
    }
    
}
