import UIKit
import DeclarativeTVC

class UpdateIntervalCell: XibTableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
    }

    fileprivate var valueChangedCommand: CommandWith<Int>?

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.endEditing(true)

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        valueChangedCommand?.perform(with: Int(textField.text ?? "300") ?? 300)
    }
}

struct UpdateIntervalCellVM: CellModel
{
    let text: String?
    let valueChangedCommand: CommandWith<Int>?

    func apply(to cell: UpdateIntervalCell)
    {
        cell.textField.text = text
        cell.valueChangedCommand = valueChangedCommand
    }
}
