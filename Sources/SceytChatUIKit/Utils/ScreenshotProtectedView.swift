//
//  File.swift
//  SceytChatUIKit
//
//  Created by Sargis Mkhitaryan on 24.12.25.
//

import UIKit

final class ScreenshotProtectedView: UIView {

    private let secureField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        secureField.isSecureTextEntry = true
        secureField.isUserInteractionEnabled = false
        secureField.backgroundColor = .clear

        addSubview(secureField)
        secureField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secureField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureField.trailingAnchor.constraint(equalTo: trailingAnchor),
            secureField.topAnchor.constraint(equalTo: topAnchor),
            secureField.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func setProtectedContent(_ content: UIView) {
        secureField.subviews.forEach { $0.removeFromSuperview() }
        secureField.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: secureField.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: secureField.trailingAnchor),
            content.topAnchor.constraint(equalTo: secureField.topAnchor),
            content.bottomAnchor.constraint(equalTo: secureField.bottomAnchor),
        ])
    }
}
