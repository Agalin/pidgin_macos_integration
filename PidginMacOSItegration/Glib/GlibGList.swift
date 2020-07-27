//
//  GlibGList.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation

func forEachInList(_ list: UnsafeMutablePointer<GList>?, function: (UnsafeMutablePointer<GList>) -> ()) {
    var element = list
    while(element != nil) {
        function(element!)
        element = element!.pointee.next
    }
}
