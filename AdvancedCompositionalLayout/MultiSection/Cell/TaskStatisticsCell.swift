//
//  TaskStatisticsCell.swift
//  AdvancedCompositionalLayout
//
//  Created by Ahmed Tarık Bozyak on 22.06.2023.
//

import Foundation
import UIKit

class TaskStatisticsCell: UICollectionViewCell {
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, spacerView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.text = "<title>"
        label.numberOfLines = 1
        return label
    }()
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemGray5
        label.text = "<subtitle>"
        label.numberOfLines = 2
        return label
    }()
    
    lazy var spacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }()
    
    lazy  var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "cardBackgroundImage2")
        return imageView
    }()
    
    lazy var progressView: CustomProgressView = {
        let progressView = CustomProgressView(type: .circular)
        progressView.progressColor = .white
        progressView.trackColor = .systemGray5.withAlphaComponent(0.5)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layerConfigure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layerConfigure()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("GridCell coder has not been implemented")
    }
    
    func setupView(){
        addSubview(imageView)
        imageView.edgesToSuperview()
        addSubview(stackView)
        addSubview(progressView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            progressView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            progressView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            progressView.widthAnchor.constraint(equalTo: progressView.heightAnchor, multiplier: 1.0),
            stackView.rightAnchor.constraint(equalTo: progressView.leftAnchor, constant: -10)
            
        ])
    }
    
    func configure(with item: TaskStatistics) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        progressView.progress = item.progress
    }
    
    func layerConfigure(){
        let isLandscape = frame.width / frame.height > 1 ? true : false
        let cornerRadius = isLandscape ? frame.height / 10 : frame.width / 10
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowRadius = 8.0
        layer.shadowOpacity = 0.10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
    }
}
