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
}
