//
//  FirebaseDataSource.swift
//  FireKit
//
//  Created by deast on 5/25/15.
//  Copyright (c) 2015 davideast. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FirebaseDataSourceDelegate {
  optional func firebaseDataSource(firebaseDataSource: FirebaseDataSource, itemAddedAtIndexPath: NSIndexPath, data: FDataSnapshot)
  optional func firebaseDataSource(firebaseDataSource: FirebaseDataSource, itemChangedAtIndexPath: NSIndexPath, data: FDataSnapshot)
  optional func firebaseDataSource(firebaseDataSource: FirebaseDataSource, itemRemovedAtIndexPath: NSIndexPath, data: FDataSnapshot)
  optional func firebaseDataSource(firebaseDataSource: FirebaseDataSource, itemMovedAtIndexPath: NSIndexPath, toIndexPath: NSIndexPath, data: FDataSnapshot)
}

class FirebaseDataSource: NSObject, FirebaseArrayDelegate {
  
  private var syncArray: FirebaseArray
  var delegate: FirebaseDataSourceDelegate?
  
  var count: Int {
    return syncArray.list.count
  }
  
  var list: [FDataSnapshot] {
    return syncArray.list
  }
  
  func startSync() {
    syncArray.sync()
  }
  
  func stopSync() {
    syncArray.dispose()
  }
  
  init(ref: Firebase) {
    syncArray = FirebaseArray(ref: ref)
    super.init()
    syncArray.delegate = self
  }
  
  func itemAtIndexPath(indexPath: NSIndexPath) -> FDataSnapshot {
    return list[indexPath.row]
  }
  
  func list(list: [FDataSnapshot], indexAdded: Int, data: FDataSnapshot) {
    let path = createNSIndexPath(indexAdded)
    delegate?.firebaseDataSource?(self, itemAddedAtIndexPath: path, data: data)
  }
  
  func list(list: [FDataSnapshot], indexChanged: Int, data: FDataSnapshot) {
    let path = createNSIndexPath(indexChanged)
    delegate?.firebaseDataSource?(self, itemChangedAtIndexPath: path, data: data)
  }
  
  func list(list: [FDataSnapshot], indexRemoved: Int, data: FDataSnapshot) {
    let path = createNSIndexPath(indexRemoved)
    delegate?.firebaseDataSource?(self, itemRemovedAtIndexPath: path, data: data)
  }
  
  func list(list: [FDataSnapshot], oldIndex: Int, newIndex: Int, data: FDataSnapshot) {
    let oldPath = createNSIndexPath(oldIndex)
    let newPath = createNSIndexPath(newIndex)
    delegate?.firebaseDataSource?(self, itemMovedAtIndexPath: oldPath, toIndexPath: newPath, data: data)
  }
  
  func createNSIndexPath(forItem: Int, inSection: Int = 0) -> NSIndexPath {
    return NSIndexPath(forItem: forItem, inSection: inSection)
  }
  
}