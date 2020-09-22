//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class SectionHeaderCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct SectionHeaderCellVM: CellModel
{
    let title: String
    
    func apply(to cell: SectionHeaderCell)
    {
        cell.titleLabel.text = title
    }
}
