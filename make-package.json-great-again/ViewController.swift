//  ViewController.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 17/10/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var packageJsonLocations = [URL]() // Stores list of package.json projects
    
    var name: String = ""
    
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
                try FileManager.default.contentsOfDirectory(at: dirPath , includingPropertiesForKeys: nil, options: [])
            
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
                            readPackageJson(jsonPath: dir)
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /**
    * Reads and parses a package.json at a given path
    * Gets the name and list of build scripts for each
    */
    func readPackageJson(jsonPath: URL){
        let task = URLSession.shared.dataTask(with: jsonPath) {(data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                let packageName = json["name"] as? String
//                let packageScripts = json["scripts"] as? Data
                if let packageName = packageName {
                    print(packageName)
                    self.touchBar = nil
                    self.name = self.name + " - " + packageName
                } else {
                    print("Unable to retrieve package name.")
                }
            } catch let error as NSError {
                print(error)
            }
//            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue) as Any)
        }
        task.resume()
    }
    
    func parsePackageJson(){
        
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
            customViewItem.view = NSButton()
            customViewItem.view = NSTextField(labelWithString: " Hello World  \u{1F30E}"+" Hello "+self.name)
            return customViewItem
        case NSTouchBarItem.Identifier.packageListScrubber:
            // 2
            let scrubberItem = NSCustomTouchBarItem(identifier: identifier)
            let scrubber = NSScrubber()
            scrubber.scrubberLayout = NSScrubberFlowLayout()
            scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier(rawValue: "packageListScrubberItemIdentifier"))
            scrubber.mode = .fixed
            scrubber.selectionBackgroundStyle = .roundedBackground
            scrubber.delegate = self as? NSScrubberDelegate
            scrubber.dataSource = self as? NSScrubberDataSource
            scrubberItem.view = scrubber
//            scrubber.bind(NSBindingName(rawValue: "selectedIndex"), to: self, withKeyPath: , options: nil)
            return scrubberItem

        default:
            return nil
        }
    }

}


@available(OSX 10.12.1, *)
extension ViewController: NSTouchBarDelegate {
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .travelBar
        touchBar.defaultItemIdentifiers = [.infoLabelItem]
        touchBar.customizationAllowedItemIdentifiers = [.infoLabelItem]
        return touchBar
    }
}






