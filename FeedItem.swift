//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by NanYar on 08.11.14.
//  Copyright (c) 2014 NanYar. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem) // = Bridge to Objective-C for class FeedItem
class FeedItem: NSManagedObject
{
    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
}
