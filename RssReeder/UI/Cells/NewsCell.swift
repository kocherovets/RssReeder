import UIKit
import DeclarativeTVC
import Kingfisher

class NewsCell: XibTableViewCell {
    
    @IBOutlet fileprivate weak var sourceLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var bodyLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var imageIV: UIImageView!
    @IBOutlet fileprivate weak var starImageIV: UIImageView!
}

struct NewsCellVM: CellModel, SelectableCellModel
{
    let source: String
    let title: String
    let body: String
    let hideBody: Bool
    let time: String
    let imageURL: String
    let unread: Bool
    let starred: Bool
    let selectCommand: Command

    func apply(to cell: NewsCell)
    {
        cell.sourceLabel.text = source
        cell.titleLabel.text = title
        cell.titleLabel.textColor = unread ? UIColor.black : UIColor.lightGray
        cell.bodyLabel.text = body
        cell.bodyLabel.textColor = unread ? UIColor.darkGray : UIColor.lightGray
        cell.bodyLabel.isHidden = hideBody
        cell.timeLabel.text = time
        cell.imageIV.kf.setImage(with: URL(string: imageURL))
        cell.starImageIV.isHidden = !starred
        
        cell.layoutIfNeeded()
    }
}
