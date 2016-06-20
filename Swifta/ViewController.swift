//
//  ViewController.swift
//  Swifta
//
//  Created by Clarence Westberg on 6/14/16.
//  Copyright © 2016 Clarence Westberg. All rights reserved.
//

import UIKit
import MessageUI
import GameController

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var omLbl: UILabel!
    @IBOutlet weak var ctcLbl: UILabel!
    @IBOutlet weak var todLbl: UILabel!
    @IBOutlet weak var deltaLbl: UILabel!
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var nextSpeedLbl: UILabel!
    @IBOutlet weak var pgtaLbl: UILabel!
    @IBOutlet weak var computedTimeLbl: UILabel!
    @IBOutlet weak var outTimeLbl: UILabel!
    @IBOutlet weak var distanceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pgtaValueSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pgtaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var unitsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var speedStepper: UIStepper!
    @IBOutlet weak var timeAdjustStepper: UIStepper!
    @IBOutlet weak var timeAdjustStepperLabel: UILabel!
    @IBOutlet weak var computedDistanceLbl: UILabel!
    @IBOutlet weak var outTimeStepper: UIStepper!
    
    @IBOutlet weak var minusTenthBtn: UIButton!
    @IBOutlet weak var plus01btn: UIButton!
    @IBOutlet weak var minus01btn: UIButton!
    @IBOutlet weak var plus001btn: UIButton!
    @IBOutlet weak var minus001btn: UIButton!
    
    var om = 0.00
    var startOm = 0.0
    var ctc = NSDate()
    var computedTime = 0.0
    var computedDistance = 0.0
    var tod = NSDate()
    var outTime = NSDate()
    var pgta = 0.0
    var speed = 36.0
    var nextSpeed = 36.0
    var timeUnit = "seconds"
    var delta = 0.0
    var lastCalcOm = 0.0
    var lastCalcTime = NSDate()
    var pauses = 0.0
    var items: [String] = []
    var outTimeStepperValue = 0.0

    
//    let tapRec = UITapGestureRecognizer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        distanceSegmentedControl.selectedSegmentIndex = 1
        pgtaValueSegmentedControl.selectedSegmentIndex = 1
        speedLbl.text = "\(Int(speedStepper.value))"
        nextSpeedLbl.text = "\(Int(speedStepper.value))"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.controllerDidConnect(_:)), name: "GCControllerDidConnectNotification", object: nil)
        
        minusTenthBtn.layer.borderColor = UIColor.blueColor().CGColor
        minusTenthBtn.layer.borderWidth = 1
        minusTenthBtn.layer.cornerRadius = 20
        plus01btn.layer.borderColor = UIColor.blueColor().CGColor
        plus01btn.layer.borderWidth = 1
        plus01btn.layer.cornerRadius = 20
        minus01btn.layer.borderColor = UIColor.blueColor().CGColor
        minus01btn.layer.borderWidth = 1
        minus01btn.layer.cornerRadius = 20
        plus001btn.layer.borderColor = UIColor.blueColor().CGColor
        plus001btn.layer.borderWidth = 1
        plus001btn.layer.cornerRadius = 20
        minus001btn.layer.borderColor = UIColor.blueColor().CGColor
        minus001btn.layer.borderWidth = 1
        minus001btn.layer.cornerRadius = 20


