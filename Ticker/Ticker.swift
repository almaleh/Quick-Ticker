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

enum QTickerCurve {
    case linear, easeIn, easeOut
}

fileprivate class QTickerAnimation {
    lazy var startValue = getStartingValue(from: animationLabel?.text ?? "")
    let startTime = Date()
    weak var animationLabel: UILabel?
    
    var animationDisplayLink: CADisplayLink? = nil
    let animationEndValue: Int
    let animationCurve: QTickerCurve
    let animationDuration: TimeInterval
    
    init(label: UILabel, duration: TimeInterval, endValue: Int, curve: QTickerCurve) {
        animationLabel = label
        animationDuration = duration
        animationCurve = curve
        animationEndValue = endValue
        animationDisplayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        animationDisplayLink?.add(to: .main, forMode: RunLoop.Mode.default)
    }
    
    @objc private func handleUpdate() {
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        if elapsedTime <= animationDuration {
            let percentage = elapsedTime / animationDuration
            let value = getValueFromPercentage(percentage, startValue: startValue, endValue: animationEndValue, curve: animationCurve)
            
            if (value != animationEndValue) {
                animationLabel?.text = String(value)
            }
        } else {
            animationDisplayLink?.invalidate()
            animationDisplayLink = nil
            animationLabel?.text = String(self.animationEndValue)
        }
    }
    
    private func getStartingValue(from start: String) -> Int {
        let filtered = start.compactMap { Int(String($0)) }
        let joined = filtered.reduce(0) { $0 * 10 + $1 }
        return joined
    }
    
    private func getValueFromPercentage(_ percentage: Double, startValue: Int, endValue: Int, curve: QTickerCurve) -> Int {
        
        switch curve {
        case .linear: return startValue + Int(percentage * Double((endValue - startValue)))
            
        case .easeOut:
            var curvedPercentage = 1 - percentage
            curvedPercentage = 1 - pow(curvedPercentage, 2.5)
            return startValue + Int(curvedPercentage * Double((endValue - startValue)))
            
        case .easeIn:
            let curvedPercentage = pow(percentage, 2.5)
            return startValue + Int(curvedPercentage * Double((endValue - startValue)))
        }
    }
}

class QTicker {
    //TODO: Convenience initializers
    typealias EndValue = Int
    
    static func animate(label: UILabel,
                        duration: TimeInterval = 2,
                        toEndValue endValue: EndValue,
                        curve: QTickerCurve = .linear,
                        completion: (() -> Void)? = nil) {
        
        _ = QTickerAnimation(label: label,
                             duration: duration,
                             endValue: endValue,
                             curve: curve)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion?()
        }
    }
}
