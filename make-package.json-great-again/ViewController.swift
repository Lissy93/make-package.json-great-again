//  ViewController.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 17/10/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var packageJsonLocations = [URL]() // Stores list of package.json projects
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar))) // unbind first
        self.view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findPackageJsonInDir(dirPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    }
    

    
    
    /**
     * Function to recursivley search for valid package.json files
     * within a given directory (but ignoring node_modules !)
     */
    func findPackageJsonInDir(dirPath: URL){

        do {
            // Get URL of directory (from dirPath param)
            let directoryContents =
                try FileManager.default.contentsOfDirectory(at: dirPath as! URL, includingPropertiesForKeys: nil, options: [])
            
            // For every file/ directory in current directory
            for dir in directoryContents{
                let fileManager = FileManager.default
                var isDir : ObjCBool = false
                if fileManager.fileExists(atPath: dir.path, isDirectory:&isDir) {
                    if isDir.boolValue {
                        if dir.absoluteString.range(of: "node_modules") == nil {
                            // If this is also a directory, recursivley search it too
                            findPackageJsonInDir(dirPath: dir)
                        }
                    } else {
                        // If it's a file, check if it is the target package.json
                        if dir.absoluteString.hasSuffix("package.json") {
                            self.packageJsonLocations.append(dir)
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.infoLabelItem:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            customViewItem.view = NSTextField(labelWithString: " Hello World  \u{1F30E}")
            return customViewItem
        default:
            return nil
        }
    }

}


@available(OSX 10.12.1, *)
extension ViewController: NSTouchBarDelegate {
    
    override func makeTouchBar() -> NSTouchBar? {

        // 1
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        // 2
        touchBar.customizationIdentifier = .travelBar
        // 3
        touchBar.defaultItemIdentifiers = [.infoLabelItem]
        // 4
        touchBar.customizationAllowedItemIdentifiers = [.infoLabelItem]
        
        return touchBar
    }
}






