//
//  ViewController.swift
//  Ticker
//
//  Created by Besher on 2018-10-16.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var linear: UILabel!
    @IBOutlet weak var easeOut: UILabel!
    @IBOutlet weak var easeIn: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var endValueLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    
    var endValue: Int {
        let value = pow(slider.value, 3)
        let curvedValue = Int(value * 25000)
        return curvedValue
    }
    
    var duration: TimeInterval {
        let value = pow(durationSlider.value, 1.5)
        let curvedValue = TimeInterval(value * 15)
        let rounded = Double(round(100 * curvedValue) / 100)
        return rounded
    }
    
    var curve: QTickerCurve {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return .linear
        case 1: return .easeIn
        default: return .easeOut
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func startTicker(_ sender: UIButton) {
        let startValue = Int(linear.text ?? "") ?? 0
        
        linear.startTicker(duration: duration, until: endValue, curve: curve) { [unowned self] in
            self.linear.startTicker(duration: self.duration, until: startValue, curve: self.curve)
            
        }
        
    }
    
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        endValueLabel.text = String(endValue)
    }
    
    @IBAction func durationSliderChanged(_ sender: UISlider) {
        durationLabel.text = String(duration)
    }
    
}

