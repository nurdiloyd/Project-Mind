//
//  NodeEntity+CoreDataProperties.swift
//  Mind
//
//  Created by Nurdogan Karaman on 2.07.2024.
//
//

import Foundation
import CoreData


public class NodeEntity: NSManagedObject {

}

extension NodeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NodeEntity> {
        return NSFetchRequest<NodeEntity>(entityName: "NodeEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageName: String?
    @NSManaged public var positionX: Double
    @NSManaged public var positionY: Double
    @NSManaged public var title: String?
    @NSManaged public var lastX: Double
    @NSManaged public var lastY: Double
    @NSManaged public var children: NSSet?
    @NSManaged public var parent: NodeEntity?

}

// MARK: Generated accessors for children
extension NodeEntity {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: NodeEntity)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: NodeEntity)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension NodeEntity : Identifiable {

}
