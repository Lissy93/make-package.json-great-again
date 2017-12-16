//
//  ShellTaskRunner.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 28/11/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Foundation
import Cocoa


class TasksViewController: NSViewController {
    
    //Controller Outlets
    @IBOutlet var outputText:NSTextView!
    @IBOutlet var spinner:NSProgressIndicator!
    @IBOutlet var projectPath:NSPathControl!
    @IBOutlet var repoPath:NSPathControl!
    @IBOutlet var buildButton:NSButton!
    @IBOutlet var targetName:NSTextField!
    
    
    @objc dynamic var isRunning = false
    var outputPipe:Pipe!
    var buildTask:Process!
    
    
    @IBAction func startTask(_ sender:AnyObject) {
        
        //1.
        outputText.string = ""
        
        if let projectURL = projectPath.url, let repositoryURL = repoPath.url {
            
            //2.
            let projectLocation = projectURL.path
            let finalLocation = repositoryURL.path
            
            //3.
            let projectName = projectURL.lastPathComponent
            let xcodeProjectFile = projectLocation + "/\(projectName).xcodeproj"
            
            //4.
            let buildLocation = projectLocation + "/build"
            
            //5.
            var arguments:[String] = []
            arguments.append(xcodeProjectFile)
            arguments.append(targetName.stringValue)
            arguments.append(buildLocation)
            arguments.append(projectName)
            arguments.append(finalLocation)
            
            //6.
            buildButton.isEnabled = false
            spinner.startAnimation(self)
            
            runScript(arguments)
            
        }
        
    }
    
    @IBAction func stopTask(_ sender:AnyObject) {
        
        if isRunning {
            buildTask.terminate()
        }
        
    }
    
    func runScript(_ arguments:[String]) {
        
        //1.
        isRunning = true
        
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        //2.
        taskQueue.async {
            
            //1.
            guard let path = Bundle.main.path(forResource: "BuildScript",ofType:"command") else {
                print("Unable to locate BuildScript.command")
                return
            }
            
            //2.
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            
            //3.
            self.buildTask.terminationHandler = {
                
                task in
                DispatchQueue.main.async(execute: {
                    self.buildButton.isEnabled = true
                    self.spinner.stopAnimation(self)
                    self.isRunning = false
                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            
            //4.
            self.buildTask.launch()
            
            //5.
            self.buildTask.waitUntilExit()
            
        }
        
    }
    
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        
        //1.
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        //2.
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //3.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            //4.
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            //5.
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string ?? ""
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                
                let range = NSRange(location:nextOutput.characters.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                
            })
            
            //6.
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            
            
        }
        
    }
    
    
}
