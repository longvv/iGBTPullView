
# iGBTPullView

`iGBTPullView` is a customizable pull-to-refresh and pull-to-load more library for iOS applications.

## Features

- Pull-to-refresh
- Pull-to-load more
- Easy customization
- Support for different modes

## Installation

### CocoaPods

To integrate `iGBTPullView` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'iGBTPullView'
```

Then, run the following command:

```bash
pod install
```

## Usage

### Initialization

To use `iGBTPullView`, import the library and initialize it in your view controller:

```swift
import iGBTPullView

class ViewController: UIViewController {
    var pullView: iGBTPullView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPullView()
    }

    func setupPullView() {
        pullView = iGBTPullView()
        pullView.delegate = self
        self.view.addSubview(pullView)
    }
}
```

### Customization

You can customize various aspects of the pull view, such as its colors, fonts, and animations, by modifying the properties in `iGBTPullViewConstants` and `iGBTPullViewElements`.

### Modes

`iGBTPullView` supports different modes for pull-to-refresh and pull-to-load more. You can switch between these modes by setting the appropriate properties in `iGBTPullViewMode`.

## Example Project

The `Example` directory contains a sample project demonstrating how to integrate and use `iGBTPullView` in an iOS application.

### Main Files

- **AppDelegate.swift**: Manages the application lifecycle.
- **ViewController.swift**: Demonstrates the use of `iGBTPullView`.
- **Main.storyboard**: The UI layout for the example project.
- **LaunchScreen.xib**: The launch screen layout.

## Testing

The `Example/Tests` directory contains unit tests for the example application.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
