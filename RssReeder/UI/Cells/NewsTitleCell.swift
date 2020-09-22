//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class NewsTitleCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct NewsTitleCellVM: CellModel
{
    let title: String

    func apply(to cell: NewsTitleCell)
    {
        cell.titleLabel.text = title
    }
}
