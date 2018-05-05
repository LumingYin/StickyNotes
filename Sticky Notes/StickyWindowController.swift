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
    var currentColorTag = 0
    var deleteVC: DeleteNoteViewController?
    var sticky: Sticky?
    
    convenience init() {
        self.init(windowNibName: NSNib.Name(rawValue: "StickyWindowController"))
    }

    override func windowWillLoad() {
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.isMovableByWindowBackground = true
        self.window?.standardWindowButton(.closeButton)?.isHidden = true
        self.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true
//        let plusTrackingArea = NSTrackingArea.init(rect: plusButton.bounds, options: NSTrackingArea.Options(rawValue: NSTrackingArea.Options.RawValue(UInt8(NSTrackingArea.Options.mouseEnteredAndExited.rawValue) | UInt8(NSTrackingArea.Options.activeAlways.rawValue))), owner: self, userInfo: nil)
//        plusButton.addTrackingArea(plusTrackingArea)
        
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
        self.contentTextView.font = NSFont.systemFont(ofSize: 20, weight: .light)
        self.window?.makeFirstResponder(self.contentTextView)
    }
    
    
//    override func mouseEntered(with event: NSEvent) {
//        print("mouse entered \(event)")
//        if let cell = plusButton.cell as? NSButtonCell {
//            cell.backgroundColor = NSColor.black.withAlphaComponent(0.5)
//
//        }
//
//    }
//
//    override func mouseExited(with event: NSEvent) {
//        print("mouse exited \(event)")
//        if let cell = plusButton.cell as? NSButtonCell {
//            cell.backgroundColor = NSColor.black.withAlphaComponent(0)
//        }
//
//    }
    
    @IBAction func colorChanged(_ sender: FlatButton) {
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
            print(plusButton)
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
                self.dimBox.isHidden = true
                self.contentTextView.isEditable = true
            })
            deleteViewContainer.addSubview((deleteVC?.view)!)
        }
        
        self.plusButton.isEnabled = false
        self.moreButton.isEnabled = false
        self.deleteButton.isEnabled = false
        self.contentTextView.isEditable = false
        dimBox.isHidden = false
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
            let newSticky = Sticky(context: delegate.persistentContainer.viewContext)
            newSticky.noteContent = NSAttributedString(string: "")
            newSticky.colorTag = Int16(arc4random_uniform(6))
            delegate.makeNewSticky(newSticky)
        }
    }
}
