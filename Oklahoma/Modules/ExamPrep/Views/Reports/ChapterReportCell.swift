//
//  ChapterReportCell.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit

class ChapterReportCell: TableViewCell {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var chaptersProgressView: CustomProgressBar!
    @IBOutlet weak var chapterPercentage: UILabel!
    @IBOutlet weak var chapterName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
   
    private func setupUI() {
        self.chapterPercentage.setFont(FontType.s14)
        self.chapterName.setFont(FontType.s14)
        self.topView.roundedCorner(radius: 5)
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? ChapterCellModel else { return }
        self.topView.alpha = model.isAccessible ? 1.0 : 0.4
        self.chapterName.text = model.chapterId
        self.chapterPercentage.text =  model.chapterScore
        self.isUserInteractionEnabled = model.isAccessible
        self.chaptersProgressView.progress = model.chapterProgress
    }
    
}
