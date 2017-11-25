//
//  PackageJsonStruct.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 15/11/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Foundation

struct PackageJson {
    var packageName: String
    var packageVersion: String
    var packageScripts: [ String: Any ]
    
    func makePackageScriptList() -> [ PacklageScript ]{
        var packageScriptList: [ PacklageScript ] = []
        for (key, value) in self.packageScripts {
            let anotherScript = PacklageScript( scriptName: key, scriptCommand: value as! String)
            packageScriptList.append(anotherScript)
        }
        return packageScriptList
    }


}

struct PacklageScript {
    var scriptName: String
    var scriptCommand: String
}
