//
//  QuestionResultTableViewCell.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit

protocol QuestionResultTableViewCellDelegate: AnyObject {
    func didTapAddToStudyDeck(for chapterId: Int,
                              qID: String,
                              isStudyDeckEnabled: Bool)
}

class QuestionResultTableViewCell: TableViewCell {

    @IBOutlet weak var referencePageLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var wrongAnswerLabel: UILabel!
    @IBOutlet weak var resultContainerView: UIView!
    @IBOutlet weak var addToStudyDeckButton: UIButton!
    @IBOutlet weak var skippedStackView: UIStackView!
    
    var gradient = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setupUI()
    }
    
    func setupUI() {
        self.questionTextLabel.setFont(.p16)
        self.wrongAnswerLabel.setFont(.p16)
        self.correctAnswerLabel.setFont(.p16)
        self.referencePageLabel.setFont(.s12)
        self.resultContainerView.layer.borderWidth = 1
        self.resultContainerView.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? QuestionResultCellModel else { return }
        self.referencePageLabel.text = model.referenceNumber
        self.questionTextLabel.text = model.questionText
        self.wrongAnswerLabel.text = model.incorrectAnswer.capitalizingFirstLetter()
        self.correctAnswerLabel.text = model.correctAnswer.capitalizingFirstLetter()
        self.skippedStackView.isHidden = !model.isSkipped
        self.addToStudyDeckButton.isSelected = model.isAddedToStudyDeck
    }
    
    @IBAction func addToStudyDeckButton(_ sender: UIButton) {
        self.addToStudyDeckButton.isSelected = !self.addToStudyDeckButton.isSelected
        guard let model = item as? QuestionResultCellModel else { return }
        if let delegate = self.delegate as? QuestionResultTableViewCellDelegate {
            delegate.didTapAddToStudyDeck(for: model.chapterId,
                                          qID: model.qID,
                                          isStudyDeckEnabled: sender.isSelected)
        }
    }
    
    private func setupGradientBorderForView() {
        self.resultContainerView.clipsToBounds = true
        self.gradient.frame =  CGRect(origin: .zero,
                                      size: self.resultContainerView.frame.size)
        self.gradient.colors = [UIColor.white.cgColor,
                                UIColor.darkGray.cgColor]

        let shape = CAShapeLayer()
        shape.lineWidth = 2
        
        shape.path = UIBezierPath(roundedRect: self.resultContainerView.bounds,
                                  cornerRadius: self.resultContainerView.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        self.gradient.mask = shape
        
        self.resultContainerView.layer.addSublayer(self.gradient)
    }
    
}
