import UIKit
import DeclarativeTVC

class SourceCell: XibTableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var switchControl: UISwitch!

    fileprivate var valueChangedCommand: Command?

    @IBAction private func switchControlValueChanged()
    {
        valueChangedCommand?.perform()
    }
}

struct SourceCellVM: CellModel
{
    let title: String
    let isActive: Bool
    let valueChangedCommand: Command?
    let removeCommand: Command

    func apply(to cell: SourceCell)
    {
        cell.titleLabel.text = title
        cell.switchControl.isOn = isActive
        cell.valueChangedCommand = valueChangedCommand
    }
}
