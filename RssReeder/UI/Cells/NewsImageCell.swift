//
//  NewsDateCell.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//

import UIKit
import DeclarativeTVC

class NewsImageCell: XibTableViewCell {

    @IBOutlet fileprivate weak var imageIV: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

struct NewsImageCellVM: CellModel
{
    let imageURL: String

    func apply(to cell: NewsImageCell)
    {
        cell.imageIV.kf.setImage(with: URL(string: imageURL))
    }
}
