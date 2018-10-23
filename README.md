

<p align="center"><img src="https://github.com/almaleh/Quick-Ticker/blob/master/Images/QuickTickerLogo.png" width="750" /></p>

<p align="center">A Swift library for animating labels and text fields</p>

<p align="center"><img src="https://github.com/almaleh/Quick-Ticker/blob/master/Images/Demo.gif" width="350" /></p>

## Installation

<b>Manually:</b>

Simply copy the QuickTicker.Swift file in Sources to your project

<b>Cocoapods:</b>

Coming soon!


## Features

- Simple syntax similar to UIView's animate methods
- It works even if there is text mixed in with numbers in the same label. Your text will remain intact while the digits get animated!
- Works on both UILabels and UITextFields, and accepts any Numeric value (no need to type cast or convert)
- Completion handler lets you safely queue-up actions following the animation
- You can optionally specify animation curves and decimal points for the label
- Unit tested and checked for memory leaks

## Quick Functions

You can get started with a simple one line function call
```swift
QuickTicker.animate(label: textLabel, toEndValue: 250)
```
The default duration is 2 seconds, but that can be easily changed
```swift
QuickTicker.animate(label: TextLabel, toEndValue: 55, withDuration: 4.3)
```
You can also specify the animation curve
```swift
QuickTicker.animate(label: textLabel, toEndValue: 18.12, options: [.easeOut])
```
## Advanced Quick Ticker

You can optionally specify the duration, the animation curve, decimal points, and add a completion handler to be executed at the end of the animation. 
```swift
QuickTicker.animate(label: textLabel, toEndValue: 38.89, withDuration: 2.5, options: [.easeOut, .decimalPoints(2)], completion: {
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

The example project demonstrates the different ways to use the library. Clone it and give it a try!

## Requirements

- iOS 9.0+
- Swift 4.2 (you can run it on 4.0 by changing the CADisplayLink api call, one line of code)
- Xcode 10

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
