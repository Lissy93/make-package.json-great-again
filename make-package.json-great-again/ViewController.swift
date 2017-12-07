//  ViewController.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 17/10/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
        
    let pjo: PackageJsonOperations = PackageJsonOperations()
    
    @objc var rating = 0
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar))) // unbind first
        self.view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pjo.findPackageJsonInDir(dirPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    }
   

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}









