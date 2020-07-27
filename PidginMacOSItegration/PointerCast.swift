//
//  PointerCast.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation

func toPtr<T : AnyObject>(_ obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func fromPtr<T : AnyObject>(_ ptr : UnsafeMutableRawPointer) -> T {
    debug("From ptr: \(String.init(describing: ptr))")
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

func tryCast<T : AnyObject>(_ ptr: UnsafeMutableRawPointer?) -> T? {
    if(ptr == nil)
    {
        debug("Received invalid pointer.\n")
        return nil
    }
    return fromPtr(ptr!)
}
