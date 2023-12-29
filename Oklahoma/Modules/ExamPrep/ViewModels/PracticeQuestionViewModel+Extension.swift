//
//  PracticeQuestionViewModel+Extension.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation

// MARK: - PracticeQuestionViewControllerDelegate
extension PracticeQuestionViewModel: PracticeQuestionViewControllerDelegate {
    
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

    fileprivate func didSelectForMultipleAttempts(_ isCorrect: Bool,
                                                  _ indexPath: IndexPath) {
        self.sectionModels.value.first?.cellModels.forEach { cellModel in
            if isCorrect {
                self.updateSingleQuestionWithEachAttempt(qID: self.activePracticeQuestion?.qID ?? "0",
                                                         isStudyDeckEnable: false,
                                                         isCurrentAttempted: true,
                                                         isAnswerCorrect: isCorrect,
                                                         incorrectAnswerIndex: 5)
                (cellModel as? QuestionDescriptionCellModel)?.attemptLabelHidden = true
                guard let cellModel = cellModel as? OptionCellModel else { return }
                if cellModel.index == indexPath.row - 1 {
                    cellModel.state = .correct
                }
                self.selectEnabled = false
            } else {
                (cellModel as? QuestionDescriptionCellModel)?.attemptLabelHidden = false
                (cellModel as? QuestionDescriptionCellModel)?.currentAttempt = numberOfAttempts
                guard let cellModel = cellModel as? OptionCellModel else { return }
                if cellModel.index == indexPath.row - 1 {
                    cellModel.state = .incorrect
                }
//                HapticFeedback.error()
            }
        }
    }

    fileprivate func saveForStudyDeck(_ isCorrect: Bool) {
        if DataModel.shared.enableStudyDeckForIncorrectAnswers {
            ExamManager.addQuestionToStudyDesk(
                chapterId: self.activePracticeQuestion?.chapterID ?? 0,
                qID: self.activePracticeQuestion?.qID ?? "",
                addToStudyDeck: !isCorrect
            )
        }
    }

    fileprivate func didSelectForNumberOfAttempts(_ isCorrect: Bool, _ indexPath: IndexPath) {
        if numberOfAttempts == 0 { // allowedNumberOfAttempts
            self.sectionModels.value.first?.cellModels.forEach { cellModel in
                (cellModel as? QuestionDescriptionCellModel)?.attemptLabelHidden = true
                if isCorrect {
                    self.updateSingleQuestionWithEachAttempt(qID: self.activePracticeQuestion?.qID ?? "0",
                                                             isStudyDeckEnable: false,
                                                             isCurrentAttempted: true,
                                                             isAnswerCorrect: isCorrect,
                                                             incorrectAnswerIndex: 5)
                    self.selectEnabled = false
                    self.sectionModels.value.first?.cellModels.forEach { cellModel in
                        guard let cellModel = cellModel as? OptionCellModel else { return }
                        if cellModel.index == indexPath.row - 1 {
                            cellModel.state = .correct
                        }
                    }
                } else {
                    self.updateSingleQuestionWithEachAttempt(qID: self.activePracticeQuestion?.qID ?? "0",
                                                             isStudyDeckEnable: true,
                                                             isCurrentAttempted: true,
                                                             isAnswerCorrect: false,
                                                             incorrectAnswerIndex: indexPath.row)
//                    HapticFeedback.error()
                    self.sectionModels.value.first?.cellModels.forEach { cellModel in
                        guard let cellModel = cellModel as? OptionCellModel else { return }
                        if cellModel.index == indexPath.row - 1 {
                            cellModel.state = .incorrect
                        }
                        
                        if cellModel.index == Int(self.activePracticeQuestion?.correctAnswer ?? "0") ?? 0 {
                            cellModel.state = .correct
                        }
                    }
                }
            }
        }
        //  more attempts to go for answering
        else {
            self.didSelectForMultipleAttempts(isCorrect, indexPath)
        }
    }
    
    fileprivate func didSelectForActionButtionUpdate(_ isCorrect: Bool, _ cellModel: OptionCellModel) {
        if isCorrect {
            self.actionModel.value.actionType = .next
            previousAttemptAt = nil
        } else {
            if previousAttemptAt == nil {
                previousAttemptAt = [Int: Bool]()
            }
            previousAttemptAt?[Int(cellModel.index)] = isCorrect
            if numberOfAttempts >= 0 { // allowedNumberOfAttempts
                self.actionModel.value.actionType = numberOfAttempts == 0 ? .next : .skip
            }
        }
    }
    
    fileprivate func didSelectForNotEnableImmediateFeedback(_ isCorrect: Bool, _ indexPath: IndexPath) {
        self.sectionModels.value.first?.cellModels.forEach { cellModel in
            (cellModel as? QuestionDescriptionCellModel)?.attemptLabelHidden = true
            self.selectEnabled = false
//            HapticFeedback.success()
            self.updateSingleQuestionWithEachAttempt(qID: self.activePracticeQuestion?.qID ?? "0",
                                                     isStudyDeckEnable: false,
                                                     isCurrentAttempted: true,
                                                     isAnswerCorrect: isCorrect,
                                                     incorrectAnswerIndex: isCorrect ? 5 : indexPath.row)
            guard let cellModel = cellModel as? OptionCellModel else { return }
            if cellModel.index == indexPath.row - 1 {
                cellModel.state = .unknown
            }
        }
    }
    
