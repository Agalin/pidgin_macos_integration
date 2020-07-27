//
//  GlibEnum.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation

enum GTypes : UInt {
    case G_TYPE_INVALID = 0b0 // 0 << 2
    case G_TYPE_NONE = 0b100 // 1 << 2
    case G_TYPE_INTERFACE = 0b1000 // 2 << 2
    case G_TYPE_CHAR = 0b1100 // 3 << 2
    case G_TYPE_UCHAR = 0b10000 // 4 << 2
    case G_TYPE_BOOLEAN = 0b10100 // 5 << 2
    case G_TYPE_INT = 0b11000 // 6 << 2
    case G_TYPE_UINT = 0b11100 // 7 << 2
    case G_TYPE_LONG = 0b100000 // 8 << 2
    case G_TYPE_ULONG = 0b100100 // 9 << 2
    case G_TYPE_INT64 = 0b101000 // 10 << 2
    case G_TYPE_UINT64 = 0b101100 // 11 << 2
    case G_TYPE_ENUM = 0b110000 // 12 << 2
    case G_TYPE_FLAGS = 0b110100 // 13 << 2
    case G_TYPE_FLOAT = 0b111000 // 14 << 2
    case G_TYPE_DOUBLE = 0b111100 // 15 << 2
    case G_TYPE_STRING = 0b1000000 // 16 << 2
    case G_TYPE_POINTER = 0b1000100 // 17 << 2
    case G_TYPE_BOXED = 0b1001000 // 18 << 2
    case G_TYPE_PARAM = 0b1001100 // 19 << 2
    case G_TYPE_OBJECT = 0b1010000 // 20 << 2
    case G_TYPE_VARIANT = 0b1010100 // 21 << 2
}
