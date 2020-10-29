import UIKit
import DeclarativeTVC

class NewsBodyCell: XibTableViewCell {

    @IBOutlet fileprivate weak var bodyLabel: UILabel!
}

struct NewsBodyCellVM: CellModel
{
    let body: String

    func apply(to cell: NewsBodyCell)
    {
        cell.bodyLabel.text = body
    }
}
