//
//  ExamResultViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit
import ReactiveSwift
import FLUtilities

protocol ExamResultViewControllerDelegate: AnyObject {
    var sectionCount: Int { get }
    var attemptedQuestionsCount: MutableProperty<String> { get }
    var correctQuestionsCount: MutableProperty<String> { get }
    var incorrectQuestionsCount: MutableProperty<String> { get }
    var resultPercentage: MutableProperty<Double> { get }
    var skippedPercentage: MutableProperty<Double> { get }
    var correctPercentage: MutableProperty<Double> { get }
    var incorrectPercentage: MutableProperty<Double> { get }
    var skippedQuestionsCount: MutableProperty<String> { get }

    func rowCount(at section: Int) -> Int
    func section(at index: Int) -> SectionModel
    func cellModel(at indexPath: IndexPath) -> Any
    func loadExamResults()
    func didTapQuitResults()
    func didTapAddToStudyDeck(for chapterID: Int, qID: String, isStudyDeckEnabled: Bool)
}

class ExamResultViewController: UIViewController {

    var headerViewMaxHeight: CGFloat = 215
    let headerViewMinHeight: CGFloat = 50
    let maxLabelFontSize: CGFloat = 18.0
    let minLabelFontSize: CGFloat = 14.0
    let maxInterSpacing: CGFloat = 17.0
    let minInterSpacing: CGFloat = 0

    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var incorrectAnswerLabel: UILabel!
    @IBOutlet weak var skippedQuestionsLabel: UILabel!
    @IBOutlet weak var resultPercentageLabel: UILabel!
    @IBOutlet weak var correctAnswersCountLabel: UILabel!
    @IBOutlet weak var incorrectAnswersCountLabel: UILabel!
    @IBOutlet weak var skippedQuestionsCountLabel: UILabel!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var skippedCircularProgress: KDCircularProgress!
    @IBOutlet weak var incorrectCircularProgress: KDCircularProgress!
    @IBOutlet weak var correctCircularProgress: KDCircularProgress!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var parentStackView: UIStackView!
    @IBOutlet weak var scoreStackView: UIStackView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var line1: UIView!
    @IBOutlet weak var line2: UIView!
    @IBOutlet weak var line3: UIView!

    static var newInstance: ExamResultViewController? {
        let sb = UIStoryboard.init(name: Storyboard.examPrep.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? ExamResultViewController
        return vc
    }

    var viewModel: ExamResultViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupGradientBorderForView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.resultsTableView.performBatchUpdates(nil, completion: nil)
    }
    
    private func initialSetup() {
        self.setupUI()
        self.setupTableView()
    }
    
