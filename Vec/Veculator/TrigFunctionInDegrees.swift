//
//  TrigFunctionInDegrees.swift
//  Veculator
//
//  Created by 向宏儒 on 2017-02-13.
//  Copyright © 2017 向宏儒. All rights reserved.
//

import Foundation
/* This file overwrites trignometic functions with parameter of degrees 
 */
public func sin(degrees: Double) -> Double {
    return __sinpi(degrees / 180.0)
}

public func cos(degrees: Double) -> Double {
    return __cospi(degrees / 180.0)
}

public func atan(tangentValue: Double) -> Double {
    return atan(tangentValue) / .pi * 180.0
}

