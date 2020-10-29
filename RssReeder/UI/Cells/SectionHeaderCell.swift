import UIKit
import DeclarativeTVC

class SectionHeaderCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
}

struct SectionHeaderCellVM: CellModel
{
    let title: String
    
    func apply(to cell: SectionHeaderCell)
    {
        cell.titleLabel.text = title
    }
}