    private func setupGradientBorderForView() {
        let gradientLayer1: CAGradientLayer = CAGradientLayer()
        gradientLayer1.frame = self.line1.bounds
        let topColor: CGColor = UIColor.white.cgColor
        let bottomColor: CGColor = Colors.secondaryDarkColor.cgColor
        gradientLayer1.colors = [topColor, bottomColor]
        gradientLayer1.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer1.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.line1.layer.insertSublayer(gradientLayer1, at: 0)
        
        let gradientLayer2: CAGradientLayer = CAGradientLayer()
        gradientLayer2.frame = self.line2.bounds
        gradientLayer2.colors = [topColor, bottomColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.line2.layer.insertSublayer(gradientLayer2, at: 0)
    }
    
    private func setupProgressViews() {
        let correctAngle: Double = Double((self.viewModel.correctPercentage.value * 360) / 100) - 89
        let skippedAngle: Double = Double(((self.viewModel.correctPercentage.value + self.viewModel.skippedPercentage.value) * 360) / 100) - 89
        let progressViews = [
            correctCircularProgress,
            skippedCircularProgress,
            incorrectCircularProgress
        ]
        let progressThicknesses: [CGFloat] = [0.6, 0.5, 0.4]
        let progressColors: [UIColor] = [Colors.correctOptionColor, Colors.primaryYellow, Colors.incorrectOptionColor]
        let startAngles: [Double] = [-90, correctAngle, skippedAngle]
        
        for index in 0..<progressViews.count {
            self.setupProgressView(circularProgress: progressViews[index]!,
                                   progressThickness: progressThicknesses[index],
                                   progressColor: progressColors[index],
                                   startAngle: startAngles[index])
        }
    }
    
    private func setupUI() {
        self.setupLabels()
    }
        
    func setupViewModel(selectedQuestions: [QuestionResponse]) {
        if self.viewModel == nil {
            self.viewModel = ExamResultViewModel(self, selectedQuestions: selectedQuestions)
        }
        self.setupObservers()
        delay(0.3) {
            self.viewModel.loadExamResults()
        }
    }
    
    private func setupLabels() {
        self.incorrectAnswerLabel.font = UIFont.poppinsRegular(maxLabelFontSize)
        self.correctAnswerLabel.font = UIFont.poppinsRegular(maxLabelFontSize)
        self.skippedQuestionsLabel.font = UIFont.poppinsRegular(maxLabelFontSize)
        self.incorrectAnswersCountLabel.textColor = Colors.incorrectOptionColor
        self.correctAnswersCountLabel.textColor = Colors.correctOptionColor
        self.skippedQuestionsCountLabel.textColor = Colors.primaryYellow
    }
        
    private func setupProgressView(circularProgress: KDCircularProgress,
                                   progressThickness: CGFloat,
                                   progressColor: UIColor,
                                   startAngle: Double) {
        circularProgress.gradientRotateSpeed = 2
        circularProgress.glowMode = .noGlow
        circularProgress.clockwise = true
        circularProgress.roundedCorners = false
        circularProgress.trackThickness = progressThickness
        circularProgress.progressThickness = progressThickness
        circularProgress.startAngle = startAngle
        circularProgress.progressInsideFillColor = UIColor.clear
        circularProgress.trackColor = UIColor.clear
        circularProgress.progressColors = [progressColor]
    }
    
    private func setupObservers() {
        self.viewModel.correctQuestionsCount.signal.observeValues { [weak self] count in
            guard let self = self else { return }
            if let countInt = Int(count) {
                if countInt < 10 {
                    self.correctAnswersCountLabel.text = "0" + count
                } else {
                    self.correctAnswersCountLabel.text = count
                }
            } else {
                self.correctAnswersCountLabel.text = count
            }
        }

        self.viewModel.incorrectQuestionsCount.signal.observeValues { [weak self] count in
            guard let self = self else { return }
            if let countInt = Int(count) {
                if countInt < 10 {
                    self.incorrectAnswersCountLabel.text = "0" + count
                } else {
                    self.incorrectAnswersCountLabel.text = count
                }
            } else {
                self.incorrectAnswersCountLabel.text = count
            }
        }
        
        self.viewModel.skippedQuestionsCount.signal.observeValues { [weak self] count in
            guard let self = self else { return }
            if let countInt = Int(count) {
                if countInt < 10 {
                    self.skippedQuestionsCountLabel.text = "0" + count
                } else {
                    self.skippedQuestionsCountLabel.text = count
                }
            } else {
                self.skippedQuestionsCountLabel.text = count
            }
        }
        
        self.viewModel.resultPercentage.signal.observeValues { [weak self] percentage in
            self?.resultPercentageLabel.text = "\(percentage.rounded(toPlaces: 1))%"
        }
    }
    
    @IBAction func quitResults(_ sender: UIButton) {
        self.viewModel.didTapQuitResults()
    }
    
}

// MARK: - UITableViewDataSource
extension ExamResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func setupTableView() {
        self.resultsTableView.rowHeight = UITableView.automaticDimension
        self.resultsTableView.estimatedRowHeight = 25
        self.resultsTableView.registerCell(QuestionResultTableViewCell.self)
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
        case is QuestionResultCellModel:
            return QuestionResultTableViewCell.defaultReuseIdentifier
        default:
            return nil
        }
    }
    
}

// MARK: - ExamResultViewModelDelegate
extension ExamResultViewController: ExamResultViewModelDelegate {
    
    func reloadUI() {
        self.resultsTableView.reloadData()
        self.setupProgressViews()
        self.animateProgressView()
    }
    
    func quitResults() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: - Animations
extension ExamResultViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.headerViewMaxHeight = self.view.bounds.width * 0.4 + 25
        let yPos: CGFloat = scrollView.contentOffset.y
        let newHeaderViewHeight: CGFloat = headerViewHeightConstraint.constant - yPos
        let newInterSpacing = self.maxInterSpacing - (self.maxInterSpacing * (newHeaderViewHeight/headerViewMaxHeight))
        
