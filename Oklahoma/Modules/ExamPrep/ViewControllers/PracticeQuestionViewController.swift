//
//  PracticeQuestionViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit
import ReactiveSwift

protocol PracticeQuestionViewControllerDelegate: AnyObject {
    var disposable: CompositeDisposable { get }
    var sectionCount: Int { get }
    var practiceQuestionsResponse: [QuestionResponse] { get set }

    func rowCount(at section: Int) -> Int
    func section(at index: Int) -> SectionModel
    func cellModel(at indexPath: IndexPath) -> Any
    func didSelect(at indexPath: IndexPath)
    func didTapQuestionActionButton()
    func loadQuestion()
    func didTapExitQuiz()
    func didTapAddToStudyDeck(_ selected: Bool)
}

class PracticeQuestionViewController: UIViewController {

    @IBOutlet weak var examQuestionTableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!

    static var newInstance: PracticeQuestionViewController? {
        let sb = UIStoryboard.init(name: Storyboard.examPrep.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? PracticeQuestionViewController
        return vc
    }
    
    var viewModel: PracticeQuestionViewControllerDelegate!

    override func viewDidLoad() {
        self.title = "Take Practice Exam"
        super.viewDidLoad()
        self.setupTableView()
        self.setupActionButton(model: QuestionActionCellModel(.skip))
        self.viewModel.loadQuestion()
    }
    
    func setupViewModel(_ practiceQuestions: [PracticeQuestion], navigationType: NavigationType) {
        if self.viewModel == nil {
            self.viewModel = PracticeQuestionViewModel(self, practiceQuestions, navigationType)
        }
    }
    
    func setupActionButton(model: QuestionActionCellModel) {
        self.actionButton.layer.borderColor = model.borderColor.cgColor
        self.actionButton.layer.borderWidth = model.borderWidth
        self.actionButton.backgroundColor = model.backgroundColor
        self.actionButton.setTitle(model.title, for: .normal)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.examQuestionTableView.performBatchUpdates(nil, completion: nil)
    }
    
    @IBAction func exitQuizAction(_ sender: UIButton) {
        self.viewModel.didTapExitQuiz()
    }
    
    @IBAction func questionActionButton(_ sender: UIButton) {
        self.viewModel.didTapQuestionActionButton()
    }

}

// MARK: - PracticeQuestionViewModelDelegate
extension PracticeQuestionViewController: PracticeQuestionViewModelDelegate {
    func loadNextQuestion() {
        self.examQuestionTableView.reloadData()
    }
    
    func reloadQuestion() {
        self.examQuestionTableView.reloadData()
    }
    
    func exitQuiz() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func showExamResults() {
        guard let resultVc = ExamResultViewController.newInstance else { return }
        var selectedQuestions = [QuestionResponse]()
        selectedQuestions = self.viewModel.practiceQuestionsResponse
        resultVc.setupViewModel(selectedQuestions: selectedQuestions)
        self.navigationController?.pushViewController(resultVc, animated: true)
    }
    
    func setActionButtonTitle() {
        self.actionButton.setTitle(Constant.AudioBook.checkResults, for: .normal)
    }
    
}

// MARK: - UITableViewDelegate
extension PracticeQuestionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            self.viewModel.didSelect(at: indexPath)
        }
    }
}

// MARK: - UITableViewDataSource
extension PracticeQuestionViewController: UITableViewDataSource {
    private func setupTableView() {
        self.examQuestionTableView.delegate = self
        self.examQuestionTableView.dataSource = self
        self.examQuestionTableView.estimatedRowHeight = self.view.bounds.height / 2
        self.examQuestionTableView.rowHeight = UITableView.automaticDimension
        self.examQuestionTableView.registerCell(QuestionDescriptionTableViewCell.self)
        self.examQuestionTableView.registerCell(OptionTableViewCell.self)
        self.examQuestionTableView.separatorStyle = .none
        self.examQuestionTableView.backgroundColor = Colors.secondaryDarkColor
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rowCount(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        case is QuestionDescriptionCellModel:
            return QuestionDescriptionTableViewCell.defaultReuseIdentifier
        case is OptionCellModel:
            return OptionTableViewCell.defaultReuseIdentifier
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // animate only option type cells and when isAnimated property is set true
        guard let cellModel = (cell as? OptionTableViewCell)?.item as? OptionCellModel else { return }
        if cellModel.isAnimated {
            cell.alpha = 0
            
            UIView.animate(
                withDuration: 0.1,
                delay: 0.05 * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
                })
        }
    }
}

// MARK: - QuestionDescriptionTableViewCellDelegate
extension PracticeQuestionViewController: QuestionDescriptionTableViewCellDelegate {
    func didTapAddToStudyDeck(_ selected: Bool) {
        self.viewModel.didTapAddToStudyDeck(selected)
    }
    
}
