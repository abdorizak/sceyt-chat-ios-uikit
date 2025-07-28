//
//  ChannelEventView.swift
//  SceytChatUIKit
//
//  Created by Hovsep Keropyan on 29.09.22.
//  Copyright © 2022 Sceyt LLC. All rights reserved.
//

import UIKit

public struct ChannelEventTitleFormatterAttributes {
    public let channel: ChatChannel
    public let models: [ChannelEventModel]
    
    public init(channel: ChatChannel, models: [ChannelEventModel]) {
        self.channel = channel
        self.models = models
    }
}

public struct ChannelEventModel {
    public let user: ChatUser
    public let event: ChannelEventView.Event
    public let indicatorConfiguration: Indicator.Configuration

    public init(user: ChatUser, event: ChannelEventView.Event, indicatorConfiguration: Indicator.Configuration) {
        self.user = user
        self.event = event
        self.indicatorConfiguration = indicatorConfiguration
    }
}

open class ChannelEventView: View {

    public var indicatorView: ChatActionIndicator?
    open lazy var label = UILabel()
        .withoutAutoresizingMask
    public private(set) var channel: ChatChannel?
    public  var models: [ChannelEventModel] = []
    private var timer: Timer?
        
    deinit {
        stop()
    }

    open override func setupLayout() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    open override func setupAppearance() {
        super.setupAppearance()
        label.lineBreakMode = .byCharWrapping
        label.font = appearance.labelAppearance.font
        label.textColor = appearance.labelAppearance.foregroundColor
    }

    open func update(channel: ChatChannel, model: ChannelEventModel, isActive: Bool) {
        if !isActive {
            models.removeAll { $0.user.id == model.user.id }
        } else if !models.contains(where: { $0.user.id == model.user.id && $0.event == model.event }) {
            models.append(model)
            self.channel = channel
        }
        
        if models.isEmpty {
            stop()
        } else {
            Task {
                if self.timer == nil {
                    self.updateNextAction()
                    self.start()
                }
            }
        }
    }

    open func updateNextAction() {
        guard !models.isEmpty else {
            return
        }
        
        let model = models.removeFirst()
        label.attributedText = appearance.channelEventFormatter.format(ChannelEventTitleFormatterAttributes(channel: channel!, models: [model]))

        indicatorView?.removeFromSuperview()

        let view = model.indicatorConfiguration.viewProvider()
        view.translatesAutoresizingMaskIntoConstraints = false
        indicatorView = view
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 2),
            view.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            view.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])

        view.startAnimating()
    }

    public func start() {
        guard timer?.isValid != true else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateNextAction()
        }
    }
    
    @available(*, deprecated, message: "Use your own display formatting with using ChatActionDisplayFormatter protocol, before passing to ChatLiveAction. display(user:split:) will be removed.")
    open class func display(user: String, split: DisplaySplit = .maxLength(10)) -> String {
       return user
    }

    public func stop() {
        models = []
        channel = nil
        timer?.invalidate()
        timer = nil
        indicatorView?.stopAnimating()
        indicatorView?.removeFromSuperview()
        indicatorView = nil
    }

}

public extension ChannelEventView {
    
    enum DisplaySplit {
        case firstWord
        case maxLength(Int)
    }
}

public protocol ChatActionIndicator: View {
    func startAnimating()
    func stopAnimating()
}

// MARK: - Extended Protocol for Dot-Style Indicators

public protocol ColorConfigurableIndicator: ChatActionIndicator {
    func updateColors(_ colors: [UIColor])
}


public enum Indicator {

    public struct Configuration {
        public let viewProvider: () -> ChatActionIndicator

        public static func indicator(
            colors: [UIColor] = [
                .secondaryLabel.withAlphaComponent(1),
                .secondaryLabel.withAlphaComponent(0.6)
            ],
            ellipseSize: CGFloat = 5,
            ellipseDistance: CGFloat = 4
        ) -> Configuration {
            return Configuration {
                let view = DotIndicatorView()
                view.updateColors(colors)
                view.ellipseSize = ellipseSize
                view.ellipseDistance = ellipseDistance
                return view
            }
        }

        public static func custom(_ provider: @escaping () -> ChatActionIndicator) -> Configuration {
            Configuration(viewProvider: provider)
        }
    }
}


extension ChannelEventView {
    public enum Event {
        case typing
        case recording
        
        public var title: String {
            switch self {
            case .typing:
                return "\(L10n.Channel.Member.typing)"
            case .recording:
                return "\(L10n.Channel.Member.recording)"
            }
        }
    }
    
}

public final class DotIndicatorView: View, ColorConfigurableIndicator {
    private var offset = 0
    private var timer: Timer?

    public var colors: [CGColor] = []
    public var ellipseSize: CGFloat = 5
    public var ellipseDistance: CGFloat = 4

    public override var intrinsicContentSize: CGSize {
        let count = colors.count
        let width = CGFloat(count) * ellipseSize + CGFloat(max(0, count - 1)) * ellipseDistance
        return CGSize(width: width, height: ellipseSize)
    }
    
    public override func setup() {
        super.setup()
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    public override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        for i in 0..<colors.count {
            let index = (i + offset) % colors.count
            let x = CGFloat(i) * (ellipseSize + ellipseDistance)
            ctx.setFillColor(colors[index])
            ctx.fillEllipse(in: CGRect(x: x, y: 0, width: ellipseSize, height: ellipseSize))
        }
        offset = (offset + 1) % colors.count
    }

    public func startAnimating() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.setNeedsDisplay()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    public func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }

    public func updateColors(_ colors: [UIColor]) {
        self.colors = colors.map { $0.cgColor }
        setNeedsDisplay()
    }
}
