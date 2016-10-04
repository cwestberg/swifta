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

extension Double {
    /// Rounds the double to decimal places value
//    mutating func roundToPlaces(places:Int) -> Double {
//        let divisor = pow(10.0, Double(places))
//        return round((self * divisor) / divisor)
//    }
}
extension String {
    var doubleValue: Double? {
        return Double(self)
    }
    var floatValue: Float? {
        return Float(self)
    }
    var integerValue: Int? {
        return Int(self)
    }
}
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

    
    let tapRec = UITapGestureRecognizer()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        distanceSegmentedControl.selectedSegmentIndex = 1
        pgtaValueSegmentedControl.selectedSegmentIndex = 1
        speedLbl.text = "\(speedStepper.value)"
//        speedLbl.text = "\(Int(speedStepper.value))"
        nextSpeedLbl.text = "\(Int(speedStepper.value))"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
//        NotificationCenter.default().addObserver(self, selector: #selector), name: "GCControllerDidConnectNotification", object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(ViewController.controllerDidConnect), name: NSNotification.Name(rawValue: "GCControllerDidConnectNotification"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.controllerDidConnect), name: "GCControllerDidConnectNotification" as NSNotification.Name, object: nil)
       
        
        minusTenthBtn.layer.borderColor = UIColor.blue.cgColor
        minusTenthBtn.layer.borderWidth = 1
        minusTenthBtn.layer.cornerRadius = 20
        plus01btn.layer.borderColor = UIColor.blue.cgColor
        plus01btn.layer.borderWidth = 1
        plus01btn.layer.cornerRadius = 20
        minus01btn.layer.borderColor = UIColor.blue.cgColor
        minus01btn.layer.borderWidth = 1
        minus01btn.layer.cornerRadius = 20
        plus001btn.layer.borderColor = UIColor.blue.cgColor
        plus001btn.layer.borderWidth = 1
        plus001btn.layer.cornerRadius = 20
        minus001btn.layer.borderColor = UIColor.blue.cgColor
        minus001btn.layer.borderWidth = 1
        minus001btn.layer.cornerRadius = 20


        tapRec.addTarget(self, action: #selector(ViewController.tappedView))
        self.view.addGestureRecognizer(tapRec)
        self.view.isUserInteractionEnabled = true


        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                   selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)
        self.nextMinuteBtn(sender: self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tappedView() {
        splitBtn(sender: self)
    }
    
//    Updating
    func updateTimeLabel() {
        tod = NSDate()
        let secondsToAdd = (timeAdjustStepper.value * 0.1)
        tod = tod.addingTimeInterval(Double(secondsToAdd))
        
        let currentDate = NSDate()
        let calendar = Calendar.current
//        let dateComponents = calendar.components([Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.weekOfYear, Calendar.Unit.hour, Calendar.Unit.minute, Calendar.Unit.second, Calendar.Unit.nanosecond], from: currentDate as Date)
        
        let dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: currentDate as Date)
        
        let millisecond = Int(Double(dateComponents.nanosecond!)/1000000)
        let mytime = dateComponents.second! * 1000 + millisecond
        let cents = trunc((Double(mytime) * 1.66667)/1000)
        
        let unit = Double(dateComponents.second!)
        let second = Int(unit)
        let secondString = String(format: "%02d", second)
        
        let centString = String(format: "%02d", Int(cents))
        let minuteString = String(format: "%02d", dateComponents.minute!)
        switch timeUnit {
        case "seconds":
            todLbl.text = "\(dateComponents.hour!):\(minuteString):\(secondString)"
        case "cents":
            todLbl.text = "\(dateComponents.hour!):\(minuteString).\(centString)"
        default:
            break;
        }
        
        calcComputedDistance()
        
        let interval = outTime.timeIntervalSince(self.tod as Date)
        if interval > 0 {
            let calendar = Calendar.current
//            let datecomponenets = calendar.components(Calendar.Unit.second, from: tod as Date, to: outTime as Date)
            let datecomponenets = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: outTime as Date)

            let seconds = datecomponenets.second
            print("Seconds: \(seconds!) \(Int(Double(seconds!)/60.0)) \(60 - (second % 60)) \(interval)")
            if interval > 0.9 {
//                TODO zero pad secs
                let secondString = String(format: "%02d", 60 - second)
                deltaLbl.text = "in \(Int(Double(interval)/60.0)):\(secondString)"
//                deltaLbl.text = "in \(Int(Double(seconds!)/60.0)):\(secondString)"
            }
            else {
                deltaLbl.text = "Go!"
            }
        }


    }
    
    func calcComputedDistance(){
        computedDistance += (tod.timeIntervalSince(lastCalcTime as Date)/3600 * speed)
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
        let ti = Int(round(tod.timeIntervalSince(self.ctc as Date)))
        
        let interval = ctc.timeIntervalSince(self.tod as Date)
        var sign = "+"
        if interval < 0.0 {
            sign = "-"
        }
        
        let minutes = abs((ti / 60) % 60)
        switch timeUnit {
        case "seconds":
            if interval > 0.0 {
                var secs = abs(Int((interval .truncatingRemainder(dividingBy: 60) )))
                if secs == 60 {
                    secs = 0
                }
                deltaLbl.text = NSString(format: "\(sign)%0.2d:%0.2d" as NSString,minutes,secs) as String
            }
            if interval <=  0.1 {
                var secs = abs(Int((interval .truncatingRemainder(dividingBy: 60)) ))
                if secs == 60 {
                    secs = 0
                }
                deltaLbl.text = NSString(format: "\(sign)%0.2d:%0.2d" as NSString,minutes,secs) as String
            }
            
            
        case "cents":
            if interval > 0.0 {
                let cents = (interval .truncatingRemainder(dividingBy: 60)) * 1.6667
                var cs = abs(Int(cents))

                if cs == 100 {
                    cs = 0
                }
                deltaLbl.text = NSString(format: "\(sign)%0.2d.%0.2d" as NSString,minutes,cs) as String
            }
            if interval <=  0.1 {
                let cents = (interval.truncatingRemainder(dividingBy: 60)) * 1.6667
                var cs = abs(Int(cents - 1.0))
                
                if cs == 100 {
                    cs = 0
                }
                deltaLbl.text = NSString(format: "\(sign)%0.2d.%0.2d" as NSString,minutes,cs) as String
            }

        default:
            break;
        }
    }
    
