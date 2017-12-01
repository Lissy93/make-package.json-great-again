//
//  PackageJsonOperations.swift
//  make-package.json-great-again
//
//  Created by Sykes, Alicia on 01/12/2017.
//  Copyright © 2017 AS93. All rights reserved.
//

import Foundation

class PackageJsonOperations{
    
    static var packageJsonLocations = [URL]() // Stores list of package.json projects
    
    static var packageJsonList: [PackageJson] = []
    
    static var selectedPackage: PackageJson? = nil
    
    init(){}
    
    func getPackageJsonLocations() -> [URL]{
        return PackageJsonOperations.packageJsonLocations
    }
    func getPackageJsonList() -> [PackageJson]{
        return PackageJsonOperations.packageJsonList
    }
    func getSelectedPackage() -> PackageJson?{
        return PackageJsonOperations.selectedPackage
    }
    func setSelectedPackage( packageJson: PackageJson? ){
        PackageJsonOperations.selectedPackage = packageJson
    }
    
    /**
     * Determines if we are in start view, or package view
     */
    func isSelectedPackage() -> Bool {
        return (PackageJsonOperations.selectedPackage != nil) ? true : false
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
                            PackageJsonOperations.packageJsonLocations.append(dir)
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
                    //updateTouchbar()
                    PackageJsonOperations.packageJsonList.append(PackageJson(packageName: packageName, packageVersion: "12", packageScripts: packageScripts!))
                } else {
                    print("Unable to retrieve package name.")
                }
            } catch let error as NSError {
                print(error) // fucking swift
            }
        }
        task.resume()
    }

}
