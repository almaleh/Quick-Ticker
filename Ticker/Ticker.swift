//
//  Ticker.swift
//  Ticker
//
//  Created by Besher on 2018-10-16.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import ObjectiveC

// TODO: provide bundle of options in a struct
struct QTickerOptions {
    
}

protocol TextLabel: class {
    var text: String? { get set }
}


fileprivate class QTickerAnimation<T: QTNumericValue> {
    
    let animationStartTime = Date()
    lazy var animationStartValue = getStartingValue(from: animationLabel?.text ?? "")
    var requiredNumberOfDecimals: Int {
        let startValueCount = getDecimalCount(input: animationStartValue)
        let endValueCount = getDecimalCount(input: Double(fromNumeric: animationEndValue))
        return max(startValueCount, endValueCount)
    }
    
    // The following properties are set during initialization
    weak var animationLabel: TextLabel?
    var animationDisplayLink: CADisplayLink? = nil
    let animationEndValue: T
    let animationCurve: QuickTicker.AnimationCurve
    let animationDuration: TimeInterval
    
    init(label: TextLabel, duration: TimeInterval, endValue: T, curve: QuickTicker.AnimationCurve) {
        animationLabel = label
        animationDuration = duration
        animationCurve = curve
        animationEndValue = endValue
        animationDisplayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        animationDisplayLink?.add(to: .main, forMode: RunLoop.Mode.default)
    }
    
    @objc private func handleUpdate() {
        handleUpdateFor(animationLabel, startTime: animationStartTime, animationDuration: animationDuration,
                        startValue: animationStartValue, endValue: animationEndValue, curve: animationCurve,
                        displayLink: animationDisplayLink)
    }
    
    private func handleUpdateFor(_ label: TextLabel?, startTime: Date, animationDuration: TimeInterval,
                                 startValue: Double, endValue: T, curve: QuickTicker.AnimationCurve,
                                 displayLink: CADisplayLink?) {
        
        var animationDisplayLink = displayLink
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        if elapsedTime <= animationDuration {
            let percentage = elapsedTime / animationDuration
            let value = getValueFromPercentage(percentage, startValue: startValue, endValue: endValue, curve: curve)
            print(value)
            if (value != Double(fromNumeric: animationEndValue)) {
                updateLabel(label, withValue: value, numberOfDecimals: requiredNumberOfDecimals)
                print(String(value))
            }
        } else {
            animationDisplayLink?.invalidate()
            animationDisplayLink = nil
            updateLabel(label, withValue: Double(fromNumeric: endValue), numberOfDecimals: requiredNumberOfDecimals)
        }
    }
    
    private func updateLabel(_ label: TextLabel?, withValue value: Double, numberOfDecimals: Int) {
        
        print("Required number is \(requiredNumberOfDecimals)")
        
        let power = pow(10, Double(numberOfDecimals))
        let updatedValue = Double(round(power * value) / power)
        
        if numberOfDecimals == 0 {
            label?.text = String(Int(updatedValue))
        } else {
            label?.text = String(updatedValue)
        }
        
        
        
//        // if no decimals, we return Int value to avoid zeroes
//        if digitIsInt(value) {
//            label?.text = String(Int(value))
//            print("No decimals")
//        }
//
//        // TODO replace with simpler rounding
//
//        print("Yes decimals")
//        // Output with desired decimal count
//        let text = String(value)
//        if let dot = text.index(of: ".") {
//            if let index = text.index(dot, offsetBy: numberOfDecimals,
//                                      limitedBy: text.index(text.endIndex, offsetBy: -1)) {
//                if index == dot {
//                    label?.text = String(Int(value))
//                } else {
//                    let firstPart = text[text.startIndex...index]
//                    label?.text = String(firstPart)
//                }
//            }
//        }
    }
    
    private func getStartingValue(from start: String) -> Double {
        
        if let digit = Double(start) {
            return digit
        }
        
        
        
        let filtered = start.compactMap { Double( String($0)) }
        let joined = filtered.reduce(0) { $0 * 10 + $1 }
        print("Start was \(start) and end was \(joined)")
        return joined
    }
    
    private func digitIsInt(_ digit: Double) -> Bool {
        return Double(Int(digit)) == digit
    }
    
    private func getValueFromPercentage(_ percentage: Double, startValue: Double, endValue: T, curve: QuickTicker.AnimationCurve) -> Double {
        let endDouble = Double(fromNumeric: endValue)
        switch curve {
        case .linear: return startValue + (percentage * (endDouble - startValue))
            
        case .easeOut:
            var curvedPercentage = 1 - percentage
            curvedPercentage = 1 - pow(curvedPercentage, 2.8)
            return startValue + (curvedPercentage * (endDouble - startValue))
            
        case .easeIn:
            let curvedPercentage = pow(percentage, 2.8)
            return startValue + (curvedPercentage * (endDouble - startValue))
        }
    }
    
    private func getDecimalCount(input: Double) -> Int {
        if digitIsInt(input) { return 0 }
        let str = String(input)
        if let dot = str.index(of: ".") {
            let firstPart = str[str.startIndex...dot]
            var decimals = str
            decimals.removeFirst(firstPart.count)
            return decimals.count
        } else { return 0 }
    }
    
    
}

class QuickTicker {
    
    enum AnimationCurve {
        case linear, easeIn, easeOut
    }
    
    //TODO: Convenience initializers
    
    /// Starts a ticker animation on a UILabel or TextField using the provided end value. Optional parameters include duration, curve, and completion handler. 
    class func animate<T: QTNumericValue, L: TextLabel>(label: L, toEndValue endValue: T, duration: TimeInterval = 2, 
                        curve: AnimationCurve = .linear, completion: (() -> Void)? = nil) {
        
        _ = QTickerAnimation(label: label, duration: duration, endValue: endValue, curve: curve)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion?()
        }
    }
    
    // TODO: find number of decimal points
    
    
    
}

// This protocol allows us to cast generic input to other types
protocol QTNumericValue : Comparable {
    init(_ v:Float)
    init(_ v:Double)
    init(_ v:Int)
    init(_ v:UInt)
    init(_ v:Int8)
    init(_ v:UInt8)
    init(_ v:Int16)
    init(_ v:UInt16)
    init(_ v:Int32)
    init(_ v:UInt32)
    init(_ v:Int64)
    init(_ v:UInt64)
    init(_ v:CGFloat)
    
    // 'shadow method' that allows instances of QTickerNumeric
    // to coerce themselves to another QTickerNumeric type
    func _asOther<T:QTNumericValue>() -> T
}

extension QTNumericValue {
    init<T:QTNumericValue>(fromNumeric numeric: T) { self = numeric._asOther() }
}

extension Float   : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension Double  : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension CGFloat : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension Int     : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension Int8    : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension Int16   : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension Int32   : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension Int64   : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension UInt    : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension UInt8   : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension UInt16  : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension UInt32  : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}
extension UInt64  : QTNumericValue {func _asOther<T:QTNumericValue>() -> T { return T(self) }}

extension UILabel : TextLabel { }
extension UITextField: TextLabel { }

