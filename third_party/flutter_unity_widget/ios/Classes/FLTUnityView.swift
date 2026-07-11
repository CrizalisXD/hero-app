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
            if ticks == 8 { self.dumpHierarchy() }  // диагностика: один снимок
            if ticks >= 20 { timer.invalidate() }  // ~10 seconds
        }
    }

    // ── Диагностика: полный дамп иерархии окна в файл Documents ──────
    // flutter run не пробрасывает NSLog — пишем в файл и забираем его с
    // устройства через `devicectl device copy from`.
    private func dumpHierarchy() {
        var out = "===== WINDOW HIERARCHY =====\n"
        if let w = self.window {
            dumpView(w, depth: 0, into: &out)
        } else {
            out += "no window\n"
        }
        // Дерево CALayer отдельно — оверлеи Flutter и Metal-слои могут не
        // иметь UIView-обёртки.
        if let wl = self.window?.layer {
            out += "===== WINDOW LAYER TREE =====\n"
            dumpLayer(wl, depth: 0, into: &out)
        }
        out += "===== END =====\n"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            try? out.write(to: dir.appendingPathComponent("hero_dump.txt"), atomically: true, encoding: .utf8)
        }
        NSLog("[HERO-DUMP] written")
    }

    private func dumpView(_ v: UIView, depth: Int, into out: inout String) {
        let pad = String(repeating: "| ", count: depth)
        let l = v.layer
        let bg = v.backgroundColor.map { c -> String in
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            c.getRed(&r, green: &g, blue: &b, alpha: &a)
            return String(format: "rgba(%.1f,%.1f,%.1f,%.1f)", r, g, b, a)
        } ?? "nil"
        out += String(format: "%@%@ f=(%.0f,%.0f %.0fx%.0f) op=%d a=%.2f hid=%d bg=%@ L=%@ Lop=%d\n",
                      pad, NSStringFromClass(type(of: v)),
                      v.frame.origin.x, v.frame.origin.y, v.frame.width, v.frame.height,
                      v.isOpaque ? 1 : 0, v.alpha, v.isHidden ? 1 : 0, bg,
                      NSStringFromClass(type(of: l)), l.isOpaque ? 1 : 0)
        for s in v.subviews { dumpView(s, depth: depth + 1, into: &out) }
    }

    private func dumpLayer(_ l: CALayer, depth: Int, into out: inout String) {
        let pad = String(repeating: "| ", count: depth)
        let bg = l.backgroundColor.map { c -> String in
            let comps = c.components ?? []
            return "rgba(" + comps.map { String(format: "%.1f", $0) }.joined(separator: ",") + ")"
        } ?? "nil"
        out += String(format: "%@%@ f=(%.0f,%.0f %.0fx%.0f) op=%d hid=%d bg=%@\n",
                      pad, NSStringFromClass(type(of: l)),
                      l.frame.origin.x, l.frame.origin.y, l.frame.width, l.frame.height,
                      l.isOpaque ? 1 : 0, l.isHidden ? 1 : 0, bg)
        for s in l.sublayers ?? [] { dumpLayer(s, depth: depth + 1, into: &out) }
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
