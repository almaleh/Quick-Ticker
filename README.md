

<p align="center"><img src="https://github.com/almaleh/Quick-Ticker/blob/master/Images/QuickTickerLogo.png" width="750" /></p>

<p align="center">A Swift library for animating labels and text fields</p>

<p align="center"><img src="https://github.com/almaleh/Quick-Ticker/blob/master/Images/Demo.gif" width="350" /></p>

[![Version](https://img.shields.io/cocoapods/v/QuickTicker.svg?style=flat)](https://cocoapods.org/pods/QuickTicker)
[![License](https://img.shields.io/cocoapods/l/QuickTicker.svg?style=flat)](https://cocoapods.org/pods/QuickTicker)
[![Platform](https://img.shields.io/cocoapods/p/QuickTicker.svg?style=flat)](https://cocoapods.org/pods/QuickTicker)
![Swift 4](https://img.shields.io/badge/swift-4.2-orange.svg)

## Installation

<b>Manually:</b>

Simply copy the QuickTicker.Swift file to your project (it is located in QuickTicker > Classes)

<b>Cocoapods:</b>

QuickTicker is also available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'QuickTicker'
```

## Features

- Simple syntax similar to UIView's animate methods
- It works even if there is text mixed in with numbers in the same label. Text remains intact while the digits get animated!
- Works on both UILabels and UITextFields, and accepts any Numeric value (no need to type cast or convert)
- Completion handler lets you safely queue-up actions following the animation
- You can optionally specify animation curves and decimal points for the label
- Completely safe to destroy or deallocate your label mid-animation, no strong reference is kept
- Unit tested and checked for memory leaks

## Quick Functions

You can get started with a simple one line function call
```swift
QuickTicker.animate(label: textLabel, toEndValue: 250)
```
The default duration is 2 seconds, but that can be easily changed
```swift
QuickTicker.animate(label: textLabel, toEndValue: 250, duration: 4.3)
```
You can also specify the animation curve
```swift
QuickTicker.animate(label: textLabel, toEndValue: 250, options: [.easeOut])
```
## Advanced Quick Ticker

You can optionally specify the duration, the animation curve, decimal points, and add a completion handler to be executed at the end of the animation. 
```swift
QuickTicker.animate(label: textLabel, toEndValue: 250, duration: 4.3, options: [.easeOut, .decimalPoints(2)], completion: {
                        print("Ticker animation done!")
                    })
```

## Compatible Types

Enter any of the following types as the end value for the animation, no need to type cast!
- [x] CGFloat
- [x] Float
- [x] Double
- [x] Int
- [x] UInt
- [x] Int8
- [x] UInt8
- [x] Int16
- [x] UInt16
- [x] Int32
- [x] UInt32
- [x] Int64
- [x] UInt64

## What it looks like

Sample App:<br>
<img src="https://github.com/almaleh/Quick-Ticker/blob/master/Images/usage.gif" width="350">

[InstaWeather:](https://itunes.apple.com/us/app/instaweather/id1341392811?ls=1&mt=8)<br>
<img src="https://github.com/almaleh/Quick-Ticker/blob/master/Images/weather.gif" width="350">

[Find My Latte:](https://itunes.apple.com/us/app/find-my-latte/id1435110287?ls=1&mt=8)<br>
<img src="https://github.com/almaleh/Quick-Ticker/blob/master/Images/Latte%20stats.gif" width = "350">

[Find My Latte:](https://itunes.apple.com/us/app/find-my-latte/id1435110287?ls=1&mt=8)<br>
<img src="https://github.com/almaleh/Quick-Ticker/blob/master/Images/Latte%20screencap.gif" width="350">

## Try it!

To run the example project, clone the repo, and launch QuickTicker.xcworkspace from the Example directory.

## Requirements

- iOS 9.0+
- Swift 4.2 (you can run it on 4.0 by changing the CADisplayLink api call, one line of code)
- Xcode 10 (same as above to run on older Xcode)

## Release History

* 0.0.1
    * Initial release

## Author

Besher Al Maleh – almalehdev@gmail.com

Distributed under the MIT license. See [LICENSE](https://github.com/almaleh/Quick-Ticker/blob/master/LICENSE) for more information.

[https://github.com/almaleh/github-link](https://github.com/almaleh/)
<br>
[LinkedIn](https://www.linkedin.com/in/besher-al-maleh/)

## Contributing

Contributors are welcome!
1. Fork it (<https://github.com/almaleh/Quick-Ticker/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
