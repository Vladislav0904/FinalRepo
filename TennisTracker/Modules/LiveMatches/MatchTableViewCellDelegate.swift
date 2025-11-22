import Foundation

protocol MatchTableViewCellDelegate: AnyObject {
    func matchCell(_ cell: MatchTableViewCell, didTapPlayer playerInfo: PlayerInfo)
}
