# StormTheRoad-Hackathon
https://lp.google-mkto.com/StormTheRoad-Hackathon-Atlanta.html

##Android Google Maps API Key

Before you can begin working with the API, you will need to download the API and ensure that you have a Google Maps Android API v2 key. 

To get one, follow this link, follow the directions and press "Create" at the end:

https://console.developers.google.com/flows/enableapi?apiid=maps_android_backend&keyType=CLIENT_SIDE_ANDROID&r=B9:18:46:E3:F0:23:3D:68:28:65:1D:49:88:CC:1D:EF:82:46:27:44%3Bcom.weather.hackathon.app

You can also add your credentials to an existing key, using this line:
B9:18:46:E3:F0:23:3D:68:28:65:1D:49:88:CC:1D:EF:82:46:27:44;com.weather.hackathon.app

Once you have your key (it starts with "AIza"), replace the "google_maps_key"
string in android/app/src/release/res/values/google_maps_api.xml.

##iOS Google Maps API Key

Using an API key enables you to monitor your application's API usage, and ensures that Google can contact you about your application if necessary. The key is free, you can use it with any of your applications that call the Google Maps SDK for iOS, and it supports an unlimited number of users. You obtain an API key from the Google Developers Console by providing your application's bundle identifier.

If your project doesn't already have a key for iOS applications, follow these steps to create an API key from the Google Developers Console:

In the sidebar on the left, select Credentials.
Click Create New Key and then select iOS key.
In the resulting dialog, enter your app's bundle identifier. For example: com.weather.hackathon
Click Create.

The Google Developers Console displays a section titled Key for iOS applications with a character-string API key. Here's an example:

AIzaSyBdVl-cTICSwYKrZ95SuvNw7dbMuDt1KG0
Add your API key to your AppDelegate.swift as follows:

Add the following to your AppDelegate class, setting kGoogleMapsAPIKey to your API key

#License

StormTheRoad-Hackathon is licensed under a modified MIT License. See the LICENSE file for more information.