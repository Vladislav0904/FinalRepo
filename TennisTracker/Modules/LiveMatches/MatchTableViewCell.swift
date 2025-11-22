import UIKit

final class MatchTableViewCell: UITableViewCell {
    weak var delegate: MatchTableViewCellDelegate?
    private var match: Match?

    private let player1ImageView = UIImageView()
    private let player2ImageView = UIImageView()
    private let player1Label = UILabel()
    private let player2Label = UILabel()
    private let scoreLabel = UILabel()
    private let tournamentLabel = UILabel()
    private let statusLabel = UILabel()
    private let favoriteIcon = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        setupTraitChangeObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupTraitChangeObserver()
    }

    private func setupTraitChangeObserver() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(updateColorsForTraitChange))
        }
    }

    @objc private func updateColorsForTraitChange() {
        updateColors()
    }

    @available(iOS, deprecated: 17.0, message: "Use registerForTraitChanges instead")
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground

        let imageSize: CGFloat = 32

        player1ImageView.contentMode = .scaleAspectFill
        player1ImageView.clipsToBounds = true
        player1ImageView.layer.cornerRadius = imageSize / 2
        player1ImageView.backgroundColor = .systemGray5
        player1ImageView.translatesAutoresizingMaskIntoConstraints = false

        player2ImageView.contentMode = .scaleAspectFill
        player2ImageView.clipsToBounds = true
        player2ImageView.layer.cornerRadius = imageSize / 2
        player2ImageView.backgroundColor = .systemGray5
        player2ImageView.translatesAutoresizingMaskIntoConstraints = false

        player1Label.font = .systemFont(ofSize: UIConstants.FontSize.large, weight: .semibold)
        player1Label.numberOfLines = 1
        player1Label.textColor = .label

        player2Label.font = .systemFont(ofSize: UIConstants.FontSize.large, weight: .semibold)
        player2Label.numberOfLines = 1
        player2Label.textColor = .label

        scoreLabel.font = .systemFont(ofSize: UIConstants.FontSize.medium, weight: .bold)
        scoreLabel.textColor = .systemBlue
        scoreLabel.numberOfLines = 1

        tournamentLabel.font = .systemFont(ofSize: UIConstants.FontSize.small)
        tournamentLabel.textColor = .secondaryLabel
        tournamentLabel.numberOfLines = 1

        statusLabel.font = .systemFont(ofSize: UIConstants.FontSize.small, weight: .medium)
        statusLabel.numberOfLines = 1

        favoriteIcon.image = UIImage(systemName: ImageConstants.SystemIcons.starFill)
        favoriteIcon.tintColor = ColorConstants.favoriteIcon
        favoriteIcon.contentMode = .scaleAspectFit
        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false

        let player1Stack = UIStackView(arrangedSubviews: [player1ImageView, player1Label])
        player1Stack.axis = .horizontal
        player1Stack.spacing = UIConstants.Spacing.medium
        player1Stack.alignment = .center
        player1Stack.isUserInteractionEnabled = true

        let player2Stack = UIStackView(arrangedSubviews: [player2ImageView, player2Label])
        player2Stack.axis = .horizontal
        player2Stack.spacing = UIConstants.Spacing.medium
        player2Stack.alignment = .center
        player2Stack.isUserInteractionEnabled = true

        let player1Tap = UITapGestureRecognizer(target: self, action: #selector(player1Tapped))
        player1Stack.addGestureRecognizer(player1Tap)

        let player2Tap = UITapGestureRecognizer(target: self, action: #selector(player2Tapped))
        player2Stack.addGestureRecognizer(player2Tap)

        let mainStackView = UIStackView(arrangedSubviews: [
            player1Stack,
            player2Stack,
            scoreLabel,
            tournamentLabel,
            statusLabel
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = UIConstants.StackView.defaultSpacing
        mainStackView.alignment = .leading
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStackView)
        contentView.addSubview(favoriteIcon)

        NSLayoutConstraint.activate([
            player1ImageView.widthAnchor.constraint(equalToConstant: imageSize),
            player1ImageView.heightAnchor.constraint(equalToConstant: imageSize),

            player2ImageView.widthAnchor.constraint(equalToConstant: imageSize),
            player2ImageView.heightAnchor.constraint(equalToConstant: imageSize),

            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Spacing.extraLarge),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.Spacing.large),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.Spacing.large),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: favoriteIcon.leadingAnchor, constant: -UIConstants.Spacing.medium),

            favoriteIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.Spacing.extraLarge),
            favoriteIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteIcon.widthAnchor.constraint(equalToConstant: UIConstants.IconSize.medium),
            favoriteIcon.heightAnchor.constraint(equalToConstant: UIConstants.IconSize.medium)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        player1ImageView.image = nil
        player2ImageView.image = nil
        match = nil
    }

    func configure(
        with match: Match,
        isFavorite: Bool,
        showLiveIndicator: Bool = true,
        player1Image: UIImage? = nil,
        player2Image: UIImage? = nil
    ) {
        self.match = match
        player1Label.text = match.firstPlayer.name
        player2Label.text = match.secondPlayer.name

        player1ImageView.image = player1Image
        player2ImageView.image = player2Image

        if !match.scores.isEmpty {
            let scoresText = match.scores.map { "\($0.firstPlayerScore)-\($0.secondPlayerScore)" }.joined(separator: " ")
            scoreLabel.text = scoresText
        } else if let finalResult = match.finalResult, !finalResult.isEmpty, finalResult != "0 - 0" {
            scoreLabel.text = finalResult
        } else if let gameResult = match.gameResult, !gameResult.isEmpty {
            scoreLabel.text = gameResult
        } else {
            scoreLabel.text = StringConstants.Status.defaultScore
        }

        tournamentLabel.text = match.tournament.name

        if match.isLive && showLiveIndicator {
            statusLabel.text = StringConstants.Status.live
            statusLabel.textColor = ColorConstants.statusLive
        } else {
            statusLabel.text = match.status.isEmpty ? StringConstants.Status.defaultScore : match.status
            statusLabel.textColor = .secondaryLabel
        }

        favoriteIcon.isHidden = !isFavorite
    }

    private func updateColors() {
        player1Label.textColor = .label
        player2Label.textColor = .label
        tournamentLabel.textColor = .secondaryLabel
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
    }

    @objc private func player1Tapped() {
        guard let match = match else { return }

        delegate?.matchCell(self, didTapPlayer: match.firstPlayer)
    }

    @objc private func player2Tapped() {
        guard let match = match else { return }

        delegate?.matchCell(self, didTapPlayer: match.secondPlayer)
    }
}
