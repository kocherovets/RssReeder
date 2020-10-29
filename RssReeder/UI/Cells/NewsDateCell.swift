import UIKit
import DeclarativeTVC

class NewsDateCell: XibTableViewCell {

    @IBOutlet fileprivate weak var dateLabel: UILabel!
}

struct NewsDateCellVM: CellModel
{
    let date: String

    func apply(to cell: NewsDateCell)
    {
        cell.dateLabel.text = date
    }
}
