//
//  StickieWindowController.swift
//  Sticky Notes
//
//  Created by Numeric on 5/4/18.
//  Copyright © 2018 Kenny. All rights reserved.
//

import Cocoa

class StickieWindowController: NSWindowController {
    @IBOutlet weak var plusButton: NSButton!
    @IBOutlet weak var moreButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var contentBox: NSBox!
    @IBOutlet weak var titleBarBox: NSBox!
    @IBOutlet weak var colorSelectorBox: NSBox!
    @IBOutlet weak var colorBoxTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorButtonsStackView: NSStackView!
    
    convenience init() {
        self.init(windowNibName: NSNib.Name(rawValue: "StickieWindowController"))
    }

    override func windowWillLoad() {
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.standardWindowButton(.closeButton)?.isHidden = true
        self.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true
        
        let plusTrackingArea = NSTrackingArea.init(rect: plusButton.bounds, options: NSTrackingArea.Options(rawValue: NSTrackingArea.Options.RawValue(UInt8(NSTrackingArea.Options.mouseEnteredAndExited.rawValue) | UInt8(NSTrackingArea.Options.activeAlways.rawValue))), owner: self, userInfo: nil)
        plusButton.addTrackingArea(plusTrackingArea)

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("mouse entered \(event)")
        if let cell = plusButton.cell as? NSButtonCell {
            cell.backgroundColor = NSColor.black.withAlphaComponent(0.5)
            
        }

    }
    
    override func mouseExited(with event: NSEvent) {
        print("mouse exited \(event)")
        if let cell = plusButton.cell as? NSButtonCell {
            cell.backgroundColor = NSColor.black.withAlphaComponent(0)
        }

    }
    
    @IBAction func colorChanged(_ sender: FlatButton) {
        
//        let color = sender.activeButtonColor
//        print(color)
//        titleBarBox.fillColor = color
        updateColorAccordingToTag(tag: sender.tag)
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.2
        NSAnimationContext.current.completionHandler = {
            self.colorBoxTopConstraint.constant = -64
        }
        colorBoxTopConstraint.animator().constant = -64
        NSAnimationContext.endGrouping()

    }
    
    func updateColorAccordingToTag(tag: Int) {
        switch tag {
        case 0:
            updateColorAccordingToString(colorName: "yellow")
        case 1:
            updateColorAccordingToString(colorName: "green")
        case 2:
            updateColorAccordingToString(colorName: "blue")
        case 3:
            updateColorAccordingToString(colorName: "purple")
        case 4:
            updateColorAccordingToString(colorName: "pink")
        case 5:
            updateColorAccordingToString(colorName: "gray")
        default:
            updateColorAccordingToString(colorName: "yellow")

        }
    }
    
    func updateColorAccordingToString(colorName: String) {
        guard let dark = NSColor(named: NSColor.Name(rawValue: "\(colorName)_dark")), let light = NSColor(named: NSColor.Name(rawValue: "\(colorName)_light")), let medium = NSColor(named: NSColor.Name(rawValue: "\(colorName)_medium")) else {
            return
        }
        self.titleBarBox.fillColor = dark
        self.colorSelectorBox.fillColor = light
        self.contentBox.fillColor = medium

    }
    
    @IBAction func moreColorOptions(_ sender: Any) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.2
        NSAnimationContext.current.completionHandler = {
            self.colorBoxTopConstraint.constant = 0
        }
        colorBoxTopConstraint.animator().constant = 0
        NSAnimationContext.endGrouping()
    }
    
    @IBAction func deleteStickyNote(_ sender: Any) {
        let deleteVC = DeleteNoteViewController()
        let horC = NSLayoutConstraint(item: deleteVC.view, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.window!.contentView!, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0.0)
        let verC = NSLayoutConstraint(item: deleteVC.view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.window!.contentView!, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0)
        let widthC = NSLayoutConstraint(item: deleteVC.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 303)
        let heightC = NSLayoutConstraint(item: deleteVC.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 165)

        self.window?.contentView?.addSubview(deleteVC.view)
        self.window?.contentView?.addConstraints([heightC, widthC, horC, verC])

    }
    
    @IBAction func newStickyNote(_ sender: Any) {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            let newVC = StickieWindowController()
            delegate.arrayOfStickieWindowControllers.append(newVC)
            newVC.showWindow(nil)
        }
    }
}
