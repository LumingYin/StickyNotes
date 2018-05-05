//
//  StickyWindowController.swift
//  Sticky Notes
//
//  Created by Numeric on 5/4/18.
//  Copyright © 2018 Kenny. All rights reserved.
//

import Cocoa

class StickyWindowController: NSWindowController {
    @IBOutlet weak var plusButton: NSButton!
    @IBOutlet weak var moreButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var contentBox: NSBox!
    @IBOutlet weak var titleBarBox: NSBox!
    @IBOutlet weak var colorSelectorBox: NSBox!
    @IBOutlet weak var dimBox: NSBox!
    @IBOutlet weak var colorBoxTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorButtonsStackView: NSStackView!
    @IBOutlet weak var deleteViewContainer: NSView!
    @IBOutlet var contentTextView: NSTextView!
    @IBOutlet weak var yellowChangeButton: FlatButton!
    @IBOutlet weak var greenChangeButton: FlatButton!
    
    var currentColorTag = 0
    var deleteVC: DeleteNoteViewController?
    var sticky: Sticky?
    var tick_black = NSImage(named: NSImage.Name(rawValue: "tick_black"))
    
    convenience init() {
        self.init(windowNibName: NSNib.Name(rawValue: "StickyWindowController"))
    }

    override func windowWillLoad() {
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2
            self.titleBarBox.animator().alphaValue = 1
            self.plusButton.animator().alphaValue = 1
            self.moreButton.animator().alphaValue = 1
            self.deleteButton.animator().alphaValue = 1

        }) {
            self.titleBarBox.alphaValue = 1
            self.plusButton.alphaValue = 1
            self.moreButton.alphaValue = 1
            self.deleteButton.alphaValue = 1

        }
    }

    override func mouseExited(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2
            self.titleBarBox.animator().alphaValue = 0.3
            self.plusButton.animator().alphaValue = 0
            self.moreButton.animator().alphaValue = 0
            self.deleteButton.animator().alphaValue = 0

        }) {
            self.titleBarBox.alphaValue = 0.3
            self.plusButton.alphaValue = 0
            self.moreButton.alphaValue = 0
            self.deleteButton.alphaValue = 0

        }
        
    }

    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.titleBarBox.alphaValue = 0.3
        self.plusButton.alphaValue = 0
        self.moreButton.alphaValue = 0
        self.deleteButton.alphaValue = 0
        let windowTrackingArea = NSTrackingArea.init(rect:self.contentBox.bounds, options: NSTrackingArea.Options(rawValue: NSTrackingArea.Options.RawValue(UInt8(NSTrackingArea.Options.mouseEnteredAndExited.rawValue) | UInt8(NSTrackingArea.Options.activeAlways.rawValue))), owner: self, userInfo: nil)
        self.contentBox.addTrackingArea(windowTrackingArea)

        self.window?.isMovableByWindowBackground = true
        self.window?.standardWindowButton(.closeButton)?.isHidden = true
        self.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true
        self.contentTextView.font = NSFont.systemFont(ofSize: 20, weight: .light)

        if let stk = sticky {
            if let content = stk.noteContent {
                self.contentTextView.textStorage?.setAttributedString(content)
                self.updateColorAccordingToTag(tag: Int(stk.colorTag))
                let mainScreenFrame = (NSScreen.main?.frame)!
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 0.5
                NSAnimationContext.current.completionHandler = {
                }
                self.window?.animator().setFrame(CGRect(x: CGFloat(mainScreenFrame.size.width * CGFloat(stk.screenPositionX)), y: CGFloat(mainScreenFrame.size.height * CGFloat(stk.screenPositionY)), width: CGFloat(stk.width), height: CGFloat(stk.height)), display: true)
                NSAnimationContext.endGrouping()
            }
        }
        self.window?.makeFirstResponder(self.contentTextView)
    }
    
    
    @IBAction func colorChanged(_ sender: NSButton) {
//        print(sender)
//        sender.image = NSImage(named: NSImage.Name(rawValue: "tick_black"))
//        sender.setNeedsDisplay()
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
        currentColorTag = tag
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
        if colorName == "yellow" || colorName == "gray" {
            plusButton.image = NSImage(named: NSImage.Name(rawValue: "add"))
            deleteButton.image = NSImage(named: NSImage.Name(rawValue: "delete"))
            moreButton.image = NSImage(named: NSImage.Name(rawValue: "more"))
        } else {
            plusButton.image = NSImage(named: NSImage.Name(rawValue: "add_white"))
            deleteButton.image = NSImage(named: NSImage.Name(rawValue: "delete_white"))
            moreButton.image = NSImage(named: NSImage.Name(rawValue: "more_white"))
        }
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
        let skipPrompt = UserDefaults.standard.bool(forKey: "ShouldDeleteWithoutPrompting")
        if skipPrompt {
            deleteAssociatedNote()
            return
        }
        if (deleteVC == nil) {
            deleteVC = DeleteNoteViewController(deleteCompletion: {
                self.deleteAssociatedNote()
            }, cancelCompletion: {
                self.plusButton.isEnabled = true
                self.moreButton.isEnabled = true
                self.deleteButton.isEnabled = true
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 0.2
                NSAnimationContext.current.completionHandler = {
                    self.dimBox.isHidden = true
                }
                self.dimBox.animator().isHidden = true
                NSAnimationContext.endGrouping()
                self.contentTextView.isEditable = true
            })
            deleteViewContainer.addSubview((deleteVC?.view)!)
        }
        self.window?.makeFirstResponder(deleteVC?.keepButton)
        
        self.plusButton.isEnabled = false
        self.moreButton.isEnabled = false
        self.deleteButton.isEnabled = false
        self.contentTextView.isEditable = false
        
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.2
        NSAnimationContext.current.completionHandler = {
            self.dimBox.isHidden = false
        }
        dimBox.animator().isHidden = false
        NSAnimationContext.endGrouping()


    }
    
    func deleteAssociatedNote() {
        self.window?.close()
        if let delegate = NSApplication.shared.delegate as? AppDelegate,
            let index = delegate.arrayOfStickyWindowControllers.index(of: self) {
            if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext, let stk = self.sticky {
                context.delete(stk)
                
            }
            delegate.arrayOfStickyWindowControllers.remove(at: index)
        }
    }
    
    @IBAction func newStickyNote(_ sender: Any) {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.makeNewStickyClicked(self)
        }
    }
}