    func didSelect(at indexPath: IndexPath) {
        // Reduce numberOfAttempts by 1
        // process didSelect only for option type cell models
        self.sectionModels.value.first?.cellModels.forEach { cellModel in
            guard let cellModel = cellModel as? OptionCellModel else { return }
            cellModel.state = .none
        }
        if selectEnabled {
            guard let cellModel = self.cellModel(at: indexPath) as? OptionCellModel else { return }
            if let previousAttemptAt = previousAttemptAt {
                let attemptedIndices = previousAttemptAt.keys.map({ Int($0) })
                var wasAttempted = false
                if attemptedIndices.contains(Int(cellModel.index)) {
                    wasAttempted = true
                }
                let wasCorrect = previousAttemptAt[Int(cellModel.index)] ?? false
                if !wasCorrect && wasAttempted {
                    return
                }
            }
            numberOfAttempts -= 1
            // set animate false for all option cells
            self.sectionModels.value.first?.cellModels.forEach { cellModel in
                (cellModel as? OptionCellModel)?.isAnimated = false
            }

            // check if selected option is correct or incorrect
            let isCorrect = cellModel.index == Int(self.activePracticeQuestion?.correctAnswer ?? "0") ?? 0
            // Update action button title
            self.didSelectForActionButtionUpdate(isCorrect, cellModel)
            self.view.setupActionButton(model: self.actionModel.value)
            // update selected option's attributes only if immediate feedback for answers is enabled
            if DataModel.shared.enableImmediateFeedbackForAnswers {
                if numberOfAttempts < 0 { // allowedNumberOfAttempts
                    return
                } else {
                    self.didSelectForNumberOfAttempts(isCorrect, indexPath)
                }
            } else {
                self.didSelectForNotEnableImmediateFeedback(isCorrect, indexPath)
            }
            // add incorrect answer to study deck if 'Enable Study Deck for incorrect answers' switch is enabled in exam settings
            self.saveForStudyDeck(isCorrect)
            self.view?.reloadQuestion()
            if self.activeQuestionIndex == DataModel.shared.maximumQuestionsToAttempt {
                self.view.setActionButtonTitle()
            }
        } else {
            return
        }
    }

    func updateSingleQuestionWithEachAttempt(qID: String,
                                             isStudyDeckEnable: Bool,
                                             isCurrentAttempted: Bool,
                                             isAnswerCorrect: Bool,
                                             incorrectAnswerIndex: Int) {
        var incorrectAnswer = ""
        switch incorrectAnswerIndex {
        case 1:
            incorrectAnswer = self.activePracticeQuestion?.optionA ?? ""
        case 2:
            incorrectAnswer = self.activePracticeQuestion?.optionB ?? ""
        case 3:
            incorrectAnswer = self.activePracticeQuestion?.optionC ?? ""
        case 4:
            incorrectAnswer = self.activePracticeQuestion?.optionD ?? ""
        default: ()
        }
        self.practiceQuestionsResponse = self.practiceQuestionsResponse.map { question in
            if question.qID == qID {
                question.isCurrentAttempted = isCurrentAttempted
                question.isAnsweredCorrect = isAnswerCorrect
                question.incorrectAnswer = incorrectAnswer
            }
            return question
        }

        self.activePracticeQuestion?.answeredOption(isCorrect: isAnswerCorrect)
    }

    func loadQuestion() {
        self.resetQuestionsLocallyForTest()
        self.setupSectionModel()
    }

    func didTapQuestionActionButton() {
        if self.actionModel.value.actionType == QuestionActionType.skip {
            self.didTapSkip()
        } else {
            self.didTapNext()
        }
    }

    func didTapExitQuiz() {
        self.showExitQuizConfirmation()
    }

    func didTapAddToStudyDeck(_ selected: Bool) {
        ExamManager.addQuestionToStudyDesk(
            chapterId: self.activePracticeQuestion?.chapterID ?? 0,
            qID: self.activePracticeQuestion?.qID ?? "",
            addToStudyDeck: selected
        )
    }

    func updateDatabase() {
        for question in self.practiceQuestionsResponse {
            try? ExamManager.updateQuestion(chapterId: question.chapterId,
                                            qID: question.qID,
                                            isCurrentAttempted: question.isCurrentAttempted,
                                            isAnswerCorrect: question.isAnsweredCorrect,
                                            incorrectAnswer: question.incorrectAnswer)
        }
        var duplicates = [String: Int]()
        practiceQuestionsResponse.forEach { quest in
            duplicates[quest.qID] = (duplicates[quest.qID] ?? 0) + 1
        }
        self.view?.showExamResults()
    }
}
