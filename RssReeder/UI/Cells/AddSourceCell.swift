//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class AddSourceCell: XibTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct AddSourceCellVM: CellModel, SelectableCellModel
{
    let selectCommand: Command

    func apply(to cell: AddSourceCell)
    {
    }
}
