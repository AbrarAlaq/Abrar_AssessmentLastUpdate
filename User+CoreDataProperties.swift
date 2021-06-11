//
//  User+CoreDataProperties.swift
//  
//
//  Created by ابرار on 01/11/1442 AH.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: NSObject?
    @NSManaged public var gender: NSObject?
    @NSManaged public var name: NSObject?
    @NSManaged public var status: NSObject?

}
