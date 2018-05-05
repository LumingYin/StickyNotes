//
//  InteractiveButton.swift
//  Sticky Notes
//
//  Created by Numeric on 5/5/18.
//  Copyright © 2018 Kenny. All rights reserved.
//

import Cocoa

class InteractiveButton: NSButton {
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer?.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var activeButtonColor: NSColor? {
        didSet {
            if let color = activeButtonColor {
                layer?.backgroundColor = color.cgColor
            }
        }
    }


    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        let area = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        self.addTrackingArea(area)
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.animator().alphaValue = 0.7
        self.animator().layer?.backgroundColor = NSColor.white.withAlphaComponent(0.4).cgColor
        NSCursor.pointingHand.set()
    }
    
    override func mouseExited(with event: NSEvent) {
        self.animator().alphaValue = 1.0
        self.animator().layer?.backgroundColor = NSColor.clear.cgColor
        NSCursor.arrow.set()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) in
            context.duration = 0.1
            self.animator().alphaValue = 1.0
        }, completionHandler: {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.1
                self.animator().alphaValue = 0.7
            }, completionHandler: nil)
        })
    }

    
}
