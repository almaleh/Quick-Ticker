//
//  Ticker.swift
//  Ticker
//
//  Created by Besher on 2018-10-16.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import ObjectiveC

private enum LabelType {
    case score
}

// TODO: provide bundle of settings in a struct
struct settings {
    
}

enum QTickerCurve {
    case linear, easeIn, easeOut
}

extension UILabel {
    
    func startTicker(duration: TimeInterval = 2, until endValue: Int, curve: QTickerCurve = .linear, completion: (() -> Void)? = nil) {
        let initialText = self.text ?? "0"
        self.endValue = endValue
        
        animationCurve = curve
        animationDuration = duration
        
        startTime = Date()
        startValue = getStartingValue(from: initialText)
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink?.add(to: .main, forMode: RunLoop.Mode.default)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            completion?()
        }
    }
    
    @objc private func handleUpdate() {
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        if elapsedTime <= animationDuration {
            let percentage = elapsedTime / animationDuration
            let value = getValueFromPercentage(percentage, startValue: startValue, endValue: endValue, curve: animationCurve)
            
            if (value != endValue) {
                self.text = String(value)
            }
        } else {
            displayLink?.invalidate()
            displayLink = nil
            self.text = String(self.endValue)
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


extension UILabel {
    
    //TODO safety precaution: if anything is nil, stop timer instead of crashing
    private struct AssociatedKeys {
        static var animationDuration = "animationDuration",
                   startTime = "StartDate",
                   displayLink = "displayLink",
                   startValue = "startValue",
                   endValue = "endValue",
                   curve = "curve"
    }
    
    fileprivate var startTime: Date {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startTime) as? Date ?? Date()
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startTime, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate var animationDuration: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.animationDuration) as? TimeInterval ?? 2
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.animationDuration, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate var displayLink: CADisplayLink? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.displayLink) as? CADisplayLink
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.displayLink, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate var startValue: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.startValue) as? Int ?? 0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.startValue, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate var endValue: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.endValue) as? Int ?? 0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.endValue, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate var animationCurve: QTickerCurve {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.curve) as? QTickerCurve ?? .linear
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.curve, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
