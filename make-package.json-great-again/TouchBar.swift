//
//  TouchBar.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 26/11/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Foundation
import Cocoa


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
    
    
    
    @objc func save(_ sender: AnyObject) -> Void {
        print("hello")
    }
    
    @objc func backToHomeView(_ sender: AnyObject) -> Void {
        pjo.setSelectedPackage(packageJson: nil)
        updateTouchbar()
    }
    
    func updateTouchbar(){
        self.touchBar = nil
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
            
            
        case NSTouchBarItem.Identifier.leftSideNav:
            let touchBarAvailiblePackages = NSCustomTouchBarItem(identifier: identifier)
            if pjo.getSelectedPackage() != nil {
                let button = NSButton(title: "🔙", target: self, action: #selector(backToHomeView(_:)))
                button.bezelColor = NSColor(red:0.8, green:0.8, blue:0.8, alpha:1.00)
                touchBarAvailiblePackages.view = button
                return touchBarAvailiblePackages
            }
            return nil
            
            
        case NSTouchBarItem.Identifier.leftSideLabel:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            
            if let selectedPackage = pjo.getSelectedPackage() {
                customViewItem.view = NSTextField(labelWithString: selectedPackage.packageName)
            }
            else{
                customViewItem.view = NSTextField(labelWithString: "🤠 Select a Project: ")
            }
            return customViewItem
            
        case NSTouchBarItem.Identifier.packageList:
            let customActionItem = NSCustomTouchBarItem(identifier: identifier)
            let segmentedControl = NSSegmentedControl(
                labels: pjo.getPackageJsonList().map({ $0.packageName }),
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
