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
   	var view: UIToolbar
    {
    get{
<<<<<<< HEAD
        return self.view hehehe
        abc
=======
        return self.view here will caust confict, just test by fish
        efg
>>>>>>> FETCH_HEAD
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
