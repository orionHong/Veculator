//
//  VeculatorBrain.swift
//  Veculator
//
//  Created by 向宏儒 on 2017-02-05.
//  Copyright © 2017 向宏儒. All rights reserved.
//

import Foundation

func coordinatesToValue(_ coordinate: (Double, Double)) -> (Double, Double) {
    var referenceAngle = atan(tangentValue: abs(coordinate.1 / coordinate.0))
    if referenceAngle.isNaN { referenceAngle = 0 } //If x value is zero, and the referenceAngle gets NaH value, it will reset it as 0 degree.
    //print("referenceAngle is \(referenceAngle)")
    //print("coordinate is \(coordinate)")
    switch coordinate {
    case let (x, y) where x >= 0 && y >= 0: break //Quadrant 1
    case let (x, y) where x < 0 && y >= 0:
        referenceAngle = 180 - referenceAngle // Quadrant 2
    case let (x, y) where x <= 0 && y < 0:
        referenceAngle += 180 //Quadrant 3
    case let (x, y) where x > 0 && y < 0:
        referenceAngle = 360 - referenceAngle //Quadrant 4
    default: break
    }
    return (sqrt(coordinate.0 * coordinate.0 + coordinate.1 * coordinate.1), referenceAngle)
}

extension Double {
    struct Number {
        static var formatter = NumberFormatter()
    }
    var scientificStyle: String {
        Number.formatter.numberStyle = NumberFormatter.Style.scientific
        Number.formatter.positiveFormat = "0.###E0"
        Number.formatter.exponentSymbol = "e"
        return Number.formatter.string(from: NSNumber(value: self))!
        //Number.formatter.stringFromNumber(NSNumber(value: self) ?? description
    }
    var isInteger: Bool {
        if self == floor(self) {
            return true
        }
        return false
    }
}

/** Turn display value into coordinates **/
func valueToCoordinate(givenValue: (Double, Double)) -> (Double, Double) {
    return (givenValue.0 * cos(degrees: givenValue.1), givenValue.0 * sin(degrees: givenValue.1))
}

class VeculatorBrain {
    private var accumulator = (0.0, 0.0)
    private var isOutputAVector = true
    private var description = " " //store the string for previousDisplay in the controller
    //private var isPartialResult = false //if there is a binary calculation pending, the value is true. If not, the value is false
    //private var lastPressedButtonName = ""
    
    
    func setOperand(value: (Double, Double)) {
        //if isOutputAVector
        //isPartialResult = false //initially set as false
        /*
         if isPartialResult == true {
         description += " \(value.0)[\(value.1)]"
         }
         else { //When isPartialResult is nil or false
         description = "\(value.0)[\(value.1)]"
         }
         */
        //let maginitude = value.0 > 10_000_000 ? value.0.scientificStyle : String(value.0)
        //if let tempPending = pending {
        //    let newValue = valueToCoordinate(givenValue: tempPending.firstOperand)
        //description = "\(newValue.0)[\(newValue.1)]"
        // }
        // else {
        description = "\(value.0)[\(value.1)]"
        // }
        accumulator = valueToCoordinate(givenValue: (value.0, value.1))
        print(accumulator)
        /*}
         else {
         accumulator = value
         }
         */
    }
    /*
     func setInputType(type: Bool) {
     isOutputAVector = type
     //If input is a vector, the current output will also be considered as vector, and vice versa. This value will be changed in executingPending()
     }
     */
    
