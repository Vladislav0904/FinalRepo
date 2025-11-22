import UIKit

final class RankingTableViewCell: UITableViewCell {
    static let identifier = "RankingCell"

    private lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: UIConstants.FontSize.large)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UIConstants.FontSize.medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UIConstants.FontSize.small)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var pointsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UIConstants.FontSize.medium)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground

        contentView.addSubview(rankLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(countryLabel)
        contentView.addSubview(pointsLabel)

        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Spacing.medium),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: UIConstants.Spacing.medium),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.Spacing.small),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -UIConstants.Spacing.medium),

            countryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            countryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: UIConstants.Spacing.small),
            countryLabel.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -UIConstants.Spacing.medium),
            countryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.Spacing.small),

            pointsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.Spacing.medium),
            pointsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pointsLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    func configure(with ranking: PlayerRanking) {
        rankLabel.text = ranking.rank.map { "\($0)" } ?? "-"
        nameLabel.text = ranking.player.name
        countryLabel.text = ranking.player.country ?? "N/A"

        if let points = ranking.points {
            pointsLabel.text = "\(points) pts"
        } else {
            pointsLabel.text = "-"
        }
    }
}
