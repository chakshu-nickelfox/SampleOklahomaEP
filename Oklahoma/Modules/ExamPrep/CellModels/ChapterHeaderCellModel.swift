//
//  ChapterHeaderCellModel.swift
//  LifeSafetyEducator4
//
//  Created by Vaibhav Parmar on 29/09/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import Foundation

class ChapterHeaderCellModel {
    var totalCount: String
    var selectedCount: String
    var type: ExamPrepButtonType?
    
    init(totalCount: Int,
         selectedCount: Int,
         type: ExamPrepButtonType?) {
        self.totalCount = totalCount == 0 ? "" : "\(totalCount) Exams"
        self.selectedCount = selectedCount == 0 ? "" : "\(selectedCount) \(Constant.selected.capitalized)"
        self.type = type
    }
}