//   Computing
    
    func computeTime() {
        computedTime += (60.0/speed) * (om - lastCalcOm)
        print("computedTime \(computedTime)")
        lastCalcOm = om
        computedTimeLbl.text = String(format: "%0.4f", computedTime)
        
        let minutesToAdd = trunc(computedTime)
        var secondsToAdd = minutesToAdd * 60
        secondsToAdd += ((computedTime .truncatingRemainder(dividingBy: 1.0)) * 0.6) * 100
        var units = computedTime .truncatingRemainder(dividingBy: 1.0) * 1000
        
        let ctcTime = self.outTime.addingTimeInterval(Double(secondsToAdd))
        let calendar = Calendar.current

//        let dateComponents = calendar.components([Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.weekOfYear, Calendar.Unit.hour, Calendar.Unit.minute, Calendar.Unit.second, Calendar.Unit.nanosecond], from: ctcTime as Date)
        
        let dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: ctcTime as Date)
        
        let minStr = String(format: "%02d", dateComponents.minute!)
        if units < 0.0 {
            units = units + 1000.01
            print("units \(units) secs \(units * 0.6)")
        }
        if isCents() {
//            let centStr = String(format: "%02d", Int((Double(dateComponents.second) * 1.66667)))

            let centStr = String(format: "%03d", Int(units))
            self.ctcLbl.text = "\(dateComponents.hour!):\(minStr).\(centStr)"
        } else {
//            let secStr = String(format: "%02d", dateComponents.second)
            let secStr = String(format: "%03d",Int(units * 0.6))
            self.ctcLbl.text = "\(dateComponents.hour!):\(minStr):\(secStr)"
        }
        ctc = ctcTime
        updateDelta()
    }
