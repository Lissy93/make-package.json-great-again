//  ViewController.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 17/10/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
        
    var packageJsonLocations = [URL]() // Stores list of package.json projects
    
    var packageJsonList: [PackageJson] = []
    
    var selectedPackage: PackageJson? = nil
    
    @objc var rating = 0
    
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
     * Determines if we are in start view, or package view
     */
    func isSelectedPackage() -> Bool {
        return (self.selectedPackage != nil) ? true : false
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
                let packageScripts = json["scripts"] as? [String: Any]

                if let packageName = packageName {
                    self.touchBar = nil
                    self.packageJsonList.append(PackageJson(packageName: packageName, packageVersion: "12", packageScripts: packageScripts!))
                } else {
                    print("Unable to retrieve package name.")
                }
            } catch let error as NSError {
                print(error) // fucking swift
            }
        }
        task.resume()
    }


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    @objc func save(_ sender: AnyObject) -> Void {
        print("hello")
    }

    @objc func backToHomeView(_ sender: AnyObject) -> Void {
        self.selectedPackage = nil
        self.touchBar = nil
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {

            
        case NSTouchBarItem.Identifier.leftSideNav:
            let touchBarAvailiblePackages = NSCustomTouchBarItem(identifier: identifier)
            if self.selectedPackage != nil {
                let button = NSButton(title: "🔙", target: self, action: #selector(backToHomeView(_:)))
                button.bezelColor = NSColor(red:0.8, green:0.8, blue:0.8, alpha:1.00)
                touchBarAvailiblePackages.view = button
                return touchBarAvailiblePackages
            }
            return nil
            
            
        case NSTouchBarItem.Identifier.leftSideLabel:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            
            if let selectedPackage = self.selectedPackage {
                customViewItem.view = NSTextField(labelWithString: selectedPackage.packageName)
            }
            else{
                customViewItem.view = NSTextField(labelWithString: "🤠 Select a Project: ")
            }
            return customViewItem

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
            
            
        case NSTouchBarItem.Identifier.packageListScrubber:
            let scrubberItem = NSCustomTouchBarItem(identifier: identifier)
//            scrubberItem
            let scrubber = NSScrubber()
            scrubber.scrubberLayout = NSScrubberProportionalLayout()
            scrubber.register(NSScrubberTextItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RatingScrubberItemIdentifier"))
            scrubber.mode = .free
            scrubber.selectionBackgroundStyle = .roundedBackground
            scrubber.backgroundColor = NSColor(red:1, green:0.2, blue:0.5, alpha:1.00)
            scrubber.delegate = self
            scrubber.dataSource = self
            scrubberItem.view = scrubber
            scrubber.bind(NSBindingName(rawValue: "selectedIndex"), to: self, withKeyPath: #keyPath(rating), options: nil)
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
        touchBar.defaultItemIdentifiers = [.leftSideNav, .leftSideLabel, .packageListScrubber]
        touchBar.customizationAllowedItemIdentifiers = [.packageLabelItem]
        return touchBar
    }
}



// MARK: - Scrubber DataSource & Delegate

@available(OSX 10.12.1, *)
extension ViewController: NSScrubberDataSource, NSScrubberDelegate {
    
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        if self.isSelectedPackage(){
            return (self.selectedPackage?.packageScripts.count)!
        }
        else{
            return self.packageJsonList.count
        }
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let itemView = scrubber.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RatingScrubberItemIdentifier"), owner: nil) as! NSScrubberTextItemView
        if self.selectedPackage != nil{ // there IS a selected package.json- so show scripts
            itemView.textField.stringValue =  (self.selectedPackage?.makePackageScriptList()[index].scriptName)!
        }
        else { // there ISN'T a selected package.json- so show package list
            itemView.textField.stringValue = packageJsonList[index].packageName
        }
        return itemView
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt index: Int) {
        self.touchBar = nil
        if self.isSelectedPackage(){
            print((self.selectedPackage?.makePackageScriptList()[index].scriptCommand)!)
        }
        else{
            self.selectedPackage = self.packageJsonList[index]
        }
        willChangeValue(forKey: "rating")
        rating = index
        didChangeValue(forKey: "rating")
    }
    
    
    
    
}







