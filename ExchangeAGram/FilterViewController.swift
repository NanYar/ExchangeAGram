//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by NanYar on 06.11.14.
//  Copyright (c) 2014 NanYar. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    var thisFeedItem: FeedItem!
    var collectionView: UICollectionView!
    let kIntensity = 0.7
    var context: CIContext = CIContext(options: nil)
    var filters: [CIFilter] = []
    let placeHolderImage = UIImage(named: "Placeholder")
    let tmp = NSTemporaryDirectory()
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return filters.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell: FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        cell.imageView.image = placeHolderImage
        
        //Advanced code: Multi-Threading (GCD)
        let filterQueue: dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getCachedImage(indexPath.row)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })
        return cell
    }
    
    //UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        createUIAlertController()
        
//        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
//        
//        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
//        self.thisFeedItem.image = imageData
//        
//        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
//        self.thisFeedItem.thumbNail = thumbNailData
//        
//        //Speichern in CoreData:
//        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
//        
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    // Helper Functions
    func photoFilters() -> [CIFilter]
    {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    
    func filteredImageFromImage(imageData: NSData, filter: CIFilter) -> UIImage
    {
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage: CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage: CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        //let finalImage = UIImage(CGImage: cgImage)
        let finalImage = UIImage(CGImage: cgImage, scale: 1.0, orientation: UIImageOrientation.Up)
        
        return finalImage!
    }
    
    
    // UIAlertController Helper Functions
    func createUIAlertController()
    {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
        var text: String
        let textField = alert.textFields![0] as UITextField
        
        if textField.text != nil
        {
            text = textField.text
        }
        
        
        let photoAction = UIAlertAction(title: "Post to Facebook with Caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            
        }
        alert.addAction(photoAction)
        
        
        let saveFilterAction = UIAlertAction(title: "Save Filter w/o posting", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
        }
        alert.addAction(saveFilterAction)
        
        
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            
        }
        alert.addAction(cancelAction)
        
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    // Caching Functions
    func cacheImage(imageNumber: Int)
    {
        //let fileName = "\(imageNumber)"
        let fileName = "\(imageNumber)-\(thisFeedItem.hashValue)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        //println(uniquePath)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName)
        {
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage(imageNumber: Int) -> UIImage
    {
        //let fileName = "\(imageNumber)"
        let fileName = "\(imageNumber)-\(thisFeedItem.hashValue)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        var image: UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath)
        {
            image = UIImage(contentsOfFile: uniquePath)!
        }
        else
        {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        return image
    }
    
}
