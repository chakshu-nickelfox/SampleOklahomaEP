//
//  DownloadContentHeaderModel.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 17/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

class DownloadContentCellModel {
    var title: String
    var buttonTitle:String
    var button:ShowButton
    var buttonColor: UIColor
    var selectedCount: String
    var hideActionButton: Bool

    init(title: String , buttonTitle: String, button:ShowButton, buttonColor: UIColor, selectedCount: Int, hideActionButton: Bool) {
        self.title = title
        self.buttonTitle =  buttonTitle
        self.button = button
        self.buttonColor = buttonColor
        self.selectedCount = selectedCount == 0 ? "" : "\(selectedCount)" + " " + Text.selected.localize()
        self.hideActionButton = hideActionButton
    }
}
