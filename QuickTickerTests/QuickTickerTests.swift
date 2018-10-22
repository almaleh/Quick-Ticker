//
//  QuickTickerTests.swift
//  QuickTickerTests
//
//  Created by Besher on 2018-10-21.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import XCTest
@testable import Ticker


class QuickTickerTests: XCTestCase {
    
    func generateDoubleTestObject() -> QTObject<Double> {
        let label = UILabel(frame: CGRect.zero)
        label.text = "0"
        let duration: Double = 0
        let endValue: Double = 100
        let options: [QuickTicker.Options] = [.linear, .decimalPoints(0)]
        return QTObject(label: label, duration: duration, endValue: endValue, options: options, completion: nil)
    }

    func generateIntTestObject() -> QTObject<Int> {
        let label = UILabel(frame: CGRect.zero)
        label.text = "0"
        let duration: Double = 0
        let endValue: Int = 100
        let options: [QuickTicker.Options] = [.linear, .decimalPoints(0)]
        return QTObject(label: label, duration: duration, endValue: endValue, options: options, completion: nil)
    }
    
    lazy var array = [generateDoubleTestObject(), generateIntTestObject()]
    
    // TODO: Array of all types

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStartingValue() {
        let object = generateIntTestObject()
        let label = UILabel()
        let doubleValue: Double = 150
        label.text = String(doubleValue)
        let stringValue = object.getStartingValue(from: label)
        XCTAssertEqual(stringValue, doubleValue, "Starting value is not accurate")
        
        // Int object and Double end value
        for _ in 0...10 {
            let object = generateIntTestObject()
            let randomDouble = Double.random(in: -11110...999999)
            label.text = String(randomDouble)
            let stringRandomValue = object.getStartingValue(from: label)
            XCTAssertEqual(stringRandomValue, randomDouble, "Starting value with random double is not accurate")
            print("Tested with \(randomDouble)")
        }
        
        // Int object and Int end value
        for _ in 0...10 {
            let object = generateIntTestObject()
            let randomDouble = Int.random(in: -11110...999999)
            label.text = String(randomDouble)
            let stringRandomValue = object.getStartingValue(from: label)
            XCTAssertEqual(stringRandomValue, Double(randomDouble), "Starting value with random double is not accurate")
            print("Tested with \(randomDouble)")
        }
        
        // Double object and Double end value
        for _ in 0...10 {
            let object = generateDoubleTestObject()
            let randomDouble = Double.random(in: -11110...999999)
            label.text = String(randomDouble)
            let stringRandomValue = object.getStartingValue(from: label)
            XCTAssertEqual(stringRandomValue, randomDouble, "Starting value with random double is not accurate")
            print("Tested with \(randomDouble)")
        }
        
        // Double object and Int end value
        for _ in 0...10 {
            let object = generateDoubleTestObject()
            let randomDouble = Int.random(in: -11110...999999)
            label.text = String(randomDouble)
            let stringRandomValue = object.getStartingValue(from: label)
            XCTAssertEqual(stringRandomValue, Double(randomDouble), "Starting value with random double is not accurate")
            print("Tested with \(randomDouble)")
        }
    }
    
    func testGetFirstAndLastDigitIndexes() {
        let object = generateIntTestObject()
        
        let tempLabel = UILabel()
        tempLabel.text = "Temperature: 98 F"
        let (start, end) = object.getFirstAndLastDigitIndexes(for: tempLabel)
        if let start = start, let end = end, let labelText = tempLabel.text {
            XCTAssertEqual(String(labelText[start...end]), "98")
        }
        
        let regularLabel = UILabel()
        regularLabel.text = "2938.98"
        let (start2, end2) = object.getFirstAndLastDigitIndexes(for: regularLabel)
        if let start = start2, let end = end2, let labelText = regularLabel.text {
            XCTAssertEqual(String(labelText[start...end]), "2938.98")
        }
        
        let mixedLabel = UILabel()
        mixedLabel.text = "mixed983.1000bingo"
        let (start3, end3) = object.getFirstAndLastDigitIndexes(for: mixedLabel)
        if let start = start3, let end = end3, let labelText = mixedLabel.text {
            XCTAssertEqual(String(labelText[start...end]), "983.1000")
        }
    }
    
