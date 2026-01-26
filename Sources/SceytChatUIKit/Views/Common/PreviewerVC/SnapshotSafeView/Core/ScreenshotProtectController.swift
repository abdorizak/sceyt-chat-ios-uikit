//
//  ScreenshotProtectController.swift
//  
//
//  Created by Князьков Илья on 02.03.2022.
//

import UIKit

/**
Controller on hide from screenshot and screen recording states of content
 
 Example usage:
```
 final class ExampleSecureViewController: UIViewController {
     
     let hiddenFromScreenshotButtonController = ScreenshotProtectController(content: UIButton())

     override func viewDidLoad() {
         super.viewDidLoad()
         hiddenFromScreenshotButtonController.content.backgroundColor = .red // UI customization apply to content
         hiddenFromScreenshotButtonController.content.layer.cornerRadius = 16
         
         view.addSubview(hiddenFromScreenshotButtonController.container)
         hiddenFromScreenshotButtonController.container // Layout control apply to container
             .position
             .pin(to: view.safeAreaLayoutGuide, const: 65)
         
         hiddenFromScreenshotButtonController.setupContentAsHiddenInScreenshotMode() // apply hidden mode
         // content will be removed from system screenshots and screen recording
     }
     
 }

```
*/
open class ScreenshotProtectController<Content: UIView>: ScreenshotProtectControllerProtocol {
    
    public typealias ProtectiveContainer = ScreenshotInvincibleContainerProtocol
    
    /// - View, which will be hidden on screenshots and screen recording
    /// - All operation with UI customization need perform at content
    public var content: Content
    
    /// - Container view, all operation with layout need perform at container
    public lazy var container: ProtectiveContainer = ScreenshotInvincibleContainer(content: content)
    
    /// - Whether to show overlay in screenshots (default: false for backward compatibility)
    public var showsOverlayInScreenshots: Bool = false
    
    /// - The overlay view shown in screenshots when content is protected
    /// - This view is visible in screenshots while the actual content is hidden
    public lazy var protectedContentOverlay: ProtectedContentOverlayView = Components.protectedContentOverlayView.init()
    
    /// - Wrapper view that contains both the overlay (background) and secure container (foreground)
    /// - Use this view for layout instead of container when showsOverlayInScreenshots is true
    public lazy var wrapperView: UIView = {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        return wrapper
    }()
    
    private var isOverlayConfigured = false
    
    public init(content: Content) {
        self.content = content
    }
    
    public func eraseOldAndAddnewContent(_ newContent: Content) {
        container.eraseOldAndAddnewContent(newContent)
    }
    
    public func setupContentAsHiddenInScreenshotMode() {
        container.setupContanerAsHideContentInScreenshots()
        
        if showsOverlayInScreenshots {
            configureOverlayIfNeeded()
        }
    }
    
    public func setupContentAsDisplayedInScreenshotMode() {
        container.setupContanerAsDisplayContentInScreenshots()
    }
    
    /// Configures the wrapper view with overlay and secure container layered properly.
    /// Call this after adding wrapperView to your view hierarchy.
    private func configureOverlayIfNeeded() {
        guard !isOverlayConfigured else { return }
        isOverlayConfigured = true
        
        // Add overlay as background (visible in screenshots)
        wrapperView.addSubview(protectedContentOverlay)
        protectedContentOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            protectedContentOverlay.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            protectedContentOverlay.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            protectedContentOverlay.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            protectedContentOverlay.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
        ])
        
        // Add secure container as foreground (hidden in screenshots, visible on device)
        wrapperView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            container.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
        ])
    }
    
    /// Sets up the wrapper view with overlay support.
    /// Use this method when you want to show a custom overlay in screenshots.
    /// - Parameter parentView: The parent view to add the wrapper to
    /// - Returns: The wrapper view for additional layout configuration
    @discardableResult
    public func setupWithOverlay(in parentView: UIView) -> UIView {
        showsOverlayInScreenshots = true
        
        parentView.addSubview(wrapperView)
        configureOverlayIfNeeded()
        setupContentAsHiddenInScreenshotMode()
        
        return wrapperView
    }
}
