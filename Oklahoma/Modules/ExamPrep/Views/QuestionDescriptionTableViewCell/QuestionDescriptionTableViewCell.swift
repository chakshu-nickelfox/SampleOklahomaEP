//
//  QuestionDescriptionTableViewCell.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit

protocol QuestionDescriptionTableViewCellDelegate: AnyObject {
    func didTapAddToStudyDeck(_ selected: Bool)
}

class QuestionDescriptionTableViewCell: TableViewCell {

    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionAttemptsLabel: UILabel!
    @IBOutlet weak var questionReferenceLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var addToStudyDeckButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setupUI()
    }
    
    func setupUI() {
        self.questionTextLabel.setFont(.s14)
        self.questionAttemptsLabel.setFont(.s12)
        self.addToStudyDeckButton.setFont(.s12)
        self.questionReferenceLabel.setFont(.s12)
    }
    override func configure(_ item: Any?) {
        guard let model = item as? QuestionDescriptionCellModel else { return }
        self.questionNumberLabel.text = model.questionSubTitle
        self.questionTextLabel.text = model.text
        self.questionReferenceLabel.text = model.referenceNumber
        self.addToStudyDeckButton.isHidden = !model.isStudyDeckVisible
        self.addToStudyDeckButton.isSelected = model.isStudyDeckEnabled
        self.questionAttemptsLabel.isHidden = model.attemptLabelHidden
        self.questionAttemptsLabel.text = "Attempts Left : " + String(model.currentAttempt ?? 0)
    }
    
    @IBAction func addToStudyDeckAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        (self.delegate as? QuestionDescriptionTableViewCellDelegate)?.didTapAddToStudyDeck(sender.isSelected)
    }
    
}
