//
//  KeyBoardTopBar.swift
//  EverythingForFish
//
//  Created by Fish Yu on 14-6-19.
//  Copyright (c) 2014年 yhl10000@gmail.com. All rights reserved.
//

import UIKit

class KeyBoardTopBar: NSObject {
    /** the toolbar. */
    var view : UIToolbar = UIToolbar(frame: CGRect(x: 0,y: 568,width: 320,height: 44))
    
    /** whether the toolbar is in a navigation control. */
    var isInNavigationController: Bool
    
    /** the hidden button . */
    var hiddenButtonItem: UIBarButtonItem;
    /** the space button. */
    var spaceButtonItem: UIBarButtonItem;
    
    var bShowing: Bool = false

    var currentInputView: UIView?
    
    init(){
        
        hiddenButtonItem = UIBarButtonItem();
        spaceButtonItem = UIBarButtonItem();
        isInNavigationController = true;
        bShowing = false;
        
        super.init()
        
    }
    
    /**
    * here has a bug in swift, so stupid
    *
    */
    func init_fix_swift_bug(){
        hiddenButtonItem = UIBarButtonItem(title:"结束编辑",
            style: UIBarButtonItemStyle.Bordered,
            target: self,
            action: "HiddenKeyBoard" )
        spaceButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,
            target: self,
            action: nil )
        
        
        var gcd : CommonData = CommonData();
        
        view.barStyle = UIBarStyle.Default;
        view.items = [spaceButtonItem,hiddenButtonItem];
        
    }
    /**
    * show the toolbar.
    *
    * @param textField the input which is binding to the keyboard.
    * @param keyBorardFrame the framk of hte keyboard
    * @param animationDuration
    * @return no return value.
    *
    * @see HiddenKeyBoard
    */
    func ShowBar(textField:UIView,  keyBorardFrame:CGRect, animationDuration:NSTimeInterval){
        
        if !view.superview  {
            var w:UIWindow = UIApplication.sharedApplication().keyWindow
            w.addSubview(view)
        }
        
        if bShowing {
            return;
        }
        currentInputView = textField;
        
        UIView.animateWithDuration(animationDuration,
            animations: {
                self.view.frame = CGRectMake(0, keyBorardFrame.origin.y-44, 320,  44);
                self.view.superview.bringSubviewToFront(self.view);
            })
        
        bShowing = true;
    }
    
    /**
    * hide the toolbar.
    *
    * @param animationDuration
    * @return no return value.
    *
    * @see ShowBar
    */
    func HiddenKeyBoard(animationDuration:NSTimeInterval){
        if !bShowing {
            return;
        }
        if !currentInputView   {
            currentInputView?.resignFirstResponder();
        }
        UIApplication.sharedApplication().sendAction("resignFirstResponder",
            to: nil,
            from: nil,
            forEvent: nil)
        UIView.animateWithDuration(animationDuration,
            animations: {
                self.view.frame = CGRectMake(0, 568, 320, 44);
            })
        bShowing = false;
    }
    
}
