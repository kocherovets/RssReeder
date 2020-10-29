import UIKit
import DeclarativeTVC

class AddSourceCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
}

struct AddSourceCellVM: CellModel, SelectableCellModel
{
    let title: String
    let selectCommand: Command

    func apply(to cell: AddSourceCell)
    {
        cell.titleLabel.text = title
    }
}
