//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class NewsHeaderCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct NewsHeaderCellVM: TableHeaderModel
{
    let title: String
    
    func apply(to cell: NewsHeaderCell)
    {
        cell.titleLabel.text = title
    }
    
//    var height: CGFloat? { 35 }
}
