//
//  SegmentTableHeaderView.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

struct SegmentTableHeaderViewModel {
    let selectedSegment: ListSegment
    let segmentTitles: [String]
}

protocol SegmentTableHeaderViewDelegate: AnyObject {
    func didSelectSegment(_ segment: ListSegment)
}

protocol SegmentTableHeaderViewUIDelegate: AnyObject {
    func updateSegment()
}

class SegmentTableHeaderView: TableHeaderFooterView {
    
    @IBOutlet weak var labelWidthConstariants: NSLayoutConstraint!
    @IBOutlet weak var segmentUnderlineView: UIView!
    @IBOutlet weak var segmentUnderlineViewLeading: NSLayoutConstraint!
    @IBOutlet weak var segmentStackView: UIStackView!
    
    var currentSelectedSegmentIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.deviceType()
    }
    
    func setupUI() {
        for index in 0..<self.segmentStackView.subviews.count {
            (self.segmentStackView.viewWithTag(index) as? UIButton)?.setFont(FontType.m4)
        }
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? SegmentTableHeaderViewModel else { return }
        self.setupUI()
        // set title for each button inside stack view
        for index in 0..<self.segmentStackView.subviews.count {
            (self.segmentStackView.viewWithTag(index) as? UIButton)?.setTitle(model.segmentTitles[index], for: .normal)
            (self.segmentStackView.viewWithTag(index) as? UIButton)?.isSelected = index == model.selectedSegment.rawValue ? true : false
            self.segmentUnderlineViewLeading.constant = ((self.segmentStackView.viewWithTag(model.selectedSegment.index) as? UIButton)?.frame.origin.x)!
        }
    }
    
    
    func deviceType() {
        if  UIDevice().userInterfaceIdiom  == .pad {
            self.labelWidthConstariants = self.labelWidthConstariants.setMultiplier(multiplier: 0.3)
        } else {
            self.labelWidthConstariants = self.labelWidthConstariants.setMultiplier(multiplier: 0.0)
        }
    }
}

// MARK: - Segment selections
extension SegmentTableHeaderView {
    @IBAction func didSelectSegment(_ sender: UIButton) {
        let selectedSegmentIndex = sender.tag
        guard let selectedSegment = ListSegment.init(rawValue: selectedSegmentIndex) else { return }
        // update selected state for each buttons inside the stack view
        for index in 0..<segmentStackView.subviews.count {
            if let segmentButton = (self.segmentStackView.viewWithTag(index) as? UIButton) {
                segmentButton.isSelected = segmentButton.tag == selectedSegmentIndex ? true : false
            }
        }
        /* update leading constraint of segment stack view's under line view so as to align it's x-position with the selected button's x-position
         */
        self.segmentUnderlineViewLeading.constant = ((self.segmentStackView.viewWithTag(selectedSegmentIndex) as? UIButton)?.frame.origin.x)!
        
        // call on delegate to take action after selecting segment
        (self.delegate as? SegmentTableHeaderViewDelegate)?.didSelectSegment(selectedSegment)
        self.currentSelectedSegmentIndex = selectedSegmentIndex
    }
}

//MARK: - Segment UI update delegate
extension SegmentTableHeaderView: SegmentTableHeaderViewUIDelegate {
    func updateSegment() {
        DispatchQueue.main.async {
            self.updateSegmentIndicator()
            self.contentView.layoutIfNeeded()
        }
    }
    
    func updateSegmentIndicator() {
        /* update leading constraint of segment stack view's under line view so as to align it's x-position with the selected button's x-position
         */
        self.segmentUnderlineViewLeading.constant = ((self.segmentStackView.viewWithTag(self.currentSelectedSegmentIndex) as? UIButton)?.frame.origin.x)!
    }
} 
