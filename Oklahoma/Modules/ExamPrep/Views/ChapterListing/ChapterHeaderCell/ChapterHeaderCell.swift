//
//  ChapterHeaderCell.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import UIKit

protocol ChapterHeaderCellDelegate: AnyObject {
    func didTapButton(type: ExamPrepButtonType?)
}

class ChapterHeaderCell: TableViewCell {
    
    @IBOutlet weak var examCountLabel: UILabel!
    @IBOutlet weak var selectedCountLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func configure(_ item: Any?) {
        if let item = item as? ChapterHeaderCellModel {
            self.examCountLabel.text = item.totalCount
            self.selectedCountLabel.text = item.selectedCount
            self.actionButton.setTitle(item.type?.buttonTitle, for: .normal)
            
            switch item.type {
            case .buy:
                self.actionButton.setImage(UIImage(named: Image.AudioBooks.buyAll.rawValue), for: .normal)
            case .unselect:
                self.actionButton.setImage(nil, for: .normal)
            case .selectAll:
                self.actionButton.setImage(nil, for: .normal)
            case .enableSelection:
                self.actionButton.setImage(nil, for: .normal)
            case .none:
                self.actionButton.setImage(nil, for: .normal)
                self.actionButton.setTitle("Select Exams", for: .normal)
            }
        }
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        if let item = item as? ChapterHeaderCellModel {
            if let delegate = self.delegate as? ChapterHeaderCellDelegate {
                delegate.didTapButton(type: item.type)
            }
        }
    }
    
}
