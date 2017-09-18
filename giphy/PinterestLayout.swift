//
//  PinterestLayout.swift
//  pintersest
//
//  Created by chetan rajagiri on 18/09/17.
//  Copyright © 2017 chetan rajagiri. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate {
    func collectionView(collectionview: UICollectionView , heightForItemAtIndexpath indexpath: NSIndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    
    var delegate : PinterestLayoutDelegate!
    var numberOfColumns = 1
    
    private var cache = [UICollectionViewLayoutAttributes] ()
    private var contentHeight : CGFloat = 0
    private var width: CGFloat {
        get {
            return collectionView!.bounds.width
        }
    }
    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    override func prepare() {
        cache.removeAll(keepingCapacity: false)
        if cache.isEmpty {
            let columnWidth = width / CGFloat(numberOfColumns)
            var xOffsets = [CGFloat]()
            for column in 0..<numberOfColumns {
                xOffsets.append(CGFloat(column) * columnWidth)
            }
            var yOffset = [CGFloat] (repeating: 0 , count: numberOfColumns)
            var column = 0
            _ = 0
            let items = collectionView!.numberOfItems(inSection: 0)
            for item in 0..<items {
                let indexpath = NSIndexPath(item: item , section: 0)
                let height = delegate.collectionView(collectionview: collectionView!, heightForItemAtIndexpath: indexpath)
                let frame = CGRect(x: xOffsets[column], y: yOffset[column], width: columnWidth, height: height)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexpath as IndexPath)
                attributes.frame = frame
                cache.append(attributes)
                contentHeight = max(contentHeight, frame.maxY )
                yOffset[column] = yOffset[column] + height
                column = column >= (numberOfColumns - 1) ? 0 : column+1
                
            }
        }
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects (rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }    
}
