//
//  AppDelegate.swift
//  Sticky Notes
//
//  Created by Numeric on 5/4/18.
//  Copyright © 2018 Kenny. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var arrayOfStickyWindowControllers: [StickyWindowController] = []
    
    @IBAction func closeWindowClicked(_ sender: Any) {
        if let stickyWindowController = NSApplication.shared.keyWindow?.windowController as? StickyWindowController {
            stickyWindowController.deleteStickyNote(self)
        }
    }
    
    @IBAction func makeNewStickyClicked(_ sender: Any) {
        let newSticky = Sticky(context: persistentContainer.viewContext)
        newSticky.noteContent = ""
        newSticky.colorTag = Int16(arc4random_uniform(6))
        makeNewSticky(newSticky)
    }
    
    func makeNewSticky() {
        let newSticky = Sticky(context: persistentContainer.viewContext)
        newSticky.noteContent = ""
        newSticky.colorTag = 0
        makeNewSticky(newSticky)
    }
    
    func makeNewSticky(_ sticky: Sticky) {
        let newVC = StickyWindowController()
        newVC.sticky = sticky
        self.arrayOfStickyWindowControllers.append(newVC)
        newVC.showWindow(nil)
        newVC.window?.orderFront(nil)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var hasExistingDataFetched: Bool = false
        do {
            let fetchRequest: NSFetchRequest<Sticky> = Sticky.fetchRequest()
            let Stickys = try self.persistentContainer.viewContext.fetch(fetchRequest)
            for sticky in Stickys {
                makeNewSticky(sticky)
                hasExistingDataFetched = true
            }
        } catch {}

        if !hasExistingDataFetched {
            makeNewSticky()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Sticky_Notes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let mainScreenFrame = NSScreen.main?.frame
        for noteWindowController in arrayOfStickyWindowControllers {
            if noteWindowController.contentTextView.string.count > 0 {
                let sticky = noteWindowController.sticky
                let window = noteWindowController.window!
                sticky?.noteContent = noteWindowController.contentTextView.string
                sticky?.colorTag = Int16(noteWindowController.currentColorTag)
                sticky?.width = Float(window.frame.size.width)
                sticky?.height = Float(window.frame.size.height)
                sticky?.screenPositionX = Float(window.frame.origin.x / (mainScreenFrame?.size.width)!)
                sticky?.screenPositionY = Float(window.frame.origin.y / (mainScreenFrame?.size.height)!)
//                print("screenPos\(sticky?.screenPositionX), y\(sticky?.screenPositionY)")

            }
        }
        
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

