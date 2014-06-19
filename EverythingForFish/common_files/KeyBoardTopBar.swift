//
//  KeyBoardTopBar.swift
//  EverythingForFish
//
//  Created by Fish Yu on 14-6-19.
//  Copyright (c) 2014年 yhl10000@gmail.com. All rights reserved.
//

import UIKit

class KeyBoardTopBar: NSObject {
    this line will cause error, just a test. fish will delete this line.
    /** the toolbar. */
   	var view: UIToolbar
    {
    get{
        return self.view
    }
    }
    
    /** whether the toolbar is in a navigation control. */
    var isInNavigationController: Bool
    {
    get{
        return self.isInNavigationController
    }
    set(newValue){
        self.isInNavigationController = newValue
    }
    }
    
    /** the hidden button . */
//    var hiddenButtonItem: UIBarButtonItem;
    /** the space button. */
 //   var spaceButtonItem: UIBarButtonItem;
    
    var bShowing: Bool = false;

    init(){
        super.init()
        
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
        
    }
    
}
