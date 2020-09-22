//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class NewsDateCell: XibTableViewCell {

    @IBOutlet fileprivate weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct NewsDateCellVM: CellModel
{
    let date: String

    func apply(to cell: NewsDateCell)
    {
        cell.dateLabel.text = date
    }
}
