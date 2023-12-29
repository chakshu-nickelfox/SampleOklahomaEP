//
//  ChapterListViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import UIKit
import ReactiveSwift

protocol ChapterListViewControllerDelegate: AnyObject {
    var disposable: CompositeDisposable { get }
    var sectionCount: Int { get }
    var navigationType: NavigationType { get }
    var isSomeChapterSelected: MutableProperty<Bool> { get }
    var isAllChaptersSelected: MutableProperty<Bool> { get }
    var attemptingSelectedChapters: [ChapterCellModel] { get set }
    
    func rowCount(at section: Int) -> Int
    func section(at index: Int) -> SectionModel
    func cellModel(at indexPath: IndexPath) -> Any
    func didSelect(at indexPath: IndexPath)
    func didTapSelectAll(_ selected: Bool)
    func didFinishPurchasingOrRestoring()
    func loadChapters()
    func didTapEnableSection()
}

class ChapterListViewController: UIViewController {
    
    @IBOutlet weak var chaptersTableView: UITableView!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var totalExamsCountLabel: UILabel!
    @IBOutlet weak var selectedExamsCountLabel: UILabel!
    @IBOutlet weak var titleButton: UIButton!
    
    static var newInstance: ChapterListViewController? {
        let sb = UIStoryboard.init(name: Storyboard.examPrep.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? ChapterListViewController
        return vc
    }
    
    var viewModel: ChapterListViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.loadChapters()
    }
    
    private func initialSetup() {
        self.nextButton.isHidden = true
        if self.viewModel == nil {
            self.viewModel = ChapterListViewModel(self)
        }
        self.setupObservers()
        self.setupTableView()
        self.selectedExamsCountLabel.isHidden = true
        self.selectAllButton.isHidden = true
        self.titleButton.setTitle(viewModel.navigationType.typeTitle, for: .normal)
        self.viewModel.loadChapters()
    }
    
    private func setupObservers() {
        self.viewModel.isSomeChapterSelected.signal.observeValues { [weak self] selected in
            guard let self = self else { return }
            self.nextButton.isHidden = !selected
            self.nextButton.isSelected = selected
            if selected {
                self.selectAllButton.isHidden = false
                self.selectAllButton.setTitle("Select All", for: .normal)
                self.selectedExamsCountLabel.isHidden = false
            } else {
                self.selectedExamsCountLabel.isHidden = true
                self.selectAllButton.isHidden = true
            }
        }
        self.viewModel.isAllChaptersSelected.signal.observeValues { [weak self] selected in
            self?.selectAllButton.isSelected = selected
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectAllButtonAction(_ sender: UIButton) {
        if !self.selectAllButton.isHidden {
            self.selectedExamsCountLabel.isHidden = false
            sender.isSelected = !sender.isSelected
            self.viewModel.didTapSelectAll(sender.isSelected)
        }
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        guard let examSettingsVc = ExamSettingsViewController.newInstance else { return }
        let viewModel = ExamSettingsViewModel(examSettingsVc)
        viewModel.selectedPracticeChapters = self.viewModel.attemptingSelectedChapters
        viewModel.navigationType = self.viewModel.navigationType
        examSettingsVc.viewModel = viewModel
        self.navigationController?.pushViewController(examSettingsVc, animated: true)
    }
    
}

// MARK: - UITableViewDelegate
extension ChapterListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.didSelect(at: indexPath)
    }
    
}

// MARK: - UITableViewDataSource
extension ChapterListViewController: UITableViewDataSource {
    
    private func setupTableView() {
        self.chaptersTableView.delegate = self
        self.chaptersTableView.dataSource = self
        self.chaptersTableView.estimatedRowHeight = self.view.bounds.height / 2
        self.chaptersTableView.rowHeight = UITableView.automaticDimension
        self.chaptersTableView.estimatedSectionHeaderHeight = 100
        self.chaptersTableView.sectionHeaderHeight = UITableView.automaticDimension
        self.chaptersTableView.registerCell(ChapterTableViewCell.self)
        self.chaptersTableView.registerCell(ChapterHeaderCell.self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rowCount(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        guard let cellIdentifier = self.reusableIdentifiers(at: indexPath),
              let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.item = self.viewModel.cellModel(at: indexPath)
        cell.delegate = self
        return cell
    }
    
    private func reusableIdentifiers(at indexPath: IndexPath) -> String? {
        let cellModel = self.viewModel.cellModel(at: indexPath)
        switch cellModel {
        case is ChapterCellModel:
            return ChapterTableViewCell.defaultReuseIdentifier
        case is ChapterHeaderCellModel:
            return ChapterHeaderCell.defaultReuseIdentifier
        default:
            return nil
        }
    }
    
}

// MARK: - ChapterListViewModelDelegate
extension ChapterListViewController: ChapterListViewModelDelegate {
    
    func didUpdateSelectionTitle(_ title: String) {
        reloadData()
    }
    
    func updateTotalChaptersCount(count: String) {
        if let intCount = Int(count) {
            if intCount < 2 {
                self.totalExamsCountLabel.text = count + " Exam"
            } else {
                self.totalExamsCountLabel.text = count + " Exams"
            }
        }
    }
    
    func updateSelectedChaptersCount(count: String) {
        self.selectedExamsCountLabel.text = count + " Selected"
    }
    
    func reloadData() {
        self.chaptersTableView.reloadData()
    }
    
}

// MARK: - IAPViewControllerDelegate
extension ChapterListViewController: IAPViewControllerDelegate {
    func updatePurchase(view: IAPViewController, success: Bool, module: SubModule) {
        if module == .examPrep && success == true {
            self.viewModel.didFinishPurchasingOrRestoring()
        }
    }
    
    func updateRestore(view: IAPViewController, success: Bool) {
        if success {
            self.viewModel.didFinishPurchasingOrRestoring()
        }
    }
}

// MARK: - ChapterHeaderCellDelegate
extension ChapterListViewController: ChapterHeaderCellDelegate {
    
    func didTapButton(type: ExamPrepButtonType?) {
        guard let type = type else {
            self.viewModel.didTapEnableSection()
            return
        }
        switch type {
        case .buy:
            guard let iapVc = IAPViewController.newInstance else { return }
            iapVc.delegate = self
            iapVc.module = .examPrep
            let nav = UINavigationController(rootViewController: iapVc)
            nav.modalPresentationStyle = .overFullScreen
            present(nav, animated: true, completion: nil)
        case .unselect:
            self.viewModel.didTapSelectAll(false)
        case .selectAll:
            self.viewModel.didTapSelectAll(true)
        case .enableSelection:
            self.viewModel.didTapEnableSection()
        }
    }
    
}
