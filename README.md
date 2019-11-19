# ComicReader

This is a Marvel comic book reader prototype.  It's goal is to demonstrate querying the Marvel API, cache the results, and display them.  

### Project features:
* Dependency injection
* MVVM architecture
* ReactiveKit (Rx) Swift used between view models and controllers
* AppDelegate uses the service design pattern
  * Initial goal was to use a window service to configure the UIWindow, but SceneDelegate made this obsolete
  * CoreDataService left in place as an example, but is empty
* Unit tests for networking and reactive Swift (although not 100% code coverage)
* Marvel API keys automagically imported from ~/.bash_profile, otherwise can be set within NetworkProvider.swift
* CoreData used to cache network calls and SDWebImage used to cache images
  * CoreData selected over Realm
    * Realm's framework adds additional size to the app's binary
    * Any object which consumes a Realm derived model must import and have knowledge about Realm
* Network API uses Apple's NSURLSession
* UI kept plain and simple to focus on app architecture 

List View | Detail View
--- | --- 
<img src="https://raw.githubusercontent.com/rsbauer/comicreader/master/images/ListViewController.png" width="300px"> | <img src="https://raw.githubusercontent.com/rsbauer/comicreader/master/images/DetailViewController.png" width="300px">

### Getting Started

You will need the source code from here and the latest Xcode installed.  

Although CocoaPods was used, the author added the Pods directory to the repository in case a pod is no longer avaialbe and to ease onboarding.  

If desired, pods can be installed: (this requiers CocoaPods to be installed)

  `pod install`

### Prerequisites

Before starting, you will need Cocoapods installed.  

You will also need a Marvel public and private API key.  This may be had by logging in to https://developer.marvel.com/.  

With the MARVEL public and private keys, place them in your ~/.bash_profile as 
```
export MARVEL_PRIVATE_KEY="[PRIVATE KEY HERE]"
export MARVEL_PUBLIC_KEY="[PUBLIC KEY HERE]"
```

Alternatively, update the `publicKey` and `privateKey` variables with the appropriate keys in NetworkProvider.swift's init().

1. Clone this repo

  `git clone [this repo url]`

2. Install pods

  `pod install`

5. Open the ComicReader.xcworkspace

  `open ComicReader.wxworkspace`

6. Build!

## Running the tests

From Xcode, select the Test Navigator and select all tests or individual tests.
 
## Deployment

Deployments are ad hoc at this time.

### License

See LICENSE file located in this repository.

