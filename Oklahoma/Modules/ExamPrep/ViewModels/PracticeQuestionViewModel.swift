//
//  PracticeQuestionViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import ReactiveSwift
import FLUtilities
import Realm
import RealmSwift

protocol PracticeQuestionViewModelDelegate: AnyObject, BaseViewModelProtocol {
    func loadNextQuestion()
    func reloadQuestion()
    func showExamResults()
    func exitQuiz()
    func setupActionButton(model: QuestionActionCellModel)
    func setActionButtonTitle()
}

class PracticeQuestionViewModel {
    
    weak var view: PracticeQuestionViewModelDelegate!
    
    var sectionModels = MutableProperty<[SectionModel]>([])
    var disposable = CompositeDisposable([])
    var navigationType: NavigationType
    var activePracticeQuestion: PracticeQuestion?
    var activeQuestionIndex = 0
    var practiceQuestions: [PracticeQuestion]
    var practiceQuestionsResponse: [QuestionResponse] = []
    var numberOfAttempts = DataModel.shared.perQuestionAttempt
    var allowedNumberOfAttempts = DataModel.shared.perQuestionAttempt
    var selectEnabled: Bool = true
    
    var actionModel = MutableProperty<QuestionActionCellModel>(QuestionActionCellModel(.skip))
    var previousAttemptAt: [Int: Bool]?
    
    init(_ view: PracticeQuestionViewModelDelegate,
         _ practiceQuestions: [PracticeQuestion],
         _ navigationType: NavigationType) {
        self.view = view
        self.practiceQuestions = practiceQuestions
        self.navigationType = navigationType
        self.observeAction()
        self.setupQuestionResponse()
    }
    
    private func setupQuestionResponse() {
        self.practiceQuestionsResponse.removeAll()
        for question in self.practiceQuestions {
            let isCurrentAttempted = ExamPrepHelper.getQuestionType(with: question.questionType) == .attempted
            let questionResponse = QuestionResponse(id: question.id,
                                                    isStudyDeckEnabled: question.inStudyDeck,
                                                    isCurrentAttempted: isCurrentAttempted,
                                                    isAnsweredCorrect: question.didAnswerCorrect,
                                                    incorrectAnswer: question.userAnswer,
                                                    question: question.questionText,
                                                    correctAnswer: Int(question.correctAnswer) ?? 0,
                                                    chapterId: question.chapterID,
                                                    refPage: question.referencePage,
                                                    questionId: question.questionId,
                                                    answer0: question.optionA,
                                                    answer1: question.optionB,
                                                    answer2: question.optionC,
                                                    answer3: question.optionD,
                                                    isSkipped: false,
                                                    qID: question.qID)
            self.practiceQuestionsResponse.append(questionResponse)
        }
    }
    
    func resetQuestionsLocallyForTest() {
        self.practiceQuestionsResponse = self.practiceQuestionsResponse.map({ question in
            question.isCurrentAttempted = false
            question.isAnsweredCorrect = false
            question.incorrectAnswer = ""
            return question
        })
    }
    
    private func observeAction() {
        self.actionModel.signal.observeValues { model in
            self.view.setupActionButton(model: model)
        }
    }
    
    func setupSectionModel() {
        // show next question if current question index does not exceeds max question count
        if self.activeQuestionIndex < DataModel.shared.maximumQuestionsToAttempt {
            self.sectionModels.value.removeAll()
            let sectionModel = SectionModel()
            self.activePracticeQuestion = self.practiceQuestions[self.activeQuestionIndex]
            
            // NOTE: create question description cell model
            let question = self.practiceQuestionsResponse[self.activeQuestionIndex]
            let questionSubTitle = "Question \(self.activeQuestionIndex + 1) of \(DataModel.shared.maximumQuestionsToAttempt)"
            
            let cellModel = QuestionDescriptionCellModel(question,
                                                         questionSubTitle,
                                                         DataModel.shared.enableImmediateFeedbackForAnswers,
                                                         DataModel.shared.enableStudyDeckForIncorrectAnswers)
            sectionModel.cellModels.append(cellModel)
            
            // create question options cell model
            var questionOptionCellModels = [OptionCellModel]()
            questionOptionCellModels.append(
                OptionCellModel(self.practiceQuestions[self.activeQuestionIndex].optionA,
                                .none,
                                0)
            )
            questionOptionCellModels.append(
                OptionCellModel(self.practiceQuestions[self.activeQuestionIndex].optionB,
                                .none,
                                1)
            )
            questionOptionCellModels.append(
                OptionCellModel(self.practiceQuestions[self.activeQuestionIndex].optionC,
                                .none,
                                2)
            )
            questionOptionCellModels.append(
                OptionCellModel(self.practiceQuestions[self.activeQuestionIndex].optionD,
                                .none,
                                3)
            )
            sectionModel.cellModels.append(contentsOf: questionOptionCellModels)
            
            self.actionModel.value.actionType = .skip
            self.view.setupActionButton(model: self.actionModel.value)
            
            self.sectionModels.value.append(sectionModel)
            self.activeQuestionIndex += 1
            self.view?.loadNextQuestion()
        } else {
            // show exit quiz alert
            self.showResultAlert()
        }
    }
    
