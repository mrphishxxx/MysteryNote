//
//  AnonTextViewController.swift
//  MysteryNote
//
//  Created by Joshua Gafni on 3/12/15.
//  Copyright (c) 2015 jgafni. All rights reserved.
//

import UIKit
import QuartzCore
import Parse

class AnonTextViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var replyPhoneTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    var keyboardIsShowing: Bool = false
    let twilio_accountsid_LIVE = "TWILIO LIVE ACCOUNT ID"
    let twilio_authtoken_LIVE = "TWILIO AUTH TOKEN"
    let twilio_phone = "TWILIO PHONE NUMBER"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissAll"))
        self.addProgramObservers()
        
        self.phoneTextField.attributedPlaceholder = self.placeHolderText(self.phoneTextField)
        self.replyPhoneTextField.attributedPlaceholder = self.placeHolderText(self.replyPhoneTextField)
    }
    
    func placeHolderText(textField:UITextField)->NSAttributedString{
        if textField==self.phoneTextField {
            return NSAttributedString(string: "Enter Recipient's Phone Number",
                attributes:[NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(14))])
        }
        else if textField == self.replyPhoneTextField{
            return NSAttributedString(string: "Enter Your Phone Number",
                attributes:[NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(14))])
        }
        return NSAttributedString(string: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var deviceType = UIDevice.currentDevice().model
        if deviceType.rangeOfString("iPad")==nil{
            self.addKeyboardObservers()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(string: "")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.phoneTextField {
            self.phoneTextField.attributedPlaceholder = self.placeHolderText(self.phoneTextField)
        }
        else if textField == self.replyPhoneTextField {
            self.replyPhoneTextField.attributedPlaceholder = self.placeHolderText(self.replyPhoneTextField)
        }
    }
    
    //http://stackoverflow.com/questions/1246439/uitextfield-for-phone-number
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        if textField == self.phoneTextField || textField == self.replyPhoneTextField {
            var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            var components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            var decimalString = "".join(components) as NSString
            var length = decimalString.length
            var hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11{
                var newLength = (textField.text as NSString).length + (string as NSString).length - range.length as Int
                
                if newLength == 0{
                    textField.resignFirstResponder()
                }
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            var formattedString = NSMutableString()
            
            if hasLeadingOne{
                formattedString.appendString("1 ")
                index += 1
            }
            if length - index > 3{
                var areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3{
                var prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            var remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            if self.mobileIsValid(textField.text){
                textField.resignFirstResponder()
            }
            return false
        }
        else{
            return true
        }
    }
    
    let defaultTextViewString = "Enter Anonymous Message"
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView == self.messageTextView{
            if textView.text == defaultTextViewString {
                textView.text = ""
            }
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == self.messageTextView{
            if textView.text == "" {
                textView.text = defaultTextViewString
            }
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            self.sendButtonTouched(self.sendButton)
            return false
        }
        return true
    }
    
    //http://stackoverflow.com/questions/27386930/twilio-send-sms-in-swift-example
    @IBAction func sendButtonTouched(sender: UIButton) {
        if self.mobileIsValid(self.phoneTextField.text) && self.mobileIsValid(self.replyPhoneTextField.text){
            var fromMobileNumber = "".join(self.replyPhoneTextField.text.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
            var textID = PFObject(className: "TextID")
            textID.setObject(fromMobileNumber, forKey: "phone")
            
            textID.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    println("Object created with id: \(textID.objectId)")
                        var swiftRequest = SwiftRequest()
                        var data = [
                            "To" : self.phoneTextField.text!,
                            "From" : self.twilio_phone,
                            "Body" : self.messageTextView.text! + " - sent by MysteryNote.  To reply start text message with \(textID.objectId)"
                        ]
                    
                        swiftRequest.post("https://api.twilio.com/2010-04-01/Accounts/"+self.twilio_accountsid_LIVE+"/Messages",
                            auth: ["username" : self.twilio_accountsid_LIVE, "password" : self.twilio_authtoken_LIVE],
                            data: data,
                            callback: {err, response, body in
                                if err == nil {
                                    println("Success: \(response)")
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        self.messageTextView.text = self.defaultTextViewString
                                        self.resignFirstResponder()
                                        UIAlertView(title:"Sent!", message: "Your Message Was Sent!", delegate: nil, cancelButtonTitle: "Okay").show()
                                    })
                                }
                                else {
                                    println("Error: \(err)")
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        UIAlertView(title:"Error", message: "Could not send message", delegate: nil, cancelButtonTitle: "Okay").show()
                                    })
                                }
                        })
                }
                else {
                    println("Error: \(error)")
                }
            }
        }
        else{
            UIAlertView(title:"Error", message: "Could not send message", delegate: nil, cancelButtonTitle: "Okay").show()
        }
    }
    
    //http://stackoverflow.com/questions/13176083/validate-phone-number-ios
    func mobileIsValid(mobile: String) -> Bool{
        var mobileNumbers = "".join(mobile.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
        if count(mobileNumbers) != 10{
            return false
        }
        if mobileNumbers.substringToIndex(advance(mobileNumbers.startIndex,3))=="555"{
            return false
        }
        return true
    }
    
    func addKeyboardObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func addProgramObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadProgram", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveProgram", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        if self.messageTextView.isFirstResponder()||self.replyPhoneTextField.isFirstResponder(){
            UIView.animateWithDuration(NSTimeInterval(0.3), animations: { () -> Void in
                self.view.frame = CGRectMake(0,-self.view.frame.size.height*0.20 , self.view.frame.size.width, self.view.frame.size.height)
                self.keyboardIsShowing = true
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        if keyboardIsShowing {
            UIView.animateWithDuration(NSTimeInterval(0.3), animations: { () -> Void in
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                self.keyboardIsShowing = false
                })
        }
    }
    
    func dismissAll(){
        self.phoneTextField.resignFirstResponder()
        self.messageTextView.resignFirstResponder()
        self.replyPhoneTextField.resignFirstResponder()
    }
    
    func saveProgram(){
        NSUserDefaults.standardUserDefaults().setObject(self.phoneTextField.text, forKey: "toPhone")
        NSUserDefaults.standardUserDefaults().setObject(self.messageTextView.text, forKey: "message")
        NSUserDefaults.standardUserDefaults().setObject(self.replyPhoneTextField.text, forKey: "fromPhone")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func loadProgram(){
        if let toPhone = NSUserDefaults.standardUserDefaults().objectForKey("toPhone") as! String?{
            self.phoneTextField.text = toPhone
        }
        if let message = NSUserDefaults.standardUserDefaults().objectForKey("message") as! String?{
            self.messageTextView.text = message
        }
        if let fromPhone = NSUserDefaults.standardUserDefaults().objectForKey("fromPhone") as! String?{
            self.replyPhoneTextField.text = fromPhone
        }
    }
    
}
