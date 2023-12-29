//
//  OptionTableViewCell.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit

class OptionTableViewCell: TableViewCell {
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionImage: UIImageView!
    @IBOutlet weak var optionView: UIView!
    
    var gradient = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setupUI()
    }
    
    func setupUI() {
        self.optionLabel.setFont(.s14)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.setupGradientBorderForView()
        
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? OptionCellModel else { return }
        self.optionLabel.text = model.text.capitalizingFirstLetter()
        self.optionLabel.textColor = model.state.labelColor
        self.optionImage.image = model.image
        self.optionImage.isHidden = model.isOptionImageHidden
        self.optionView.backgroundColor = model.state.backgroundColor
    }
    
    private func setupGradientBorderForView() {
        self.optionView.layer.borderWidth = 1
        self.optionView.layer.borderColor = UIColor.gray.cgColor
    }
    
}
