import UIKit
import DeclarativeTVC

class NewsImageCell: XibTableViewCell {

    @IBOutlet fileprivate weak var imageIV: UIImageView!
}

struct NewsImageCellVM: CellModel
{
    let imageURL: String

    func apply(to cell: NewsImageCell)
    {
        cell.imageIV.kf.setImage(with: URL(string: imageURL))
    }
}
