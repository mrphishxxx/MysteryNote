# MysteryNote

## Synopsis

Project allows you to send a text message from a central phone number using Twilio.  It also allows the receiver to send a message back using a unique (but anonymous) identifier as the beginning of the message.

Note that Apple does not allow such apps on the Apple Store, so this is merely for curiosity.

This app works for both iPhone and iPad devices.

![](https://github.com/jgafni/MysteryNote/blob/master/iOS%20Simulator%20Screen%20Shot%20May%2026,%202015,%2010.52.38%20PM.png?raw=true)

## Details

The app allows you to enter in the recipient's phone number, a text message, and your phone number to allow for the recipient to text message you back.

## Installation

First, create a Twilio account, and replace the following strings in AnonTextViewController.swift: 

    let twilio_accountsid_LIVE = "TWILIO LIVE ACCOUNT ID"
    let twilio_authtoken_LIVE = "TWILIO AUTH TOKEN"
    let twilio_phone = "TWILIO PHONE NUMBER"

Second, add an app in Parse, and replace the following strings in AppDelegate.swift:

     Parse.setApplicationId("PARSE ID", clientKey: "PARSE CLIENT KEY");

Third, in Parse, create a class TextID, with a text field named "phone".

## Contributors

Feel free to add additiona features

## License

The MIT License (MIT)

Copyright (c) 2015 Joshua Gafni

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
