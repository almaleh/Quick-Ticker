//
//  ViewController.swift
//  Ticker
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


import UIKit
import QuickTicker

class ViewController: UIViewController {

    @IBOutlet weak var ticker: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var endValueLabel: UITextField!
    @IBOutlet weak var endValueSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var demoStack: UIStackView!
    
    var increment: Bool = false {
        didSet {
            startDemoCounters(increment: increment)
        }
    }
    
    var decimalCount: Int {
        return getDecimalCount(input: endValue)
    }
    
    var endValue: Double {
        return Double(endValueLabel.text ?? "") ?? 0
    }
    
    var duration: TimeInterval {
        let value = pow(durationSlider.value, 1.5)
        let curvedValue = TimeInterval(value * 15)
        let rounded = Double(round(100 * curvedValue) / 100)
        return rounded
    }
    
    var curve: QuickTicker.Options {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return .linear
        case 1: return .easeIn
        default: return .easeOut
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        endValueLabel.delegate = self
        // Monospace is important to prevent wobbling
        ticker.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        
    }
    
    @IBAction func startTicker(_ sender: UIButton) {
        startCustomCounter()
    }
    
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        let oldValue = Double(ticker.text ?? "") ?? 0
        let value = pow(endValueSlider.value, 3)
        let curvedValue = Double(value * 25000)
        let decimalCount = getDecimalCount(input: oldValue)
        if decimalCount > 0 {
            endValueLabel.text = String(truncateNumber(curvedValue, toDecimals: decimalCount))
        } else {
            endValueLabel.text = String(Int(curvedValue))
        }
    }
    
    @IBAction func durationSliderChanged(_ sender: UISlider) {
        durationLabel.text = String(duration)
    }
    
    
    @IBAction func startDemo(_ sender: UIButton) {
        increment = !increment
    }
    
}

extension ViewController {
    
    // Animates the custom animation counter
    func startCustomCounter() {
        QuickTicker.animate(label: ticker, toEndValue: endValue, duration: duration, options: [curve, .decimalPoints(decimalCount)]) {
            print("Animation done!")
        }
    }
    
    // Animates the 3 demo counters at the bottom
    func startDemoCounters(increment: Bool) {
        for case let stack as UIStackView in demoStack.arrangedSubviews {
            for case let label as UILabel in stack.arrangedSubviews {
                let endValue: Double = increment ? 100 : 0
                let duration: Double = 3.5
                let decimalCount = 0
                var curve: QuickTicker.Options = .linear
                label.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .regular)
                
                switch label.tag {
                case 1: curve = .linear
                case 2: curve = .easeOut
                case 3: curve = .easeIn
                default: continue
                }
                
                QuickTicker.animate(label: label, toEndValue: endValue, duration: duration, options: [curve, .decimalPoints(decimalCount)]) {
                    print("Finished animation with \(curve) curve!")
                }
            }
        }
    }
}


extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - helper methods

extension ViewController {
    
    private func truncateNumber(_ number: Double, toDecimals: Int) -> Double {
        let power = pow(10, Double(toDecimals))
        return Double(round(power * number) / power)
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
    
    private func digitIsInt(_ digit: Double) -> Bool {
        return Double(Int(digit)) == digit
    }
}
