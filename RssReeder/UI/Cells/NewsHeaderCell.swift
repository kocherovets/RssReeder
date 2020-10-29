import UIKit
import DeclarativeTVC

class NewsHeaderCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
}

struct NewsHeaderCellVM: TableHeaderModel
{
    let title: String
    
    func apply(to cell: NewsHeaderCell)
    {
        cell.titleLabel.text = title
    }
}