//    outTime
    @IBAction func outTimeStepper(sender: AnyObject) {
        if outTimeStepper.value > outTimeStepperValue {
            nextMinuteBtn(sender: self)
        }
        else if outTimeStepper.value < outTimeStepperValue {
            prevMinuteBtn(sender: self)
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
    
    @IBAction func nowBtn(_ sender: AnyObject) {
        zeroOmBtn(sender: self)
        roundStartDateToNextMinuteNow()
        computeTime()
        computedDistanceChange()
        outTimeStepperValue = 0.0
        outTimeStepper.value = 0.0
    }
    
    
    func roundStartDateToNextMinute(){
        let calendar = Calendar.current
//        var dateComponents = calendar.components([Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.weekOfYear, Calendar.Unit.hour, Calendar.Unit.minute, Calendar.Unit.second, Calendar.Unit.nanosecond], from: self.outTime as Date)
        
        var dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: self.outTime as Date)

        let secondsToAdd = 60 - dateComponents.second!
        let timePlusOneMinute = self.outTime.addingTimeInterval(Double(secondsToAdd))
//        dateComponents = calendar.components([Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.weekOfYear, Calendar.Unit.hour, Calendar.Unit.minute, Calendar.Unit.second, Calendar.Unit.nanosecond], from: timePlusOneMinute as Date)
        
        dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: timePlusOneMinute as Date)
        
        let minStr = String(format: "%02d", dateComponents.minute!)
        let secStr = "00"
        self.outTimeLbl.text = "\(dateComponents.hour!):\(minStr):\(secStr)"
        self.outTime = timePlusOneMinute
    }
    func roundDownStartDateToNextMinute(){
        let calendar = Calendar.current
//        var dateComponents = calendar.components([Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.weekOfYear, Calendar.Unit.hour, Calendar.Unit.minute, Calendar.Unit.second, Calendar.Unit.nanosecond], from: self.outTime as Date)
        var dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: self.outTime as Date)
        let secondsToAdd = -60 - dateComponents.second!
        let timePlusOneMinute = self.outTime.addingTimeInterval(Double(secondsToAdd))
//        dateComponents = calendar.components([Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.weekOfYear, Calendar.Unit.hour, Calendar.Unit.minute, Calendar.Unit.second, Calendar.Unit.nanosecond], from: timePlusOneMinute as Date)
        dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: timePlusOneMinute as Date)
        
        let minStr = String(format: "%02d", dateComponents.minute!)
        let secStr = "00"
        self.outTimeLbl.text = "\(dateComponents.hour!):\(minStr):\(secStr)"
        self.outTime = timePlusOneMinute
    }
    
    func roundStartDateToNextMinuteNow(){
        let calendar = Calendar.current
//        var dateComponents = calendar.components([Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.weekOfYear, Calendar.Unit.hour, Calendar.Unit.minute, Calendar.Unit.second, Calendar.Unit.nanosecond], from: Date())
        var dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: Date())

        let secondsToAdd = 60 - dateComponents.second!
        let timePlusOneMinute = Date().addingTimeInterval(Double(secondsToAdd))
//        dateComponents = calendar.components([Calendar.Unit.day, Calendar.Unit.month, Calendar.Unit.year, Calendar.Unit.weekOfYear, Calendar.Unit.hour, Calendar.Unit.minute, Calendar.Unit.second, Calendar.Unit.nanosecond], from: timePlusOneMinute as Date)
        dateComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: timePlusOneMinute as Date)
        
        let minStr = String(format: "%02d", dateComponents.minute!)
        let secStr = "00"
        self.outTimeLbl.text = "\(dateComponents.hour!):\(minStr):\(secStr)"
        self.outTime = timePlusOneMinute as NSDate
    }
