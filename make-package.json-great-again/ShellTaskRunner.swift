//
//  ShellTaskRunner.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 28/11/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Foundation

import Foundation

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}
