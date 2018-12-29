//
//  QuickTicker.swift
//  QuickTicker
//
//  Created by Besher on 2018-10-16.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import UIKit

 public protocol TextLabel: class {
    var text: String? { get set }
}

typealias QTHandler = (() -> Void)?

// MARK: - Public class

public class QuickTicker {
    
    public enum Options {
        case linear, easeIn, easeOut
        case decimalPoints(_ value: Int)
    }
    
    /// Starts a ticker animation on a UILabel or TextField using the provided end value.
    /// Options include animation curve and decimal points
    public class func animate<T: NumericValue, L: TextLabel>(label: L?, toEndValue endValue: T,
                                                      duration: TimeInterval, options: [Options] = [.linear],
                                                      completion: (() -> Void)? = nil) {
        if let label = label {
            _ = QTObject(label: label, duration: duration, endValue: endValue,
                                 options: options, completion: completion)
        }
    }
    
    /// Starts a ticker animation on a UILabel or TextField using a default 2 second duration and linear curve
    public class func animate<T: NumericValue, L: TextLabel>(label: L?, toEndValue endValue: T, completion: (() -> Void)? = nil) {
        animate(label: label, toEndValue: endValue, duration: 2, options: [.linear], completion: completion)
    }
    
    /// Starts a ticker animation on a UILabel or TextField using a default 2 second duration
    public class func animate<T: NumericValue, L: TextLabel>(label: L?, toEndValue endValue: T,
                                                      options: [Options], completion: (() -> Void)? = nil) {
        animate(label: label, toEndValue: endValue, duration: 2, options: options, completion: completion)
    }
    
}

internal class QTObject<T: NumericValue> {
    
    private let animationStartTime = Date()
    private lazy var animationStartValue = getStartingValue(from: animationLabel)
    private var userRequestedNumberOfDecimals: Int? = nil
    
    private var requiredNumberOfDecimals: Int {
        // if the user requested a specific number we use it, otherwise we infer from end value
        return userRequestedNumberOfDecimals ?? getDecimalCount(input: Double(fromNumeric: animationEndValue))
    }
    
    // The following properties are set during initialization
    private weak var animationLabel: TextLabel?
    private var animationCompletion: QTHandler
    private var animationDisplayLink: CADisplayLink? = nil
    private let animationEndValue: T
    private var animationCurve: QuickTicker.Options = .linear
    private let animationDuration: TimeInterval
    
    /// Do not call this initializer. Use QuickTicker's class function instead.
    /// This QTObject is only meant to be used internally
    required init(label: TextLabel, duration: TimeInterval, endValue: T, options: [QuickTicker.Options],
        completion: QTHandler) {
        animationLabel = label
        animationDuration = duration
        animationEndValue = endValue
        animationCurve = getCurveFrom(options)
        animationCompletion = completion
        animationDisplayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        animationDisplayLink?.add(to: .main, forMode: RunLoop.Mode.common)
        userRequestedNumberOfDecimals = getUserRequestedDecimal(from: options)
    }
    
    @objc private func handleUpdate() {
        handleUpdateFor(animationLabel, startTime: animationStartTime, animationDuration: animationDuration,
                        startValue: animationStartValue, endValue: animationEndValue, curve: animationCurve,
                        displayLink: animationDisplayLink)
    }
    
    fileprivate func handleUpdateFor(_ label: TextLabel?, startTime: Date, animationDuration: TimeInterval,
                                 startValue: Double, endValue: T, curve: QuickTicker.Options,
                                 displayLink: CADisplayLink?) {
        
        var animationDisplayLink = displayLink
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        if elapsedTime <= animationDuration {
            // Animation still in progress
            let percentage = elapsedTime / animationDuration
            let value = getValueFromPercentage(percentage, startValue: startValue, endValue: endValue, curve: curve)
            if (value != Double(fromNumeric: animationEndValue)) {
                updateLabel(label, withValue: value, numberOfDecimals: requiredNumberOfDecimals)
            }
        } else {
            // Animation is over
            animationDisplayLink?.invalidate()
            animationDisplayLink = nil
            updateLabel(label, withValue: Double(fromNumeric: endValue), numberOfDecimals: requiredNumberOfDecimals)
            animationCompletion?()
        }
    }
    
    func updateLabel(_ label: TextLabel?, withValue value: Double, numberOfDecimals: Int) {
        
        // apply requested decimals to result
        let power = pow(10, Double(numberOfDecimals))
        let updatedValue = Double(round(power * value) / power)
        
        if numberOfDecimals == 0 {
            updateDigitsWhileKeepingText(for: label, value: String(Int(updatedValue)))
        } else {
            // padding is needed in case result has zeros after decimal
            let padded = padValueWithDecimalsIfNeeded(value: updatedValue, requiredDecimals: numberOfDecimals)
            updateDigitsWhileKeepingText(for: label, value: padded)
        }
    }
}
    
    
    
// MARK: - Helper methods

