//
//  ExamSettingsViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

protocol ExamSettingsViewControllerDelegate: AnyObject {
    var disposable: CompositeDisposable { get }
    var maxQuestionsCount: Int { get }
    var minQuestionsCount: Int { get }
    var questionEntities: [PracticeQuestion] { get set }
    var  attemptSelected: Int { get }
    var navigationType: NavigationType { get }
    var enableImmediateFeedback: Bool { get }
    var enableStudyDeck: Bool { get }
    
    func fetchPracticeQuestions()
    func didUpdateMaxQuestionCount(_ maxCount: Int)
    func didUpdateImmediateFeedbackState(_ enable: Bool)
    func didUpdateAddToStudyDeckState(_ enable: Bool)
    func save(attemptSelected: Int)
    func fetchQuestions()
}

class ExamSettingsViewController: UIViewController {

    @IBOutlet weak var enableStudyDeckSwitch: UISwitch!
    @IBOutlet weak var enableImmediateFeedbackSwitch: UISwitch!
    @IBOutlet weak var progressSlider: CustomSlider!
    @IBOutlet weak var questionsCountTextField: UITextField!
    @IBOutlet weak var minQuestionCountLabel: UILabel!
    @IBOutlet weak var maxQuestionCountLabel: UILabel!
    @IBOutlet var buttonArray: [UIButton]!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet weak var attemptsView: UIStackView!
    @IBOutlet weak var selectNumberOfAttemptsView: UIView!
    
