//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class AddSourceCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct AddSourceCellVM: CellModel, SelectableCellModel
{
    let title: String
    let selectCommand: Command

    func apply(to cell: AddSourceCell)
    {
        cell.titleLabel.text = title
    }
}
