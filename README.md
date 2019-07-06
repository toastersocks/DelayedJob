# DelayedJob

Run a task at a later time. Subsequent requests to run the job while there's already one scheduled will result in either the already scheduled job to be canceled or the new run to be ignored. Whether to prioritize runs scheduled for sooner or for later can be configured.

## Uses

This can be useful, for instance, if you'd like to initiate a network request as the user is typing but only if the user stops typing for at least a second in order to not fire off too many unnecessary network requests.

``` Swift

let networkRequest = DelayedJob(prioritize: .later) { networkFetcher.sendRequest(searchText) }

func editingDidChange(sender: UITextField) {
    searchText = sender.text
    networkRequest.run(withDelay: 1)
}
```
Using the `.later` priority, if a run is requested before the existing run has fired, the previously scheduled run is canceled and the new one is scheduled. That way the network request will only actually be run when the user stops typing for more than a second.

## Instalation

### Cocoapods

Add this to your `Podfile`:

``` Ruby
target 'MyApp' do 
    use_frameworks! # Remove this line to use as a static framework
    
    pod 'DelayedJob'
end
```
And run `pod install`

### Swift Package Manager
#### Via `swift package`
Add this repo to your `Package.swift` dependencies:
``` Swift
.package(url: "https://github.com/toastersocks/DelayedJob", from: "1.0.0"),
```
And add `Delayed Job` as a dependency of your target
``` Swift
.target(
    name: "MyTarget",
    dependencies: ["DelayedJob"]),
.testTarget(
    name: "MyTargetTests",
    dependencies: ["MyTarget"]),
```
All together:
``` Swift
// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyExecutableOrLibrary",
    platforms: [.macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3)], // <-- for Apple platforms, add at least one platform. For non-Apple platforms, this isn't necessary.
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/toastersocks/DelayedJob", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MyTarget",
            dependencies: ["DelayedJob"]),
        .testTarget(
            name: "MyTargetTests",
            dependencies: ["MyTarget"]),
    ]
)
```
#### Via Xcode
If you're using Xcode 11 or higher, you can use the Swift Package Manager integration in Xcode. 

- Select your `.xcproject` file
- Select the project under `PROJECT`
- Select `Swift Package`
- Tap the `+` sign
- Paste this repo's address `https://github.com/toastersocks/DelayedJob` into the text field and hit `Next`
 - Choose your version/branch on the next screen
 - Choose your targets and hit `Finish`!
 - Wow 🤯
 
 ### Carthage
 Add this to your `Cartfile`
 ``` Ruby
 github "toastersocks/DelayedJob" ~> "1.0.0"
 ```
 And follow the directions here: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application