    func testGetValueFromPercentage() {
        let object = generateDoubleTestObject()
        
        let half = 0.5
        let startValue: Double = 0
        let endValue: Double = 100
        
        let linearValue = object.getValueFromPercentage(half, startValue: startValue, endValue: endValue, curve: .linear)
        XCTAssert(linearValue == 50)
        
        let easeOutValue = object.getValueFromPercentage(half, startValue: startValue, endValue: endValue, curve: .easeOut)
        XCTAssert(easeOutValue > 75)
        
        let easeInValue = object.getValueFromPercentage(half, startValue: startValue, endValue: endValue, curve: .easeIn)
        XCTAssert(easeInValue < 25)
    }
    
    func testUpdateDigitsWhileKeepingText() {
        let object = generateIntTestObject()
        let label = UILabel()
        
        label.text = "Temperature: 98 F"
        object.updateDigitsWhileKeepingText(for: label, value: "23.5")
        XCTAssert(label.text == "Temperature: 23.5 F")
        
        label.text = "Temperature: 0Celsius"
        object.updateDigitsWhileKeepingText(for: label, value: "1928")
        XCTAssert(label.text == "Temperature: 1928Celsius")
        
        label.text = "29.19 meters"
        object.updateDigitsWhileKeepingText(for: label, value: "10009.300")
        XCTAssert(label.text == "10009.300 meters")
    }
    
    func testUpdateLabel() {
        let object = generateDoubleTestObject()
        let label = UILabel()
        
        label.text = "Temperature: 0 F"
        
        
        object.updateLabel(label, withValue: 55, numberOfDecimals: 0)
        XCTAssert(label.text == "Temperature: 55 F")
        
        object.updateLabel(label, withValue: 55, numberOfDecimals: 1)
        XCTAssert(label.text == "Temperature: 55.0 F")
        
        object.updateLabel(label, withValue: 55, numberOfDecimals: 2)
        XCTAssert(label.text == "Temperature: 55.00 F")
        
        object.updateLabel(label, withValue: 55, numberOfDecimals: 3)
        XCTAssert(label.text == "Temperature: 55.000 F")
        
        object.updateLabel(label, withValue: 51255.4812, numberOfDecimals: 0)
        XCTAssert(label.text == "Temperature: 51255 F")
        
        for item in array {
            print(item)
        }
    }
    
    func testPadIfNeeded() {
        let object = generateIntTestObject()
        
        let value1 = 98.213
        let pad1 = object.padValueWithDecimalsIfNeeded(value: value1, requiredDecimals: 8)
        XCTAssert(pad1 == "98.21300000")
        
        let value2 = 98.0
        let pad2 = object.padValueWithDecimalsIfNeeded(value: value2, requiredDecimals: 1)
        XCTAssert(pad2 == "98.0")
        
        let value3 = 98.0
        let pad3 = object.padValueWithDecimalsIfNeeded(value: value3, requiredDecimals: 2)
        XCTAssert(pad3 == "98.00")
        
        let value4 = 98.00
        let pad4 = object.padValueWithDecimalsIfNeeded(value: value4, requiredDecimals: 3)
        XCTAssert(pad4 == "98.000")
        
        let value5 = 98.01
        let pad5 = object.padValueWithDecimalsIfNeeded(value: value5, requiredDecimals: 3)
        XCTAssert(pad5 == "98.010")
        
        let value6 = 1928.980
        let pad6 = object.padValueWithDecimalsIfNeeded(value: value6, requiredDecimals: 13)
        XCTAssert(pad6 == "1928.9800000000000")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