        if newHeaderViewHeight >= (headerViewMaxHeight * 0.6) {
            self.line1.isHidden = false
            self.line2.isHidden = false
            self.line3.isHidden = false
            self.progressContainerView.isHidden = false
            self.scoreStackView.axis = .vertical
            self.scoreStackView.distribution = .fill
            self.scoreStackView.spacing = 5
            self.parentStackView.alignment = .leading
            self.animateHeaderView(headerHeight: headerViewMaxHeight, labelFontSize: self.maxLabelFontSize)
        } else if newHeaderViewHeight < headerViewMinHeight {
            self.line1.isHidden = true
            self.line2.isHidden = true
            self.line3.isHidden = true
            self.progressContainerView.isHidden = true
            self.scoreStackView.axis = .horizontal
            self.scoreStackView.distribution = .equalCentering
            self.scoreStackView.spacing = self.minInterSpacing
            self.parentStackView.alignment = .fill
            self.animateHeaderView(headerHeight: headerViewMinHeight, labelFontSize: self.minLabelFontSize)
        } else {
            self.scoreStackView.spacing = newInterSpacing
            self.animateHeaderView(headerHeight: newHeaderViewHeight, labelFontSize: maxLabelFontSize)
        }
    }
    
    private func animateHeaderView(headerHeight: CGFloat, labelFontSize: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.headerViewHeightConstraint.constant = headerHeight
            self.incorrectAnswerLabel.font = UIFont.poppinsRegular(labelFontSize)
            self.correctAnswerLabel.font = UIFont.poppinsRegular(labelFontSize)
            self.skippedQuestionsLabel.font = UIFont.poppinsRegular(labelFontSize)
            self.correctAnswersCountLabel.font = UIFont.poppinsRegular(labelFontSize)
            self.incorrectAnswersCountLabel.font = UIFont.poppinsRegular(labelFontSize)
            self.skippedQuestionsCountLabel.font = UIFont.poppinsRegular(labelFontSize)
            self.headerView.layoutIfNeeded()
        }
    }
    
    private func animateProgressView() {
        self.incorrectCircularProgress.isHidden = self.viewModel.incorrectPercentage.value == 0.0
        self.skippedCircularProgress.isHidden = self.viewModel.skippedPercentage.value == 0.0
        self.correctCircularProgress.isHidden = self.viewModel.correctPercentage.value == 0.0
        let skippedAngle: Double = Double((self.viewModel.skippedPercentage.value * 360) / 100)
        let incorrectAngle: Double = Double((self.viewModel.incorrectPercentage.value * 360) / 100)
        let correctAngle: Double = Double((self.viewModel.correctPercentage.value * 360) / 100)
        let animationDuration: Double = 0.25
        
        func animate(_ view: KDCircularProgress,
                     _ fromAngle: Double,
                     _ toAngle: Double,
                     _ duration: TimeInterval,
                     _ relativeDuration: Bool = true,
                     completion: ((Bool) -> Void)?) {
            view.animateFromAngle(fromAngle,
                                  toAngle: toAngle,
                                  duration: duration,
                                  relativeDuration: relativeDuration,
                                  completion: completion)
        }
        
        animate(self.correctCircularProgress,
                0,
                correctAngle - 1,
                animationDuration) { [weak self] completed in
            
            guard completed, let self = self else { return }
            animate(self.skippedCircularProgress,
                    0,
                    skippedAngle - 1,
                    animationDuration) { [weak self] completed in
                guard completed, let self = self else { return }
                animate(self.incorrectCircularProgress,
                        0,
                        incorrectAngle - 1,
                        animationDuration) { completed in
                    if completed {
//                        HapticFeedback.success()
                    }
                }
            }
        }
    }
}

extension ExamResultViewController: QuestionResultTableViewCellDelegate {
    func didTapAddToStudyDeck(for chapterId: Int, qID: String, isStudyDeckEnabled: Bool) {
        self.viewModel.didTapAddToStudyDeck(for: chapterId, qID: qID, isStudyDeckEnabled: isStudyDeckEnabled)
    }
}
