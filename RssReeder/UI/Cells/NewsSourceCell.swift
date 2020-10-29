import UIKit
import DeclarativeTVC

class NewsSourceCell: XibTableViewCell {

    @IBOutlet fileprivate weak var sourceLabel: UILabel!
}

struct NewsSourceCellVM: CellModel
{
    let source: String

    func apply(to cell: NewsSourceCell)
    {
        cell.sourceLabel.text = source
    }
}
