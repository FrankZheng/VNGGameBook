//
//  WeakArray.swift
//  VNGGameBook
//
//  Created by frank.zheng on 2019/5/7.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

import Foundation

extension NSPointerArray {
    
    /// add
    func addObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
    
    /// insert
    func insertObject(_ object: AnyObject?, at index: Int) {
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        insertPointer(pointer, at: index)
    }
    
    /// replace
    func replaceObject(at index: Int, withObject object: AnyObject?) {
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        replacePointer(at: index, withPointer: pointer)
    }
    
    /// get index
    func object(at index: Int) -> AnyObject? {
        guard index < count, let pointer = self.pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    
    /// remove
    func removeObject(at index: Int) {
        guard index < count else { return }
        
        removePointer(at: index)
    }
    
    /// remove
    func remove(_ object: AnyObject?) {
        
        var index: Int?
        for i in 0..<allObjects.count {
            
            if self.object(at: i)?.hash == object?.hash {
                index = i
            }
        }
        
        if let aIndex = index {
            removeObject(at: aIndex)
        }
    }
}

class WeakArray<T> {
    
    private var contents = NSPointerArray(options: .weakMemory)
    
    /// add item
    public func add(_ item: T) {
        
        contents.addObject(item as AnyObject)
    }
    
    /// remove item
    public func remove(_ item: T) {
        
        contents.remove(item as AnyObject)
    }
    
    /// excute delegate func
    public func excute(_ block:@escaping ((T?)->Void)) {
        
        contents.allObjects.forEach({
            block($0 as? T)
        })
    }
    
}
