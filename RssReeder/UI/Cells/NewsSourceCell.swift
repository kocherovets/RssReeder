//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class NewsSourceCell: XibTableViewCell {

    @IBOutlet fileprivate weak var sourceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct NewsSourceCellVM: CellModel
{
    let source: String

    func apply(to cell: NewsSourceCell)
    {
        cell.sourceLabel.text = source
    }
}
