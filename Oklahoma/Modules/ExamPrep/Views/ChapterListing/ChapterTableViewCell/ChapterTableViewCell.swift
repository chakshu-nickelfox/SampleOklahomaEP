//
//  ChapterTableViewCell.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import UIKit
import ReactiveSwift

class ChapterTableViewCell: TableViewCell {
    
    @IBOutlet weak var chapterNumberLabel: UILabel!
    @IBOutlet weak var chapterTitleLabel: UILabel!
    @IBOutlet weak var questionCountLabel: UILabel!
    @IBOutlet weak var chapterListingView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.chapterListingView.roundedCorner(radius: 6)
        self.chapterNumberLabel.setFont(.h16)
        self.chapterTitleLabel.setFont(.p14)
        self.questionCountLabel.setFont(.p14)
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? ChapterCellModel else { return }
        self.chapterNumberLabel.text = model.chapterId
        self.chapterTitleLabel.text = model.chapterName
        // checkbox button is hidden for in accessible(unpaid) chapters
        self.selectButton.isHidden = model.isHidden
        self.selectButton.isSelected = model.isSelected
        self.chapterListingView.alpha = model.isAccessible ? 1.0 : 0.4
        self.isUserInteractionEnabled = model.isAccessible
        self.questionCountLabel.text = model.numberOfQuestions
    }
    
}
