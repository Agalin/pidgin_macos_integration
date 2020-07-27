//
//  Log.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation

func debug(_ message: String) {
    #if DEBUG
    fputs(message, __stderrp)
    if(message.last != "\n")
    {
        fputs("\n", __stderrp)
    }
    log_all("macos", message)
    #endif
}