//        tapRec.addTarget(self, action: #selector(ViewController.tappedView))
//        self.view.addGestureRecognizer(tapRec)
//        self.view.userInteractionEnabled = true


        _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self,
                                                   selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)
        self.nextMinuteBtn(self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tappedView() {
        plusOmBtn(self)
    }
    
//    Updating
    func updateTimeLabel() {
        tod = NSDate()
        let secondsToAdd = (timeAdjustStepper.value * 0.1)
        tod = tod.dateByAddingTimeInterval(Double(secondsToAdd))
        
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: currentDate)
        
        let millisecond = Int(Double(dateComponents.nanosecond)/1000000)
        let mytime = dateComponents.second * 1000 + millisecond
        let cents = trunc((Double(mytime) * 1.66667)/1000)
        
        let unit = Double(dateComponents.second)
        let second = Int(unit)
        let secondString = String(format: "%02d", second)
        
        let centString = String(format: "%02d", Int(cents))
        let minuteString = String(format: "%02d", dateComponents.minute)
        switch timeUnit {
        case "seconds":
            todLbl.text = "\(dateComponents.hour):\(minuteString):\(secondString)"
        case "cents":
            todLbl.text = "\(dateComponents.hour):\(minuteString).\(centString)"
        default:
            break;
        }
        
        calcComputedDistance()

    }
    
    func calcComputedDistance(){
        computedDistance += (tod.timeIntervalSinceDate(lastCalcTime)/3600 * speed)
        lastCalcTime = tod
        computedDistance = (computedDistance - (pauses/36 * speed))
        pauses = 0
        computedDistanceLbl.text = String(format: "%0.3f", computedDistance)
    }
    func computedDistanceChange() {
        lastCalcTime = ctc
        computedDistance = 0.00
    }
    func computedDistanceCast(distance: Double) {
        lastCalcTime = ctc
        computedDistance = distance
    }
    
    func updateDelta() {
        let ti = Int(round(tod.timeIntervalSinceDate(self.ctc)))
        
        let interval = ctc.timeIntervalSinceDate(self.tod)
        var sign = "+"
        if interval < 0.0 {
            sign = "-"
        }
        
        let minutes = abs((ti / 60) % 60)
        switch timeUnit {
        case "seconds":
            if interval > 0.0 {
                var secs = abs(Int((interval % 60)))
                if secs == 60 {
                    secs = 0
                }
                deltaLbl.text = NSString(format: "\(sign)%0.2d:%0.2d",minutes,secs) as String
            }
            if interval <=  0.1 {
                var secs = abs(Int((interval % 60) ))
                if secs == 60 {
                    secs = 0
                }
                deltaLbl.text = NSString(format: "\(sign)%0.2d:%0.2d",minutes,secs) as String
            }
            
            
        case "cents":
            if interval > 0.0 {
                let cents = (interval % 60.0) * 1.6667
                var cs = abs(Int(cents))

                if cs == 100 {
                    cs = 0
                }
                deltaLbl.text = NSString(format: "\(sign)%0.2d.%0.2d",minutes,cs) as String
            }
            if interval <=  0.1 {
                let cents = (interval % 60.0) * 1.6667
                var cs = abs(Int(cents - 1.0))
                
                if cs == 100 {
                    cs = 0
                }
                deltaLbl.text = NSString(format: "\(sign)%0.2d.%0.2d",minutes,cs) as String
            }

        default:
            break;
        }
    }
    
//   Computing
    
    func computeTime() {
        computedTime += (60.0/speed) * (om - lastCalcOm)
        lastCalcOm = om
        computedTimeLbl.text = String(format: "%0.4f", computedTime)
        
        let minutesToAdd = trunc(computedTime)
        var secondsToAdd = minutesToAdd * 60
        secondsToAdd += ((computedTime % 1.0) * 0.6) * 100
        let units = computedTime % 1.0 * 1000
        
        let ctcTime = self.outTime.dateByAddingTimeInterval(Double(secondsToAdd))
        let calendar = NSCalendar.currentCalendar()

        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: ctcTime)
        
        let minStr = String(format: "%02d", dateComponents.minute)
        if timeUnit == "cents" {
//            let centStr = String(format: "%02d", Int((Double(dateComponents.second) * 1.66667)))
            let centStr = String(format: "%03d", Int(units))
            self.ctcLbl.text = "\(dateComponents.hour):\(minStr).\(centStr)"
        } else {
//            let secStr = String(format: "%02d", dateComponents.second)
            let secStr = String(format: "%03d",Int(units * 0.6))
            self.ctcLbl.text = "\(dateComponents.hour):\(minStr):\(secStr)"
        }
        ctc = ctcTime
        updateDelta()
    }
