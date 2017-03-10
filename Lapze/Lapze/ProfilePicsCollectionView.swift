////
////  ProfilePicsCollectionView.swift
////  Lapze
////
////  Created by Ilmira Estil on 3/10/17.
////  Copyright © 2017 Lapze Inc. All rights reserved.
////
//
//import UIKit
//
//class ProfilePicsCollectionView: UICollectionView {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        var flowLayout = UICollectionViewFlowLayout()
//        
//        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
//        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.backgroundColor = UIColor.cyanColor()
//        
//        self.view.addSubview(collectionView)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
//    {
//        return 20
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
//    {
//        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
//        
//        cell.backgroundColor = UIColor.greenColor()
//        return cell
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
//    {
//        return CGSizeMake(50, 50)
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
//    {
//        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//    }
//
//
//}
