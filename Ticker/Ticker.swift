//
//  Ticker.swift
//  Ticker
//
//  Created by Besher on 2018-10-16.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import ObjectiveC

protocol TextLabel: class {
    var text: String? { get set }
}

private typealias Handler = (() -> Void)?

private class QTickerAnimation<T: NumericValue> {
    
    let animationStartTime = Date()
    lazy var animationStartValue = getStartingValue(from: animationLabel?.text ?? "")
    var userRequestedNumberOfDecimals: Int? = nil
    
    var requiredNumberOfDecimals: Int {
        // if user requested a specific number we use it, otherwise we infer from end value
        return userRequestedNumberOfDecimals ?? getDecimalCount(input: Double(fromNumeric: animationEndValue))
    }
    
    // The following properties are set during initialization
    weak var animationLabel: TextLabel?
    var animationCompletion: Handler
    var animationDisplayLink: CADisplayLink? = nil
    let animationEndValue: T
    var animationCurve: QuickTicker.Options = .linear
    let animationDuration: TimeInterval
    
    init(label: TextLabel, duration: TimeInterval, endValue: T, options: [QuickTicker.Options],
        completion: Handler) {
        animationLabel = label
        animationDuration = duration
        animationEndValue = endValue
        animationCurve = getCurveFrom(options)
        animationCompletion = completion
        animationDisplayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        animationDisplayLink?.add(to: .main, forMode: RunLoop.Mode.default)
        userRequestedNumberOfDecimals = getUserRequestedDecimal(from: options)
    }
    
    @objc private func handleUpdate() {
        handleUpdateFor(animationLabel, startTime: animationStartTime, animationDuration: animationDuration,
                        startValue: animationStartValue, endValue: animationEndValue, curve: animationCurve,
                        displayLink: animationDisplayLink)
    }
    
    private func handleUpdateFor(_ label: TextLabel?, startTime: Date, animationDuration: TimeInterval,
                                 startValue: Double, endValue: T, curve: QuickTicker.Options,
                                 displayLink: CADisplayLink?) {
        
        var animationDisplayLink = displayLink
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        if elapsedTime <= animationDuration {
            let percentage = elapsedTime / animationDuration
            let value = getValueFromPercentage(percentage, startValue: startValue, endValue: endValue, curve: curve)
            if (value != Double(fromNumeric: animationEndValue)) {
                updateLabel(label, withValue: value, numberOfDecimals: requiredNumberOfDecimals)
            }
        } else {
            animationDisplayLink?.invalidate()
            animationDisplayLink = nil
            updateLabel(label, withValue: Double(fromNumeric: endValue), numberOfDecimals: requiredNumberOfDecimals)
            animationCompletion?()
        }
    }
    
    private func updateLabel(_ label: TextLabel?, withValue value: Double, numberOfDecimals: Int) {
        
        let power = pow(10, Double(numberOfDecimals))
        let updatedValue = Double(round(power * value) / power)
        
        if numberOfDecimals == 0 {
            label?.text = String(Int(updatedValue))
        } else {
            label?.text = String(updatedValue)
        }
    }
    
    
    
    // Helper methods
    
    private func getStartingValue(from start: String) -> Double {
        // first try to typecast
        if let digit = Double(start) {
            return digit
        }
        // filter digits from label if typecast fails
        let filtered = start.compactMap { Double( String($0)) }
        let joined = filtered.reduce(0) { $0 * 10 + $1 }
        return joined
    }
    
    private func digitIsInt(_ digit: Double) -> Bool {
        return Double(Int(digit)) == digit
    }
    
    private func getValueFromPercentage(_ percentage: Double, startValue: Double, endValue: T, curve: QuickTicker.Options) -> Double {
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
    
    private func getCurveFrom(_ options: [QuickTicker.Options]) -> QuickTicker.Options {
        for option in options {
            switch option {
            case .easeOut, .easeIn, .linear: return option
            default: continue
            }
        }
        // default is linear curve
        return .linear
    }
    
    private func getUserRequestedDecimal(from options: [QuickTicker.Options]) -> Int? {
        for option in options {
            switch option {
            case .decimalPoints(let x): return x
            default: continue
            }
        }
        return nil
    }
    
}

// MARK: - Public class

public class QuickTicker {
    
    enum Options {
        case linear, easeIn, easeOut
        case decimalPoints(_ value: Int)
    }
    
    //TODO: Convenience initializers
    
    /// Starts a ticker animation on a UILabel or TextField using the provided end value. Options include animation curve and decimal points
    class func animate<T: NumericValue, L: TextLabel>(label: L, toEndValue endValue: T, withDuration duration: TimeInterval,
                                                      options: [Options] = [.linear], completion: (() -> Void)? = nil) {

        _ = QTickerAnimation(label: label, duration: duration, endValue: endValue,
                             options: options, completion: completion)
    }
    
    /// Starts a ticker animation on a UILabel or TextField using a default 2 second duration and linear curve
    class func animate<T: NumericValue, L: TextLabel>(label: L, toEndValue endValue: T, completion: (() -> Void)? = nil) {
        animate(label: label, toEndValue: endValue, withDuration: 2, options: [.linear])
    }
    
    /// Starts a ticker animation on a UILabel or TextField using a default 2 second duration
    class func animate<T: NumericValue, L: TextLabel>(label: L, toEndValue endValue: T, options: [Options], completion: (() -> Void)? = nil) {
        animate(label: label, toEndValue: endValue, withDuration: 2, options: options)
    }
    
}

// MARK: - Protocol is needed to constrain generic input

// This protocol allows us to cast generic input to other types
protocol NumericValue : Comparable {
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

extension Float   : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Double  : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension CGFloat : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int     : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int8    : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int16   : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int32   : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension Int64   : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt    : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt8   : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt16  : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt32  : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}
extension UInt64  : NumericValue {func _asOther<T:NumericValue>() -> T { return T(self) }}

extension UILabel : TextLabel { }
extension UITextField: TextLabel { }

