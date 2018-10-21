//
//  ViewController.swift
//  Ticker
//
//  Created by Besher on 2018-10-16.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ticker: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var endValueLabel: UITextField!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    
    var endValue: Double {
        return Double(endValueLabel.text ?? "") ?? 0
    }
    
    var duration: TimeInterval {
        let value = pow(durationSlider.value, 1.5)
        let curvedValue = TimeInterval(value * 15)
        let rounded = Double(round(100 * curvedValue) / 100)
        return rounded
    }
    
    var curve: QuickTicker.AnimationCurve {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return .linear
        case 1: return .easeIn
        default: return .easeOut
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        endValueLabel.delegate = self
        ticker.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        
    }
    
    @IBAction func startTicker(_ sender: UIButton) {
        QuickTicker.animate(label: ticker, toEndValue: endValue, duration: duration, curve: curve) {
            print("VICTORY")
        }
    }
    
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        let oldValue = Double(ticker.text ?? "") ?? 0
        let value = pow(slider.value, 3)
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
    
    @IBAction func resetTapped(_ sender: UIButton) {
        ticker.text = ""
    }
    
    
}


extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

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
