import UIKit
import SceytChatUIKit
import SceytChat

final class ChannelsViewController: ChannelListViewController {
    override func setup() {
        dataSourceMode = .diffable
        super.setup()
    }
}
