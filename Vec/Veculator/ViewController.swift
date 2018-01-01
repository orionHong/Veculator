//
//  ViewController.swift
//  Veculator
//
//  Created by 向宏儒 on 2017-02-04.
//  Copyright © 2017 向宏儒. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //private var isAnswerAVector = false
    //private var inputType = 0
    /* inputType Definition Dictionary:
     0: user is not in the middle of typing
     1: user is typing scalar
     2: user is not in the middle of typing, but the display has a scalar value
     3: user is typing a vector (direction)
     4: user is not in the middle of typing, but the display has a vector value
     */
    private var userIsInTheMiddleOfTyping = false
    private var isDisplayingAVector = false
    private var hasPressedDot = false
    let numberFormatter = NumberFormatter()
    //private var pastFigures = ""
    private var isLastPressedButtonAOperation = false
    
    @IBOutlet private weak var currentDisplay: UILabel!
    @IBOutlet private weak var previousDisplay: UILabel!
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        /*
         switch inputType {
         case 0,2,4:// User has not entered anything
         currentDisplay.text = sender.currentTitle!
         inputType = 1
         case 1: // User has entered a digit
         currentDisplay.text! += sender.currentTitle!
         case 3: // User is entering the direction of the vector
         currentDisplay.text!.insert(Character(sender.currentTitle!), at: currentDisplay.text!.index(before: currentDisplay.text!.endIndex))
         default:
         inputType = 0
         }
         */
        let digit = sender.currentTitle!
        isLastPressedButtonAOperation = false
        //pastFigures += digit
        /*    if digit == "." {
         if !hasPressedDot {
         if userIsInTheMiddleOfTyping{
         currentDisplay.text! += "."
         hasPressedDot = true
         }
         else {
         currentDisplay.text! = "0."
         userIsInTheMiddleOfTyping = true
         isDisplayingAVector = false
         }
         }
         }
         else { */
        switch digit {
        case ".":
            if hasPressedDot { return }
            hasPressedDot = true
        case "[d]":
            if isDisplayingAVector { return }
            else {
                isDisplayingAVector = true // User will be entering direction, and this value will be reset if user is not in the middle of the typing (Line 84)
                currentDisplay.text! += "[]"
                //pastFigures += "["
                hasPressedDot = false
                return
            }
        default: break
        }
        if userIsInTheMiddleOfTyping {
            if isDisplayingAVector {
                currentDisplay.text!.insert(Character(sender.currentTitle!), at: currentDisplay.text!.index(before: currentDisplay.text!.endIndex))
            }
            else {
                currentDisplay.text! += sender.currentTitle!
            }
        }
        else {
            currentDisplay.text = digit
            userIsInTheMiddleOfTyping = true
            isDisplayingAVector = false
            //To prevent user from typing when a result is showing
        }
    }
    
    /*
     @IBAction func directionSign(_ sender: UIButton) {
     if !isDisplayingAVector {
     isDisplayingAVector = true // User will be entering direction, and this value will be reset in touchDigit()
     currentDisplay.text! += "[]"
     //pastFigures += "["
     hasPressedDot = false
     }
     }
     
     @IBAction func dotPressing(_ sender: UIButton) {
     if !hasPressedDot {
     if userIsInTheMiddleOfTyping{
     currentDisplay.text! += "."
     hasPressedDot = true
     }
     else {
     currentDisplay.text! = "0."
     userIsInTheMiddleOfTyping = true
     isDisplayingAVector = false
     }
     }
     }
     */
    private var vectorDisplay: (Double, Double) {
        set {
            numberFormatter.numberStyle = NumberFormatter.Style.scientific
            numberFormatter.positiveFormat = "0.###E+0"
            numberFormatter.exponentSymbol = "e"
            //let maginitude = newValue.0 > 10_000_000 ? newValue.0.scientificStyle : (newValue.1.isInteger ? String(Int(newValue.0)) : String(newValue.0))
            var magnitude = String(newValue.0)
            if newValue.0.isInteger {
                magnitude = String(Int(newValue.0))
            }
            if newValue.0 > 10_000_000 {
                magnitude = newValue.0.scientificStyle
            }
            let direction = newValue.1.isInteger ? String(Int(newValue.1)) : String(newValue.1)
            if isDisplayingAVector{
                currentDisplay.text! = magnitude + "[" + direction + "]"
            }
            else {
                currentDisplay.text! = magnitude
            }
            
        }
        get {
            /*
             switch inputType {
             case 0, 1, 2:
             return (Double(currentDisplay.text!)!, 0.0)
             case 3, 4:
             let displayContent = currentDisplay.text!
             let ind = displayContent.characters.index(of: "[")!
             let value1 = Double(displayContent.substring(to: ind))!
             let value2 = Double(displayContent.substring(with: displayContent.index(after: ind) ..< displayContent.index(before: displayContent.endIndex)))!
             return (value1, value2)
             default: return (0.0, 0.0)
             }
             */
            let displayContent = currentDisplay.text!
            if isDisplayingAVector {
                let ind = displayContent.characters.index(of: "[")!
                let value1 = Double(displayContent.substring(to: ind))!
                if let value2 = Double(displayContent.substring(with: displayContent.index(after: ind) ..< displayContent.index(before: displayContent.endIndex))) {
                    return (value1, value2)
                }
                return (value1, 0.0) // (magnitude, direction)
            }
            return (Double(displayContent)!, 0.0)
        }
    }
    
    private var brain = VeculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        /*if let buttonName = sender.currentTitle {
            if lastPressedButtonName == buttonName { return }
            else { lastPressedButtonName = buttonName }
        }
 */
        brain.setOperand(value: vectorDisplay)
        //brain.setInputType(type: isDisplayingAVector)
        userIsInTheMiddleOfTyping = false
        hasPressedDot = false
        print("\(isLastPressedButtonAOperation)")
        if let mathsSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathsSymbol, isLastPressedAnOperation: isLastPressedButtonAOperation)
            //isAnswerAVector = brain.answerState
            isDisplayingAVector = brain.answerState
            vectorDisplay = brain.result
            //pastFigures += "] \(mathsSymbol)"
            //previousDisplay.text = pastFiguresss
            previousDisplay.text! = brain.previouslyEntered
            //previousDisplay.font.withSize(CGFloat(brain.previousDisplayFontSize))
            //currentDisplay.font.withSize(CGFloat(brain.currentDisplayFontSize))
        }
        isLastPressedButtonAOperation = true
    }
}