//    outTime
    @IBAction func outTimeStepper(sender: AnyObject) {
        if outTimeStepper.value > outTimeStepperValue {
            nextMinuteBtn(self)
        }
        else if outTimeStepper.value < outTimeStepperValue {
            prevMinuteBtn(self)
        }
        outTimeStepperValue = 0.0
        outTimeStepper.value = 0.0


    }

    @IBAction func nextMinuteBtn(sender: AnyObject) {
        roundStartDateToNextMinute()
        computeTime()
        computedDistanceChange()
    }
    
    @IBAction func prevMinuteBtn(sender: AnyObject) {
        roundDownStartDateToNextMinute()
        computeTime()
        computedDistanceChange()
    }
    @IBAction func splitBtn(sender: AnyObject) {
        computeTime()
        updateDelta()
    }
    
    func roundStartDateToNextMinute(){
        let calendar = NSCalendar.currentCalendar()
        var dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: self.outTime)
        let secondsToAdd = 60 - dateComponents.second
        let timePlusOneMinute = self.outTime.dateByAddingTimeInterval(Double(secondsToAdd))
        dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: timePlusOneMinute)
        
        let minStr = String(format: "%02d", dateComponents.minute)
        let secStr = "00"
        self.outTimeLbl.text = "\(dateComponents.hour):\(minStr):\(secStr)"
        self.outTime = timePlusOneMinute
    }
    func roundDownStartDateToNextMinute(){
        let calendar = NSCalendar.currentCalendar()
        var dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: self.outTime)
        let secondsToAdd = -60 - dateComponents.second
        let timePlusOneMinute = self.outTime.dateByAddingTimeInterval(Double(secondsToAdd))
        dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: timePlusOneMinute)
        
        let minStr = String(format: "%02d", dateComponents.minute)
        let secStr = "00"
        self.outTimeLbl.text = "\(dateComponents.hour):\(minStr):\(secStr)"
        self.outTime = timePlusOneMinute
    }
    
// OM Actions
    
    @IBAction func areaBtn(sender: AnyObject) {
        tappedView()
    }
    func decrementOM (value: Double) {
        if om > 0.0 {
            om -= value
        }
        if om < 0.0 {
            om = 0.0
        }
    }
    @IBAction func minusTenthBtn(sender: AnyObject) {
        decrementOM(0.1)
        updateOmLbl()
        computeTime()
    }
    @IBAction func plus01Btn(sender: AnyObject) {
        om += 0.01
        updateOmLbl()
        computeTime()
    }
    @IBAction func minus01Btn(sender: AnyObject) {
        decrementOM(0.01)
        updateOmLbl()
        computeTime()
    }
    @IBAction func plus001Btn(sender: AnyObject) {
        om += 0.001
        updateOmLbl()
        computeTime()
    }
    @IBAction func minus001Btn(sender: AnyObject) {
        decrementOM(0.001)
        updateOmLbl()
        computeTime()
    }
    
    @IBAction func plusOmBtn(sender: AnyObject) {
        switch distanceSegmentedControl.selectedSegmentIndex {
        case 0:
            om += 1.0
        case 1:
            om += 0.1
        case 2:
            om += 0.01
        case 3:
            om += 0.001
        default:
            break;
        }
        updateOmLbl()
        computeTime()
    }

    @IBAction func minusOmBtn(sender: AnyObject) {
        switch distanceSegmentedControl.selectedSegmentIndex {
        case 0:
            decrementOM(1.0)
        case 1:
            decrementOM(0.1)
        case 2:
            decrementOM(0.01)
        case 3:
            decrementOM(0.001)
        default:
            break;
        }
        updateOmLbl()
        computeTime()
    }
    @IBAction func zeroOmBtn(sender: AnyObject) {
        om = 0.0
        updateOmLbl()
        lastCalcOm = 0.00
        computedTime = 0.0
        computedTimeLbl.text = String(format: "%0.4f", computedTime)
        self.splitBtn(self)
    }
    
    func updateOmLbl(){
        omLbl.text = String(format: "%0.3f", om)
    }

//    Speed Actions
    @IBAction func speedStepper(sender: AnyObject) {
        nextSpeed = speedStepper.value
        nextSpeedLbl.text = "\(Int(speedStepper.value))"
    }
    
    @IBAction func castBtn(sender: AnyObject) {
        speed = nextSpeed
        speedLbl.text = "\(Int(speedStepper.value))"
        self.items.insert("CAST \(speed) @ \(om) ctc \(String(format: "%0.4f", computedTime))",  atIndex:0)
        self.tableView.reloadData()
        computedDistanceCast(om)
        self.splitBtn(self)
    }
    
