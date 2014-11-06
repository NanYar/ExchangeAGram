//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by NanYar on 06.11.14.
//  Copyright (c) 2014 NanYar. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell
{
    var imageView: UIImageView!
    
    override init(frame: CGRect) // override: The FilterCell class is required to be NSCoding complient
    {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(imageView)
    }
    
    
    // The FilterCell class is required to be NSCoding complient
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }    
}