    static var newInstance: ExamSettingsViewController? {
        let sb = UIStoryboard.init(name: Storyboard.examPrep.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? ExamSettingsViewController
        return vc
    }

    var viewModel: ExamSettingsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    private func setupSwitchInitialLogic() {
        if !self.viewModel.enableImmediateFeedback {
            self.enableStudyDeckSwitch.isUserInteractionEnabled = false
        } else {
            self.enableStudyDeckSwitch.isUserInteractionEnabled = true
        }
    }
    
    private func initialSetup() {
        if self.viewModel == nil {
            self.viewModel = ExamSettingsViewModel(self)
        }
        self.setupObservers()
        self.viewModel.fetchPracticeQuestions()
        self.setupSelectedAttempt()
        self.enableStudyDeckSwitch.isOn = self.viewModel.enableStudyDeck
        self.enableImmediateFeedbackSwitch.isOn = self.viewModel.enableImmediateFeedback
        self.setupGradientButtonsBorder()
        self.setupSwitchInitialLogic()
    }

    private func setupObservers() {
        // observe change in slider value when being dragged
        self.reactive.makeBindingTarget { this, slider in
            this.questionsCountTextField.text = String(Int(slider.value))
            this.viewModel.didUpdateMaxQuestionCount(Int(slider.value))
        } <~ self.progressSlider.reactive.controlEvents(.valueChanged).map { $0 }

        // observe change in switch state
        self.reactive.makeBindingTarget { this, enabled in
            this.viewModel.didUpdateAddToStudyDeckState(enabled)

        } <~ self.enableStudyDeckSwitch.reactive.controlEvents(.valueChanged).map({ $0.isOn })

        // observe change in switch state
        self.reactive.makeBindingTarget { this, enabled in
            this.viewModel.didUpdateImmediateFeedbackState(enabled)
            if !enabled {
                this.enableStudyDeckSwitch.isUserInteractionEnabled = false
                this.viewModel.didUpdateAddToStudyDeckState(enabled)
                this.enableStudyDeckSwitch.isOn = enabled
            } else {
                this.enableStudyDeckSwitch.isUserInteractionEnabled = true
            }
            self.enableAttemptsView(self.viewModel.enableImmediateFeedback)

        } <~ self.enableImmediateFeedbackSwitch.reactive.controlEvents(.valueChanged).map({ $0.isOn })

        // observe change in text after user ends typing in the text field box
        self.reactive.makeBindingTarget { this, _ in
            if let enteredText = this.questionsCountTextField.text {
                let enteredCount = (enteredText as NSString).intValue
                // if entered count exceeds max questions count, reset text to max count
                if enteredCount > this.viewModel.maxQuestionsCount {
                    this.questionsCountTextField.text = String(this.viewModel.maxQuestionsCount)
                    this.viewModel.didUpdateMaxQuestionCount(this.viewModel.maxQuestionsCount)
                } else if enteredText.isEmpty || enteredCount < this.viewModel.minQuestionsCount {
                    // if entered text is empty or the entered count is lower that the min questions count, reset text to min count
                    this.questionsCountTextField.text = String(this.viewModel.minQuestionsCount)
                    this.viewModel.didUpdateMaxQuestionCount(this.viewModel.minQuestionsCount)
                } else {
                    this.viewModel.didUpdateMaxQuestionCount(Int(enteredCount))
                }
                // slide progress bar to the entered value
                this.progressSlider.setValue(Float(enteredCount), animated: true)
            }
        } <~ self.questionsCountTextField.reactive.controlEvents(.editingDidEnd).map({ $0 })

        // observe when user starts typing in the text field box
        self.reactive.makeBindingTarget { this, _ in
            this.addDoneButtonOnKeyboard()
        } <~ self.questionsCountTextField.reactive.controlEvents(.editingDidBegin).map({ $0 })
        
    }
    
    private func setupGradientButtonsBorder() {
        let buttons = [self.button1, self.button2, self.button3, self.button4]
        for attemptButton in buttons {
            attemptButton!.layer.borderWidth = 1
            attemptButton!.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    private func setupGradientBorderForButtons(button: UIButton) {
        button.clipsToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: .zero, size: button.frame.size)
        gradient.colors = [UIColor.white.cgColor, UIColor.darkGray.cgColor]

        let shape = CAShapeLayer()
        shape.lineWidth = 3
        
        shape.path = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        button.layer.addSublayer(gradient)
    }
    
    func setupSelectedAttempt() {
        if !self.viewModel.enableImmediateFeedback {
            self.enableAttemptsView(false)
        }
        for buttons in buttonArray {
            if buttons.tag == self.viewModel.attemptSelected {
                buttons.backgroundColor = Colors.primaryYellow
                buttons.setTitleColor(UIColor(hex: 0x434342), for: .normal)
            } else {
                buttons.backgroundColor = UIColor(hex: 0x434342)
                buttons.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    func enableAttemptsView(_ enable: Bool) {
        if !enable {
            self.updateAttemptActionButtons(sender: self.button1)
        }
        self.selectNumberOfAttemptsView.isHidden = enable ? false : true
        self.attemptsView.alpha = enable ? 1.0 : 0.3
        self.attemptsView.isUserInteractionEnabled = enable
    }
    
    func updateAttemptActionButtons(sender: UIButton) {
        for buttons in buttonArray {
            if buttons.tag == sender.tag {
                buttons.backgroundColor = Colors.primaryYellow
                buttons.setTitleColor(UIColor(hex: 0x434342), for: .normal)
                self.viewModel.save(attemptSelected: sender.tag)
            } else {
                buttons.backgroundColor = UIColor(hex: 0x434342)
                buttons.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    @IBAction func selectedAttemptAction(_ sender: UIButton) {
        for buttons in self.buttonArray {
            if buttons.tag == sender.tag {
                buttons.backgroundColor = Colors.primaryYellow
                buttons.setTitleColor(UIColor(hex: 0x434342), for: .normal)
                self.viewModel.save(attemptSelected: sender.tag)
            } else {
                buttons.backgroundColor = UIColor(hex: 0x434342)
                buttons.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startExamButtonAction(_ sender: UIButton) {
        self.viewModel.fetchQuestions()
    }
    
}

// MARK: - ExamSettingsViewModelDelegate
extension ExamSettingsViewController: ExamSettingsViewModelDelegate {
    
    func updateSliderFor(minCount: Int, maxCount: Int) {
        self.progressSlider.minimumValue = Float(minCount)
        self.progressSlider.maximumValue = Float(maxCount)
        self.progressSlider.value = Float(maxCount)
        
        self.minQuestionCountLabel.text = "Min: 1"
        self.maxQuestionCountLabel.text = "Max: \(maxCount)"
        
        self.questionsCountTextField.text = String(maxCount)
    }
    
}

// MARK: - UITextFieldDelegate
extension ExamSettingsViewController {
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: self.view.frame.width,
                                                             height: 50))
        doneToolbar.barStyle = UIBarStyle.black
        self.questionsCountTextField.inputAccessoryView = doneToolbar
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                        target: nil,
                                        action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done",
                                                    style: UIBarButtonItem.Style.done,
                                                    target: self,
                                                    action: #selector(self.doneButtonAction))
        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)
        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()
    }
    
    @objc func doneButtonAction() {
        self.questionsCountTextField.resignFirstResponder()
    }
    
    func navigateToQuiz() {
        //         set entered questions count as max questions count for the exam
        self.viewModel.didUpdateMaxQuestionCount(Int(self.progressSlider.value))
        guard let practiceQuestionVc = PracticeQuestionViewController.newInstance else { return }
        practiceQuestionVc.setupViewModel(self.viewModel.questionEntities, navigationType: self.viewModel.navigationType)
        self.navigationController?.pushViewController(practiceQuestionVc, animated: true)
    }
    
}
