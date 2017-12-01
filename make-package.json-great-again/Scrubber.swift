//
//  Scrubber.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 01/12/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Foundation
import Cocoa


// MARK: - Scrubber DataSource & Delegate

@available(OSX 10.12.1, *)
extension ViewController: NSScrubberDataSource, NSScrubberDelegate {
    
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        if pjo.isSelectedPackage(){
            return (pjo.getSelectedPackage()!.packageScripts.count)
        }
        else{
            return pjo.getPackageJsonList().count
        }
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let itemView = scrubber.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RatingScrubberItemIdentifier"), owner: nil) as! NSScrubberTextItemView
        if pjo.getSelectedPackage() != nil{ // there IS a selected package.json- so show scripts
            itemView.textField.stringValue =  (pjo.getSelectedPackage()?.makePackageScriptList()[index].scriptName)!
        }
        else { // there ISN'T a selected package.json- so show package list
            itemView.textField.stringValue = pjo.getPackageJsonList()[index].packageName
        }
        return itemView
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt index: Int) {
        self.touchBar = nil
        if pjo.isSelectedPackage(){
            print((pjo.getSelectedPackage()!.makePackageScriptList()[index].scriptCommand))
            shell("ls")
            shell("xcodebuild", "-workspace", "make-package.json-great-again.xcworkspace")
            
        }
        else{
            pjo.setSelectedPackage(packageJson: pjo.getPackageJsonList()[index])
        }
        willChangeValue(forKey: "rating")
        rating = index
        didChangeValue(forKey: "rating")
    }
}
