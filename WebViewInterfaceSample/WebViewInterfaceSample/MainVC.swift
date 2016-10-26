//
//  MainVC.swift
//  WebViewInterfaceSample
//
//  Created by OtisLee on 2016/10/26.
//  Copyright © 2016年 otis. All rights reserved.
//

import UIKit

class MainVC: UIViewController, ButtonPressing, WebViewInterface
{
    @IBOutlet var m_mainView: MainView!
    
    var m_webViewDelegate: WebViewDelegate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initView()
        
        self.m_webViewDelegate = WebViewDelegate(webView: self.m_mainView.m_webView, withWebViewInterface: self)
        
        //pageName:HTML full name(include .html), fromFolder:Folder name.
        self.m_webViewDelegate.loadPage("index.html", fromFolder: "index")
        
    }
    
    //MARK: Private Function
    
    func initView()
    {
        self.m_mainView.setButtonDelegate(self)
    }
    
    //MARK: ButtonPressing
    
    func didPressButton()
    {
        //withArgs: Because framework doesn't allow args with empty, so give it an object.
        self.m_webViewDelegate.callJSFunction("fromNative", withArgs: ["":""])
    }
    
    //MARK: WebViewInterface
    
    func processFunctionFromJS(name: String!, withArgs args: [AnyObject]!) throws -> AnyObject
    {
        if "callNative" == name
        {
            let alert = UIAlertController(title: "", message: "It's come from JavaScript", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        return ""
    }
}

