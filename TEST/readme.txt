# OVERVIEW
This is a native iOS app. The app is implemented by MVVM architecture which shows the Github users in a List.
# Features
* List one hundred github users (Non-paginated)
* Each user display thease information: avatar, login (userName), and site_admin (badge)
# Requirements
Develop Environment: Xcode 10.3+
Language: Swift 5.1.2
Support OS: iOS 12.4+
Third party library: Kingfisher
# Installation
1. run `pod install` first.
2. open App.xcworkspace
3. Execute build and run
# Code Structure
* ViewController responsible for UI present
* Use URLSession to get data and save into ViewModel
* ViewModel responsible for process data
* ViewModel will notify ViewController to reload data after processed.
* Use library: Kingfisher to download avatar asynchronily.
