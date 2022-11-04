# ECard
## About
ECard, as its name states, is a electronic business card. As nowadays people are busier than usual, 
we have created an app for individuals to exchange their contact information conveniently, by just bumping their phone while the app is open.

## How to Use the App

## Dependencies & Libraries

### UIKit
The overall framework of the app, also providing components to utilize. For our app, for example, the transition between different views are provided by UIKit. Dive in deeper, each view has a lifecycle that can trigger the app to perform specific functions: e.g. after pressing the *login* button on the login view, it will trigger a *loading* pop-up view for the user.

### Foundation
Providing essential data types, collections and basic api's, such as:```Int```,```String```, ```Array```, ```DateTime```,```FlieManager```, ```URLSession```.

### MultipeerConnectivity
This library provides the curcial functionality of this app, as we utilize it to make the user's phone connect and exchange data with nearby other users via Bluetooth and/or WiFi.


### Realm & Realm Database
As we used MangoDB as our server-side database to store user data, Realm provide us with the power connecting to the cloud database for retrieving and uploading users' information and credentials.



## Structure
### File Structure
<img src="https://user-images.githubusercontent.com/78742794/196007857-2b13ab12-46eb-4a43-8f92-4efbbc9efa59.png" width="250"/>

### Workflow
<img src="https://user-images.githubusercontent.com/78742794/196007692-8e8781c1-6e8c-49d7-958c-0bc6ec31c1b4.png"/>


