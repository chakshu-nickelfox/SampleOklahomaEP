//
//  ReportsViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit
import FLUtilities

protocol ReportsViewControllerDelegate: AnyObject {
    var sectionCount: Int { get }
    func rows(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> Any
    func didSelectRow(at indexPath: IndexPath)
    func loadChapters()
    var selectedChapters: [ChapterCellModel] { get }
}

class ReportsViewController: UIViewController {
    
    @IBOutlet weak var chapterReportsTableView: UITableView!
    var viewModel: ReportsViewControllerDelegate!

    static var newInstance: ReportsViewController? {
        let sb = UIStoryboard.init(name: Storyboard.examPrep.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? ReportsViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constant.ExamPrep.viewReports
        self.setupViewModel()
        self.setupTableView()
    }

    private func setupViewModel() {
        if self.viewModel == nil {
            self.viewModel = ReportsViewModel(self)
        }
        self.viewModel.loadChapters()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func infoButtonAction(_ sender: Any) {
//        guard let infoVC = InfoViewController.newInstance else { return }
//        self.navigationController?.present(infoVC, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ReportsViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func setupTableView() {
        self.chapterReportsTableView.delegate = self
        self.chapterReportsTableView.dataSource = self
        self.chapterReportsTableView.registerCell(ChapterReportCell.self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
       return self.viewModel.rows(in: section)
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ChapterReportCell.defaultReuseIdentifier
        ) as? TableViewCell else {  return UITableViewCell() }
        
        cell.item = self.viewModel.item(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        self.viewModel.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

// MARK: - ReportsViewModelDelegate
extension ReportsViewController: ReportsViewModelDelegate {
    
    func reload() {
        self.chapterReportsTableView.reloadData()
    }
    
    func goToSettings() {
        guard let examSettingsVc = ExamSettingsViewController.newInstance else { return }
        let viewModel = ExamSettingsViewModel(examSettingsVc)
        viewModel.selectedPracticeChapters = self.viewModel.selectedChapters
        examSettingsVc.viewModel = viewModel
        self.navigationController?.pushViewController(examSettingsVc, animated: true)
    }
    
}