    func performOperation(symbol: String, isLastPressedAnOperation: Bool) {
        if let perform = operations[symbol] {
            switch perform {
            case .Constant(let value):
                accumulator = value
                isOutputAVector = false
                description = symbol
                //isPartialResult = false
                pending = nil
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
                //description = "\(symbol)(\(description))"
                description = " "
                //isPartialResult = false
                pending = nil
            //print(accumulator)
            case .BinaryOperation(let function):
                //if lastPressedButtonName == symbol { return }
                if !isLastPressedAnOperation{
                    executingPending()
                    let newValue = coordinatesToValue(accumulator)
                    print(newValue)
                    description = "\(newValue.0)[\(newValue.1)]"
                }
                pending = pendingBinaryInfo(BinaryFunction: function, firstOperand: accumulator, isSet: true, answerType: answerStateType[symbol]!)
                description += " \(symbol)"
                //print("symbol is \(symbol)")
            //print("description is \(description)")
            case .Equals:
                executingPending()
                description = " "
            case .Reset:
                accumulator = (0.0, 0.0)
                isOutputAVector = true // Set this as false, there won't be [nan]
                pending = nil
                description = " "
                //isPartialResult = false
            }
            //lastPressedButtonName = symbol
        }
    }
    
    private func executingPending() {
        if let tempPending = pending {
            accumulator =  tempPending.BinaryFunction(tempPending.firstOperand, accumulator)
            isOutputAVector = tempPending.answerType
            pending = nil
            //description = " "
            //isPartialResult = false
        }
    }
    
    private var pending: pendingBinaryInfo?
    
    private struct pendingBinaryInfo {
        var BinaryFunction: ((Double, Double), (Double, Double)) -> (Double, Double)
        var firstOperand: (Double, Double)
        var isSet: Bool
        var answerType: Bool
    }
    
    private let operations: Dictionary<String, Operation> = [
        "gcd" : Operation.BinaryOperation({
            var a = (Int)($0.0)
            var b = (Int)($1.0)
            var remainder = a % b
            while (remainder != 0) {
                a = b
                b = remainder
                remainder = a % b
            }
            return ((Double)(b),0.0)
            }),
        "π": Operation.Constant((Double.pi, 0.0)),
        "√": Operation.UnaryOperation({
            var ratio = 1.0 / sqrt(sqrt($0.0 * $0.0 + $0.1 * $0.1))
            if ratio.isInfinite { ratio = 0 }
            return ($0.0 * ratio, $0.1 * ratio)
        }), 
        "±": Operation.UnaryOperation {(-$0.0, -$0.1)},
        "+": Operation.BinaryOperation({
            ($0.0 + $1.0, $0.1 + $1.1)
        }),
        "−": Operation.BinaryOperation({
            ($0.0 - $1.0, $0.1 - $1.1)
        }),
        "×": Operation.BinaryOperation({
            ($0.0 * $1.0, $0.1 * $1.1)
        }),
        "·": Operation.BinaryOperation({
            ($0.0 * $1.0 + $0.1 * $1.1, 0.0)
        }),
        "=": Operation.Equals,
        "AC": Operation.Reset
    ]
    
    private let answerStateType: Dictionary<String, Bool> = [
        // true for ANSER IS A VECTOR; false for NOT
        "+": true,
        "−": true,
        "|v|": false,
        "×": true,
        "√": true,
        "·": false,
        "π": false,
        "gcd": false
    ]
    
    private enum Operation {
        case Constant((Double, Double))
        case UnaryOperation(((Double, Double)) -> (Double, Double))
        case BinaryOperation(((Double, Double), (Double, Double)) -> (Double, Double))
        case Equals
        case Reset
    }
    
    var result: (Double, Double) {
        get {
            if isOutputAVector{
                var resultValue = coordinatesToValue(accumulator)
                resultValue.0 = round(resultValue.0 * 100000) / 100000
                resultValue.1 = round(resultValue.1 * 1000) / 1000
                return (resultValue.0, resultValue.1)
            }
            return accumulator
        }
    }
    
    var answerState: Bool {
        get {
            return isOutputAVector
        }
    }
    
    var previouslyEntered: String {
        get {
            //if let booleanState = isPartialResult {
            return description == " " ? " " : description + " ..."
            //}
            //return " "
        }
    }
    /*
     var previousDisplayFontSize: Double {
     get {
     if description == " " {
     return 1
     }
     else {
     return 20
     }
     }
     }
     
     var currentDisplayFontSize: Double {
     get {
     if description == " " {
     return 95
     }
     else {
     return 65
     }
     }
     }
     */
}
