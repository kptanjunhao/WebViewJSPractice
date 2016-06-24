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
    @IBOutlet weak var hideButton: UIButton!

    var readingTextView:UITextView!
    var curSize:CGFloat = 30
    
    var htmlstr:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readingTextView = UITextView(frame: CGRectMake(8, urlTextField.frame.origin.y, 0, 0))
        readingTextView.editable = false
        readingTextView.font = UIFont.boldSystemFontOfSize(curSize)
        view.addSubview(readingTextView)
        urlButton.setTitle("转到", forState: UIControlState.Normal)
        urlButton.addTarget(self, action: #selector(self.openWebSite), forControlEvents: .TouchUpInside)
        urlButton.addTarget(self, action: #selector(self.showhtmlstr), forControlEvents: .TouchDragExit)
        hideButton.addTarget(self, action: #selector(self.hideButtonPress), forControlEvents: .TouchUpInside)
        readingMode.addTarget(self, action: #selector(self.readingModePress), forControlEvents: .TouchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func openWebSite(){
        
        let urlstr = urlTextField.text!
        
        if let url = NSURL(string: urlstr){
            webView.loadRequest(NSURLRequest(URL: url))
        }
        
    }
    
    @IBAction func decreseFontSize(sender: AnyObject) {
        curSize -= 1
        readingTextView.font = UIFont.boldSystemFontOfSize(curSize)
    }
    @IBAction func increaseFontSize(sender: AnyObject) {
        curSize += 1
        readingTextView.font = UIFont.boldSystemFontOfSize(curSize)
    }
    
    
    @IBOutlet weak var webViewToBottomConstraint: NSLayoutConstraint!
    func hideButtonPress(){
        if readingTextView.frame.size != CGSizeZero{
            UIView.animateWithDuration(0.2) {
                self.readingTextView.frame.size = CGSizeZero
            }
        }else{
//            UIView.animateWithDuration(0.2) {
//                self.webViewToBottomConstraint.constant = 10
//            }
        }
    }
    
    func readingModePress(){
        showhtmlstr()
        UIView.animateWithDuration(0.5) { 
            self.readingTextView.frame.size = CGSizeMake(UIScreen.mainScreen().bounds.width-16, self.readingMode.frame.origin.y - self.urlTextField.frame.origin.y)
        }
        
    }
    
    
    func showhtmlstr(){
        let title = htmlstr!.componentsSeparatedByString("Readtitle\">")[1].componentsSeparatedByString("</p>")[0]
        var content = htmlstr!.componentsSeparatedByString("Readarea ReadAjax_content\">")[1].componentsSeparatedByString("</div>")[0]
        content = content.stringByReplacingOccurrencesOfString("<p>", withString: "\n")
        content = content.stringByReplacingOccurrencesOfString("</p>", withString: "")
        
        content = deleteLabelByName("script", rawString: content)
        content = deleteBetween("<!--", second: "</ins></ins></ins>", rawString: content)
        
        readingTextView.text = content
        
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
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        webViewToBottomConstraint.constant = 10
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        htmlstr = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.innerHTML")
        //3G神马书城阅读
        if urlTextField.text!.containsString("sm.book.3g.cn/content/"){
            webViewToBottomConstraint.constant = 50
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