extension QTObject {
    
    func getStartingValue(from label: TextLabel?) -> Double {
        let startText = label?.text ?? ""
        
        // first try to typecast
        if let digit = Double(startText) {
            return digit
        }
        
        let (startIndex, endIndex) = getFirstAndLastDigitIndexes(for: animationLabel)
        if let start = startIndex, let end = endIndex {
            let outputString = String(startText[start...end])
            return Double(outputString) ?? 0
        }
        
        return 0
    }
    
    fileprivate func digitIsInt(_ digit: Double) -> Bool {
        return Double(Int(digit)) == digit
    }
    
    func getValueFromPercentage(_ percentage: Double, startValue: Double, endValue: T, curve: QuickTicker.Options) -> Double {
        let endDouble = Double(fromNumeric: endValue)
        switch curve {
        case .easeOut:
            var curvedPercentage = 1 - percentage
            curvedPercentage = 1 - pow(curvedPercentage, 2.8)
            return startValue + (curvedPercentage * (endDouble - startValue))
            
        case .easeIn:
            let curvedPercentage = pow(percentage, 2.8)
            return startValue + (curvedPercentage * (endDouble - startValue))
            
        default:
            return startValue + (percentage * (endDouble - startValue))
        }
    }
    
    fileprivate func getDecimalCount(input: Double) -> Int {
        if digitIsInt(input) { return 0 }
        let str = String(input)
        if let dot = str.index(of: ".") {
            let firstPart = str[str.startIndex...dot]
            var decimals = str
            decimals.removeFirst(firstPart.count)
            return decimals.count
        } else { return 0 }
    }
    
    fileprivate func getCurveFrom(_ options: [QuickTicker.Options]) -> QuickTicker.Options {
        for option in options {
            switch option {
            case .easeOut, .easeIn, .linear: return option
            default: continue
            }
        }
        // default is linear curve
        return .linear
    }
    
    fileprivate func getUserRequestedDecimal(from options: [QuickTicker.Options]) -> Int? {
        for option in options {
            switch option {
            case .decimalPoints(let x): return x >= 0 ? x : 0 // negative values are not allowed
            default: continue
            }
        }
        return nil
    }
    
    func getFirstAndLastDigitIndexes(for label: TextLabel?) -> (start: String.Index?, end: String.Index?) {
        let originalText = label?.text ?? ""
        var set = NSCharacterSet.decimalDigits
        set.insert(".")
        
        var startIndex: String.Index? = nil
        var endIndex: String.Index? = nil
        
        // find indexes for start and end of digits
        for (index, char) in originalText.enumerated() {
            // get unicode value for character
            let scalarValue = char.unicodeScalars.map { $0.value }.reduce(0, +)
            if let scalar = UnicodeScalar(scalarValue) {
                // check if set contains character, i.e valid digit
                if set.contains(scalar) {
                    let digitIndex = originalText.index(originalText.startIndex, offsetBy: index)
                    // this check prevents accidental mid-text detection, decimal cannot be start or end index
                    if char != "." {
                        if startIndex == nil {
                            startIndex = digitIndex
                        }
                        endIndex = digitIndex
                    }
                } else {
                    // exit loop if we already found our range
                    if startIndex != nil && endIndex != nil { break }
                }
            }
        }
        
        return (startIndex, endIndex)
    }
    
    func updateDigitsWhileKeepingText(for label: TextLabel?, value: String) {
        let (startIndex, endIndex) = getFirstAndLastDigitIndexes(for: label)
        if let start = startIndex, let end = endIndex {
            var updatedText = label?.text ?? ""
            // replace old digits with new values
            updatedText.removeSubrange(start...end)
            updatedText.insert(contentsOf: value, at: start)
            label?.text = updatedText
        } else {
            // if there are no digits in starting value, we update the entire label
            label?.text = value
        }
    }
    
    func padValueWithDecimalsIfNeeded(value: Double, requiredDecimals: Int) -> String {
        var output = String(value)
        let valueDecimals = getDecimalCount(input: value)
        let difference = requiredDecimals - valueDecimals
        
        if difference > 0 {
            // if equal to int value, we already get a free 0
            let loopCount = digitIsInt(value) ? (requiredDecimals - 1) : difference
            for _ in 0..<loopCount {
                output.append("0")
            }
        }
        return output
    }
}

// MARK: - This protocol is needed to constrain generic input and convert to other types

public protocol NumericValue : Comparable {
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
    func _asOther<T:NumericValue>() -> T
}

extension NumericValue {
    init<T:NumericValue>(fromNumeric numeric: T) { self = numeric._asOther() }
}

extension Float   : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Double  : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension CGFloat : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int     : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int8    : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int16   : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int32   : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int64   : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt    : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt8   : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt16  : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt32  : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt64  : NumericValue { public func _asOther<T:NumericValue>() -> T { return T(self) }}

// Label needs to have a text property
extension UILabel : TextLabel { }
extension UITextField: TextLabel { }
