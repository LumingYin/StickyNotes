//
//  DeleteNoteViewController.swift
//  Sticky Notes
//
//  Created by Numeric on 5/4/18.
//  Copyright © 2018 Kenny. All rights reserved.
//

import Cocoa

class DeleteNoteViewController: NSViewController {

    var deleteCompletion: (() -> ())?
    var cancelCompletion: (() -> ())?
    
    convenience init(deleteCompletion: (() -> ())?, cancelCompletion: (() -> ())?) {
        self.init()
        self.deleteCompletion = deleteCompletion
        self.cancelCompletion = cancelCompletion
    }
    
    @IBAction func toggleDeletionPrompt(_ sender: NSButton) {
        UserDefaults.standard.set(true, forKey: "ShouldDeleteWithoutPrompting")
        UserDefaults.standard.synchronize()
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.askBeforeDeletionMenuItem.state = .on
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        deleteCompletion?()
    }
    
    @IBAction func keepButtonClicked(_ sender: Any) {
        cancelCompletion?()
    }
}
