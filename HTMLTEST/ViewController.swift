//
//  ViewController.swift
//  HTMLTEST
//
//  Created by 谭钧豪 on 16/6/24.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var readingMode: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    //setting
    
    var readingTextView:UITextView!
    var curSize:CGFloat = 24
    var fontColor:UIColor!
    var textViewBackgroundColor:UIColor!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var colorSettingView: UIView!
    
    @IBOutlet weak var minFontButton: UIButton!
    @IBOutlet weak var addFontButton: UIButton!
    @IBOutlet weak var setColorButton: UIButton!
    
    
    @IBOutlet weak var colorSegment: UISegmentedControl!
    @IBAction func colorSegmentValueChange(sender: UISegmentedControl) {
        var oldColor:UIColor
        if sender.selectedSegmentIndex == 0{
            oldColor = colorSegment.tintColor
        }else{
            oldColor = colorSettingView.backgroundColor!
        }
        var color:[Float] = [0,0,0]
        getRGBComponents(&color, color: oldColor)
        redSlider.value = color[0]
        greenSlider.value = color[1]
        blueSlider.value = color[2]
    }
    
    @IBAction func colorConfirm(sender: AnyObject) {
        fontColor = colorSegment.tintColor
        textViewBackgroundColor = colorSettingView.backgroundColor!
        dispatch_async(dispatch_get_main_queue()) { 
            self.readingTextView.textColor = self.fontColor
            self.readingTextView.text = self.readingTextView.text
            self.readingTextView.backgroundColor = self.textViewBackgroundColor
            self.view.backgroundColor = self.textViewBackgroundColor
        }
        var font:[Float] = [0,0,0]
        var back:[Float] = [0,0,0]
        getRGBComponents(&font, color: fontColor)
        getRGBComponents(&back, color: textViewBackgroundColor)
        NSUserDefaults.standardUserDefaults().setValue(
            ["fontColor":font,"textViewBackgroundColor":back],
            forKey: "colorInfo"
        )
        colorSettingView.hidden = true
    }
    
    @IBAction func toSetColor(sender: AnyObject) {
        colorSettingView.hidden = !colorSettingView.hidden
        colorSettingView.backgroundColor = textViewBackgroundColor
        colorConfirmButton.setTitleColor(fontColor, forState: .Normal)
        colorSegment.tintColor = fontColor
    }
    
    @IBAction func nextCharpter(sender: AnyObject) {
        operateCharpter(1)
    }
    
    @IBAction func preCharpter(sender: UIButton) {
        operateCharpter(-1)
    }
    
    func operateCharpter(num:Int32){
        var urlstr = urlTextField.text!
        urlstr = urlstr.stringByReplacingOccurrencesOfString(".html", withString: "")
        ///http://sm.book.3g.cn/content/209420/3549.html
        var number = (urlstr.componentsSeparatedByString("/").last! as NSString).intValue
        number += num
        urlstr = urlstr.stringByReplacingOccurrencesOfString(urlstr.componentsSeparatedByString("/").last!, withString: "\(number).html")
        urlTextField.text! = urlstr
        openWebSite()
    }
    
    
    
    var htmlstr:String? = ""
    @IBOutlet weak var colorConfirmButton: UIButton!
    
    func colorChanged(){
        let red = CGFloat(redSlider.value)
        let green = CGFloat(greenSlider.value)
        let blue = CGFloat(blueSlider.value)
        if colorSegment.selectedSegmentIndex == 1{
            colorSettingView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        }else{
            colorConfirmButton.setTitleColor(UIColor(red: red, green: green, blue: blue, alpha: 1), forState: .Normal)
            colorSegment.tintColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
    }
    
    func getRGBComponents(inout components: [Float],color:UIColor){
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        var resultingPixel:[CUnsignedChar] = [0,0,0,0]
        
        let context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, CGImageAlphaInfo.NoneSkipLast.rawValue)
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillRect(context!, CGRectMake(0, 0, 1, 1))
        for component in 0..<3 {
            components[component] = Float(resultingPixel[component])/255
        }
    }
    
    func UIColorWithFloatArray(floats:[Float]) -> UIColor{
        return UIColor(red: CGFloat(floats[0]), green: CGFloat(floats[1]), blue: CGFloat(floats[2]), alpha: 1)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let colorInfo = NSUserDefaults.standardUserDefaults().valueForKey("colorInfo"){
            fontColor =  UIColorWithFloatArray((colorInfo as! NSDictionary)["fontColor"] as! [Float])
            textViewBackgroundColor =  UIColorWithFloatArray((colorInfo as! NSDictionary)["textViewBackgroundColor"] as! [Float])
        }else{
            fontColor = UIColor.blackColor()
            textViewBackgroundColor = UIColor.lightGrayColor()
        }
        
        if let fontSize = NSUserDefaults.standardUserDefaults().valueForKey("fontSize"){
            curSize = fontSize as! CGFloat
        }
        
        readingTextView = UITextView(frame: CGRectMake(8, urlTextField.frame.origin.y, 0, 0))
        readingTextView.editable = false
        readingTextView.font = UIFont.boldSystemFontOfSize(curSize)
        readingTextView.backgroundColor = textViewBackgroundColor
        readingTextView.textColor = fontColor
        colorSegment.tintColor = fontColor
        colorSettingView.backgroundColor = textViewBackgroundColor
        var components:[Float] = [0,0,0]
        getRGBComponents(&components, color: UIColor.redColor())
        redSlider.value = components[0]
        greenSlider.value = components[1]
        blueSlider.value = components[2]
        
        
        view.insertSubview(readingTextView, belowSubview: colorSettingView)
        urlButton.setTitle("转到", forState: UIControlState.Normal)
        urlButton.addTarget(self, action: #selector(self.openWebSite), forControlEvents: .TouchUpInside)
        readingMode.addTarget(self, action: #selector(self.readingModePress), forControlEvents: .TouchUpInside)
        addValueChangeAction(redSlider,greenSlider,blueSlider)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func addValueChangeAction(senders:UISlider...){
        for sender in senders{
            sender.addTarget(self, action: #selector(self.colorChanged), forControlEvents: .ValueChanged)
        }
    }
    
    func openWebSite(){
        urlTextField.resignFirstResponder()
        let urlstr = urlTextField.text!
        if let url = NSURL(string: urlstr){
            indicator.startAnimating()
            webViewToBottomConstraint.constant = 10
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    @IBAction func decreseFontSize(sender: AnyObject) {
        curSize -= 1
        readingTextView.font = UIFont.boldSystemFontOfSize(curSize)
        readingTextView.text = readingTextView.text
        NSUserDefaults.standardUserDefaults().setValue(curSize, forKey: "fontSize")
    }
    @IBAction func increaseFontSize(sender: AnyObject) {
        curSize += 1
        readingTextView.font = UIFont.boldSystemFontOfSize(curSize)
        readingTextView.text = readingTextView.text
        NSUserDefaults.standardUserDefaults().setValue(curSize, forKey: "fontSize")
    }
    
    
    @IBOutlet weak var webViewToBottomConstraint: NSLayoutConstraint!
    
    func readingModePress(sender:UIButton){
        if readingTextView.frame.size != CGSizeZero{
            sender.setTitle("3G书城小说模式", forState: .Normal)
            minFontButton.hidden = true
            addFontButton.hidden = true
            setColorButton.hidden = true
            UIView.animateWithDuration(0.2) {
                self.readingTextView.frame.size = CGSizeZero
            }
        }else{
            sender.setTitle("退出小说模式", forState: .Normal)
            minFontButton.hidden = false
            addFontButton.hidden = false
            setColorButton.hidden = false
            showhtmlstr()
            UIView.animateWithDuration(0.5) {
                self.readingTextView.frame.size = CGSizeMake(UIScreen.mainScreen().bounds.width-16, self.readingMode.frame.origin.y - self.urlTextField.frame.origin.y-10)
            }
        }
        
    }
    
    
    func showhtmlstr(){
        var title = ""
        if htmlstr!.containsString("Readtitle\">"){
            title = htmlstr!.componentsSeparatedByString("Readtitle\">")[1].componentsSeparatedByString("</p>")[0]
        }
        var content = "无法获取小说内容"
        if htmlstr!.containsString("Readarea ReadAjax_content\">"){
            content = htmlstr!.componentsSeparatedByString("Readarea ReadAjax_content\">")[1].componentsSeparatedByString("</div>")[0]
            content = content.stringByReplacingOccurrencesOfString("<p>", withString: "\n")
            content = content.stringByReplacingOccurrencesOfString("</p>", withString: "")
            
            content = deleteLabelByName("script", rawString: content)
            content = deleteBetween("<!--", second: "</ins></ins></ins>", rawString: content)
        }
        
        readingTextView.text = title+content
        readingTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        
    }
    
    /*
     *  labelName cound not be "K" or you can replace the marker character
     *  example labelName: "script"
     *  the labelName must be pair with <labelName></labelName> or <labelName><labelName> and unable nest
     */
    func deleteLabelByName(labelName:String,rawString:String) -> String{
        var content = rawString
        let markLabelName = (labelName as NSString).stringByReplacingCharactersInRange(NSMakeRange(0, 2), withString: "<K")
        while content.containsString(labelName){
            let range = (content as NSString).rangeOfString("<"+labelName)
            if range.location != NSNotFound{
                content = (content as NSString).stringByReplacingCharactersInRange(range, withString: markLabelName)
                let range2 = (content as NSString).rangeOfString(labelName+">")
                if range2.location != NSNotFound{
                    let deleteRange = NSRange.init(location: range.location, length: range2.location+range2.length-range.location)
                    content = (content as NSString).stringByReplacingCharactersInRange(deleteRange, withString: "")
                }
            }
        }
        return content
    }
    
    /*
     *  first should not equal to second
     *  some bug appeared
     */
    func deleteBetween(first:String,second:String,rawString:String) -> String{
        var content = rawString
        while content.containsString(first) && content.containsString(second){
            let range = (content as NSString).rangeOfString(first)
            if range.location != NSNotFound{
                let range2 = (content as NSString).rangeOfString(second)
                if range2.location != NSNotFound{
                    let deleteRange = NSRange.init(location: range.location, length: range2.location+range2.length-range.location)
                    content = (content as NSString).stringByReplacingCharactersInRange(deleteRange, withString: "")
                }
            }
        }
        return content
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        urlTextField.resignFirstResponder()
        for touch in touches{
            if touch.view == colorSettingView{
                
            }else{
                colorSettingView.hidden = true
            }
        }
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView.loading{
            return
        }
        indicator.stopAnimating()
        htmlstr = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.innerHTML")
        //我不是标题党。。。。然而的确用到了js 你瞧这不是么。。。还会有更多的。。先做一个小说的自个用下。
        showhtmlstr()
        //3G神马书城阅读
        if urlTextField.text!.containsString("sm.book.3g.cn/content/"){
            dispatch_async(dispatch_get_main_queue(), {
                if self.webViewToBottomConstraint.constant != 50{
                    self.webViewToBottomConstraint.constant = 50
                }
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