//    Pause Gain TA Actions
    
    @IBAction func pgtaMinus(sender: AnyObject) {
        var value = 0.0
        switch pgtaValueSegmentedControl.selectedSegmentIndex {
        case 0:
            value = -1.0
        case 1:
            value = -0.1
        case 2:
            value = -0.05
        case 3:
            value = -0.01
        default:
            break;
        }

        doPGTA(value)
    }
    
    @IBAction func pgtaPlus(sender: AnyObject) {
        var value = 0.0
        switch pgtaValueSegmentedControl.selectedSegmentIndex {
        case 0:
            value = +1.0
        case 1:
            value = +0.1
        case 2:
            value = +0.05
        case 3:
            value = +0.01
        default:
            break;
        }
        
        doPGTA(value)
    }
    
    func doPGTA(value: Double) {
        var logString = "PGTA"
        switch pgtaSegmentedControl.selectedSegmentIndex {
        case 0:
            computedTime += value
            pgta += value
            logString = "Pause"
        case 1:
            computedTime -= value
            pgta -= value
            logString = "Gain"
        case 2:
            computedTime += value
            pgta += value
            logString = "TA"
        default:
            break;
        }
        computeTime()
        pgtaLbl.text = String(format: "%0.2f", pgta)
        self.items.insert("\(logString) \(value) @ \(om)", atIndex:0)
        self.tableView.reloadData()
        pauses += value

    }
    
    @IBAction func clearPGTABtn(sender: AnyObject) {
        pgta = 0.0
        pgtaLbl.text = String(format: "%0.2f", pgta)

    }
    
    
// Table
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    // End Table
    
//    Preferences & Share
    
    @IBAction func stepperAction(sender: AnyObject) {
        timeAdjustStepperLabel.text = "\(Int(timeAdjustStepper.value))"
    }
    
    @IBAction func secondsOrCents(sender:UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            timeUnit = "seconds"
        case 1:
            timeUnit = "cents"
        default:
            break;
        }
        splitBtn(self)
    }
    
    @IBAction func share(sender: AnyObject){
        let mailString = NSMutableString()
        
        for item in self.items {
            mailString.appendString("\(item)\n")
        }
        
        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        // Unwrapping the optional.
        if let content = data {
            print("NSData: \(content)")
        }
        
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        emailController.setSubject("CSV File")
        emailController.setMessageBody("", isHTML: false)
        
        // Attaching the .CSV file to the email.
        emailController.addAttachmentData(data!, mimeType: "text/csv", fileName: "Swifta Log")
        
        // If the view controller can send the email.
        // This will show an email-style popup that allows you to enter
        // Who to send the email to, the subject, the cc's and the message.
        // As the .CSV is already attached, you can simply add an email
        // and press send.
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(emailController, animated: true, completion: nil)
        }
        
        
    }
    // Delegate requirement
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    Game Controller
    
    func controllerDidConnect(notification: NSNotification) {
        
        let controller = notification.object as! GCController
        print("controller is \(controller)")
        print("game on ")
        
        controller.gamepad?.dpad.up.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.up")
                self.plusOmBtn(self)
            }
        }
        
        controller.gamepad?.dpad.down.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed && value > 0.2  {
                print("dpad.down")
                self.minusOmBtn(self)
            }
        }
        
        controller.gamepad?.dpad.left.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.left")

            }
        }
        
        controller.gamepad?.dpad.right.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed && value > 0.2  {
                print("dpad.right")

            }
        }
        
        controller.gamepad?.buttonA.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonA")
                self.zeroOmBtn(self)
            }
        }
        controller.gamepad?.buttonB.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonB")
//                self.nextMinuteBtn(self)
                
            }
        }
        
        controller.gamepad?.buttonY.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonY")
            }
        }
        
        
        controller.gamepad?.buttonX.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonX")
            }
        }
        controller.gamepad?.rightShoulder.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("rightShoulder")
                self.splitBtn(self)
            }
        }
    }
    
}

