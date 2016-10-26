//
//  MainView.swift
//  WebViewInterfaceSample
//
//  Created by OtisLee on 2016/10/26.
//  Copyright © 2016年 otis. All rights reserved.
//

import UIKit

protocol ButtonPressing: NSObjectProtocol
{
    func didPressButton()
}

class MainView: UIView
{
    @IBOutlet weak var m_webView: UIWebView!
    
    @IBOutlet weak var m_callJSButton: UIButton!
    
    var delegate: ButtonPressing?
    
    func setButtonDelegate(_delegate: ButtonPressing)
    {
        self.m_callJSButton.addTarget(_delegate, action: #selector(self.didPressButton), forControlEvents: .TouchUpInside)
    }
    
    override func awakeFromNib()
    {
        self.m_callJSButton.layer.borderWidth = 1
        self.m_callJSButton.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func didPressButton()
    {
        self.delegate?.didPressButton()
    }
}