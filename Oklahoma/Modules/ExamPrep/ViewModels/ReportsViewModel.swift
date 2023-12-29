//
//  ReportsViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

protocol ReportsViewModelDelegate: AnyObject, BaseViewModelProtocol {
    func reload()
    func goToSettings()
}

class ReportsViewModel {
    
    private(set) var sectionModels = MutableProperty<[SectionModel]>([])
    var selectedChapters = [ChapterCellModel]()
    var ok: Int = 0
    
    weak var view: ReportsViewModelDelegate?
    
    init(_ view: ReportsViewModelDelegate) {
        self.view = view
    }
    
    private func setupCellModels(_ chapters: [Chapter]) {
        self.sectionModels.value.removeAll()
        let chapterCellModels = chapters.map {
            ChapterCellModel($0,
                             .practiceExam,
                             isHidden: true,
                             isSelected: false,
                             selectionType: .unselect)
        }
        let paidChapters = chapterCellModels.filter {$0.isPurchased == .paid}
        let paidSectionModel = SectionModel(cellModels: paidChapters)
        
        self.sectionModels.value.append(paidSectionModel)
        
        let unPaidChapters = chapterCellModels.filter({$0.isPurchased == .notPaid})
        if !unPaidChapters.isEmpty {
            let unPaidSectionModel = SectionModel(cellModels: unPaidChapters)
            self.sectionModels.value.append(unPaidSectionModel)
        }
        self.view?.reload()
    }
    
}

// MARK: - View Controller Functions

extension ReportsViewModel: ReportsViewControllerDelegate {
    
    var sectionCount: Int {
        self.sectionModels.value.count
    }
    
    func rows(in section: Int) -> Int {
        self.sectionModels.value[section].cellModels.count
    }
    
    func item(at indexPath: IndexPath) -> Any {
        self.sectionModels.value[indexPath.section].cellModels[indexPath.row]
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        self.selectedChapters.removeAll()
        guard let model = self.item(at: indexPath) as? ChapterCellModel else { return }
        self.selectedChapters.append(model)
        self.view?.goToSettings()
    }
    
    func loadChapters() {
        DispatchQueue.main.async {
            let chapterTitleEntities = ExamManager.getAllChapters()
            
            self.setupCellModels(chapterTitleEntities)
        }
    }
    
}
