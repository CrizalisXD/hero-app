//
//  FLTUnityView.swift
//  flutter_unity_widget
//
//  Created by Rex Raphael on 30/01/2021.
//

import Foundation
import UIKit
import QuartzCore
import Metal
import UnityFramework

class FLTUnityView: UIView {
    private var transparencyTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTransparency()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTransparency()
    }

    deinit {
        transparencyTimer?.invalidate()
    }

    // Let the Flutter background (home_bg.jpg) show through the Unity layer.
    // Effective together with the Unity camera Clear Flags = Solid Color,
    // background alpha 0.
    private func configureTransparency() {
        self.isOpaque = false
        self.backgroundColor = .clear
        // Unity re-creates its CAMetalLayer surface on boot/resize AFTER our
        // layoutSubviews pass, restoring opaque=YES and re-blackening the
        // view. Re-assert transparency on a short heartbeat for the first
        // seconds of the view's life — cheap, and closes the race for good.
        transparencyTimer?.invalidate()
        var ticks = 0
        transparencyTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            let unityView = GetUnityPlayerUtils().ufw?.appController()?.rootView
            self.makeTreeTransparent(unityView)
            ticks += 1
            if ticks >= 20 { timer.invalidate() }  // ~10 seconds
        }
    }

    // Walk the whole Unity view tree and force every UIView + its backing
    // layer (including the Metal render layer) to be non-opaque, otherwise the
    // engine composites onto an opaque black surface and hides the Flutter
    // background underneath.
    private func makeTreeTransparent(_ view: UIView?) {
        guard let view = view else { return }
        view.isOpaque = false
        view.backgroundColor = .clear
        makeLayerTreeTransparent(view.layer)
        for sub in view.subviews {
            makeTreeTransparent(sub)
        }
    }

    // The Metal layer isn't always the backing layer of a UIView — Unity can
    // attach it as a SUBLAYER, which a UIView-only walk misses. Walk the
    // CALayer tree too.
    private func makeLayerTreeTransparent(_ layer: CALayer?) {
        guard let layer = layer else { return }
        layer.isOpaque = false
        if let metal = layer as? CAMetalLayer {
            metal.isOpaque = false
            metal.backgroundColor = UIColor.clear.cgColor
        }
        for sub in layer.sublayers ?? [] {
            makeLayerTreeTransparent(sub)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if (!self.bounds.isEmpty) {
            let unityView = GetUnityPlayerUtils().ufw?.appController()?.rootView
            unityView?.frame = self.bounds
            makeTreeTransparent(unityView)
            unityView?.superview?.isOpaque = false
            unityView?.superview?.backgroundColor = .clear
        }
    }
}
