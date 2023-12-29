//
//  SimilarVideoCell.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit


class SimilarVideoCell: TableViewCell {
    
    @IBOutlet weak var similarSkillsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func configure(_ item: Any?) {
    }
    
    func setupUI() {
        self.similarSkillsLabel.text = Text.otherSkills.localize()
        self.similarSkillsLabel.setFont(FontType.m4)
    }
    
}