// OM Actions
    func roundToPlaces(value: Double, decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return round(value * divisor) / divisor
    }
    @IBAction func roundUpBtn(_ sender: AnyObject) {
        print("RoundUp \(computedDistance) \(om)")
        if computedDistance > om {
            om = roundToPlaces(value: computedDistance,decimalPlaces: 1)

            print(om)
            updateOmLbl()
            computeTime()
        }
    }
    @IBAction func areaBtn(_ sender: AnyObject) {
//        plusOmBtn(sender: self)
//        self.roundUpBtn(self)
        plusOmBtn(sender: AnyObject.self as AnyObject)

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
        decrementOM(value: 0.1)
        updateOmLbl()
        computeTime()
    }
    @IBAction func plus01Btn(sender: AnyObject) {
        om += 0.01
        updateOmLbl()
        computeTime()
    }
    
    @IBAction func plus05Btn(_ sender: AnyObject) {
        om += 0.05
        updateOmLbl()
        computeTime()
    }
    @IBAction func plus025Btn(_ sender: AnyObject) {
        om += 0.025
        updateOmLbl()
        computeTime()
    }
    @IBAction func minus01Btn(sender: AnyObject) {
        decrementOM(value: 0.01)
        updateOmLbl()
        computeTime()
    }
    @IBAction func plus001Btn(sender: AnyObject) {
        om += 0.001
        updateOmLbl()
        computeTime()
    }
    @IBAction func minus001Btn(sender: AnyObject) {
        decrementOM(value: 0.001)
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
        case 4:
            om += 0.05
        case 5:
            om += 0.025
        default:
            break;
        }
        updateOmLbl()
        computeTime()
    }

    @IBAction func minusOmBtn(_ sender: AnyObject) {
        switch distanceSegmentedControl.selectedSegmentIndex {
        case 0:
            decrementOM(value: 1.0)
        case 1:
            decrementOM(value: 0.1)
        case 2:
            decrementOM(value: 0.01)
        case 3:
            decrementOM(value: 0.001)
        case 4:
            decrementOM(value: 0.05)
        case 5:
            decrementOM(value: 0.025)
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
        self.splitBtn(sender: self)
    }
    
    func updateOmLbl(){
        omLbl.text = String(format: "%0.3f", om)
    }

//    Speed Actions
    @IBAction func speedStepper(sender: AnyObject) {
        nextSpeed = speedStepper.value
        nextSpeedLbl.text = "\(speedStepper.value)"
//        nextSpeedLbl.text = "\(Int(speedStepper.value))"
    }
    
    @IBAction func castBtn(sender: AnyObject) {
        speed = nextSpeed
        speedLbl.text = "\(nextSpeed)"
//        speedLbl.text = "\(speedStepper.value)"
//        speedLbl.text = "\(Int(speedStepper.value))"
        self.items.insert("CAST \(speed) @ \(om) ctc \(String(format: "%0.4f", computedTime))",  at:0)
        self.tableView.reloadData()
        computedDistanceCast(distance: om)
        self.splitBtn(sender: self)
//        let delayTime = DispatchTime.now() + .seconds(1)
//        DispatchQueue.main.after(when: delayTime) {
//            self.roundUpBtn(self)
//        }
    }
    
    

    @IBAction func customSpeedBtn(_ sender: AnyObject) {
//        var speedTextField: UITextField?
        let alertController = UIAlertController(title: "UIAlertController", message: "UIAlertController With TextField", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
//            print("Ok Button Pressed")
            let textField = alertController.textFields![0] as UITextField
            
            if let value = textField.text?.doubleValue  {
                print(value)
            } else {
//                print("invalid input")
                return
            }
            
            self.nextSpeedLbl.text = textField.text
            self.nextSpeed = (textField.text! as NSString).doubleValue
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel Button Pressed")
        }
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextField { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.decimalPad
//            textField.text = self.speedLbl.text
            textField.placeholder = "Enter Next Speed"
        }
        present(alertController, animated: true, completion: nil)
    }

    
    func isSeconds () -> Bool {
        return timeUnit == "seconds"
    }
    func isCents () -> Bool {
        return timeUnit == "cents"
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

        doPGTA(aValue: value)
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
        
        doPGTA(aValue: value)
    }
    
    func doPGTA(aValue: Double) {
        var value = aValue
        if isSeconds() {
            value = value * (1.666667)
        }
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
        self.items.insert("\(logString) \(value) @ \(om)",at:0)
        self.tableView.reloadData()
        pauses += value

    }
    
    @IBAction func clearPGTABtn(sender: AnyObject) {
        pgta = 0.0
        pgtaLbl.text = String(format: "%0.2f", pgta)
    }
    
    
// Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
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
        splitBtn(sender: self)
    }
    
    @IBAction func share(sender: AnyObject){
        let mailString = NSMutableString()
        
        for item in self.items {
            mailString.append("\(item)\n")
        }
        
        let data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
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
            self.present(emailController, animated: true, completion: nil)
        }
        
        
    }
    // Delegate requirement
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
//    Game Controller
    
    func controllerDidConnect(notification: NSNotification) {
        
        let controller = notification.object as! GCController
        print("controller is \(controller)")
        print("game on ")
        
        controller.gamepad?.dpad.up.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed  && value > 0.2 {
                print("dpad.up")
                self.plusOmBtn(sender: self)
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
                self.zeroOmBtn(sender: self)
            }
        }
        controller.gamepad?.buttonB.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("buttonB")
                
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
                self.splitBtn(sender: self)
            }
        }
        controller.gamepad?.leftShoulder.pressedChangedHandler = { (element: GCControllerElement, value: Float, pressed: Bool) in
            if pressed {
                print("leftShoulder")
                self.roundUpBtn(self)
            }
        }
    }
    
}

