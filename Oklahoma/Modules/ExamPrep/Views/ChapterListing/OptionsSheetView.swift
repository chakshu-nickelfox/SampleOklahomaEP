//
//  OptionsSheetView.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import UIKit

protocol OptionsSheetViewDelegate: AnyObject {
    func didSelected(option: SheetActionType)
    func removeDimmedView()
}

class OptionsSheetView: UIView {
    
    var delegate: OptionsSheetViewDelegate?
    
    static var newInstance: OptionsSheetView? {
        return Bundle.main.loadNibNamed(
            OptionsSheetView.className(),
            owner: nil,
            options: nil
        )?.first as? OptionsSheetView
    }
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var clearTestResultsButton: UIButton!
    @IBOutlet weak var clearStudyDeckButton: UIButton!
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var outerTapView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isHidden = false
        self.setupUI()
        self.setupGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mainBackgroundView.roundCorners(corners: [.topLeft, .topRight], radius: 8)
    }
 
    func setupUI() {
        self.clearStudyDeckButton.setFont(.h16)
        self.clearTestResultsButton.setFont(.h16)
    }
    
    func setupGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDownGesture(_:)))
        swipeGesture.direction = [.down]
        self.addGestureRecognizer(swipeGesture)
    }
    
    func printing() {
        self.hideSelf()
    }
    
    @objc
    func handleSwipeDownGesture(_ sender: UISwipeGestureRecognizer) {
        self.hideSelf()
    }
    
    @IBAction func didTapFirstButton(_ sender: UIButton) {
        if sender.tag == 1 {
            self.delegate?.didSelected(option: .clearStudyDeck)
        } else {
            self.delegate?.didSelected(option: .clearTestResults)
            
        }
        self.hideSelf()
    }
    
    func hideSelf() {
        self.isHidden = true
        self.delegate?.removeDimmedView()
    }
}