    func didTapNext() {
        selectEnabled = true
        self.numberOfAttempts = DataModel.shared.perQuestionAttempt
        if self.activeQuestionIndex == DataModel.shared.maximumQuestionsToAttempt {
            practiceQuestionsResponse[self.activeQuestionIndex - 1].isSkipped = false
        }
        self.resetAttemptsDictionary()
        self.setupSectionModel()
    }
    
    func didTapSkip() {
        selectEnabled = true
        self.numberOfAttempts = DataModel.shared.perQuestionAttempt
        self.markQuestionUnattempted()
        self.resetAttemptsDictionary()
        self.setupSectionModel()
    }
    
    func markQuestionUnattempted() {
        // Reduce activeQuestionIndex by 1 to match the array value
        practiceQuestionsResponse[self.activeQuestionIndex - 1].isSkipped = true
    }
    
    func resetAttemptsDictionary() {
        self.previousAttemptAt = nil
    }
    
    private func showResultAlert() {
        let scoreAndExitAction = ActionInterface(title: Constant.yes, style: .default)
        let cancelAction = ActionInterface(title: Constant.cancel,
                                           style: .default)
        var actionInterfaceList = [ActionInterface]()
        actionInterfaceList = [scoreAndExitAction,
                               cancelAction]
        self.view?.showAlert(title: Constant.ExamPrep.areYouSureYouWantToExit,
                             message: "",
                             actionInterfaceList: actionInterfaceList) { action in
            switch action.title {
            case Constant.yes:
                self.exitAndDisplayExamResults()
            default:
                return
            }
        }
    }
    
    func showExitQuizConfirmation() {
        let scoreAndExitAction = ActionInterface(title: Constant.ExamPrep.scoreAndExit, style: .default)
        let exitWithoutScoreAction = ActionInterface(title: Constant.ExamPrep.exitWithoutScore, style: .destructive)
        let cancelAction = ActionInterface(title: Constant.cancel,
                                           style: .default)
        let exitAction = ActionInterface(title: Constant.yes,
                                         style: .destructive)
        var actionInterfaceList = [ActionInterface]()
        
        // if none questions are answered, do not show 'score and exit' option
        if self.practiceQuestionsResponse.filter({ $0.isCurrentAttempted == true }).isEmpty {
            actionInterfaceList = [exitAction,
                                   cancelAction]
        } else {
            actionInterfaceList = [scoreAndExitAction,
                                   exitWithoutScoreAction,
                                   cancelAction]
        }
        
        self.view?.showAlert(title: Constant.ExamPrep.endQuiz,
                             message: "",
                             actionInterfaceList: actionInterfaceList) { action in
            switch action.title {
            case Constant.ExamPrep.scoreAndExit:
                // display exam results
                self.exitAndDisplayExamResults()
            case Constant.ExamPrep.exitWithoutScore:
                // pop back without displaying exam results
                self.exitWithoutDisplayingExamResults()
            case Constant.yes:
                // pop back without displaying exam results
                self.exitWithoutDisplayingExamResults()
            default:
                return
            }
        }
    }
    
    private func exitAndDisplayExamResults() {
        ExamManager.generateReports()
        self.updateDatabase()
    }
    
    private func exitWithoutDisplayingExamResults() {
        
        /* get attempted question from current exam and reset questions
         to not answered in database when exit without score is selected.*/
        self.view?.exitQuiz()
    }
    
}
