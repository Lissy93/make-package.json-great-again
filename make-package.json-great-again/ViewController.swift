//  ViewController.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 17/10/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var touchGroup: NSTouchBarItem!
    
    var packageJsonLocations = [URL]() // Stores list of package.json projects
    
    var packageJsonList: [PackageJson] = []
    
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
            print(error.localizedDescription) // Hmm, looks like everything gone wrong, already
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
                    self.touchBar = nil
                    self.packageJsonList.append(PackageJson(packageName: packageName, packageVersion: "12", packageScripts: "jk"))
                } else {
                    print("Unable to retrieve package name.")
                }
            } catch let error as NSError {
                print(error) // fucking swift
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

    
    @objc func save(_ sender: AnyObject) -> Void {
        print("hello")
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.packageList:
            let customActionItem = NSCustomTouchBarItem(identifier: identifier)
            let segmentedControl = NSSegmentedControl(
                labels: packageJsonList.map({ $0.packageName }),
                trackingMode: .momentary,
                target: self,
                action: #selector(save(_:))
            )
            customActionItem.view = segmentedControl
            return customActionItem
            
        case NSTouchBarItem.Identifier.scriptList:
            let touchBarAvailiblePackages = NSCustomTouchBarItem(identifier: identifier)
                let button = NSButton(title: "Hello World", target: self, action: #selector(save(_:)))
                button.bezelColor = NSColor(red:0.35, green:0.61, blue:0.35, alpha:1.00)
                touchBarAvailiblePackages.view = button
            return touchBarAvailiblePackages

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
        touchBar.defaultItemIdentifiers = [.scriptList, .packageList]
        touchBar.customizationAllowedItemIdentifiers = [.packageLabelItem]
        return touchBar
    }
}






