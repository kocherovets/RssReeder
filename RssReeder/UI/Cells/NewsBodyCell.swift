//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class NewsBodyCell: XibTableViewCell {

    @IBOutlet fileprivate weak var bodyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct NewsBodyCellVM: CellModel
{
    let body: String

    func apply(to cell: NewsBodyCell)
    {
        cell.bodyLabel.text = body
    }
}
