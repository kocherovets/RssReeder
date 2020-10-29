import UIKit
import DeclarativeTVC

class NewsTitleCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
}

struct NewsTitleCellVM: CellModel
{
    let title: String

    func apply(to cell: NewsTitleCell)
    {
        cell.titleLabel.text = title
    }
}
