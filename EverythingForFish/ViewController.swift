//
//  ViewController.swift
//  EverythingForFish
//
//  Created by Fish Yu on 14-6-11.
//  Copyright (c) 2014年 yhl10000@gmail.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!){
        
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int{
        return 10;
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell!
    {
        var cell : UICollectionViewCell  =  collectionView.dequeueReusableCellWithReuseIdentifier("only_lable", forIndexPath:indexPath) as UICollectionViewCell;
        var l100 : UILabel =  cell.viewWithTag(100) as UILabel;
        l100.text = "测试";
        return cell;
    }
}

