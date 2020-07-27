//
//  PidginConversation.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation

extension PidginConversation {
    var latestImagePath : String? {
        debug("Latest image path.")
        var result : String?
        if let entry = self.entry {
            result = entry.withMemoryRebound(to: GtkIMHtml.self, capacity: 1) {
                (html : UnsafeMutablePointer<GtkIMHtml>) -> String? in
                if let images = html.pointee.im_images {
                    let imageStruct = images.pointee.data.assumingMemoryBound(to: im_image_data.self)
                    let image = html.pointee.funcs.pointee.image_get(imageStruct.pointee.id)
                    if let imagePath = html.pointee.funcs.pointee.image_get_filename(image) {
                        return String(cString: imagePath)
                    }
                }
                return nil
            }
        }
        debug("Latest image path: \(String(describing: result))")
        log_all("macos", "Latest image path: \(String(describing: result))\n")
        return result
    }
}
