//
//  HCPhotoBrowserFlowLayout.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/15.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class HCPhotoBrowserFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        self.collectionView?.decelerationRate = 0.01
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let proposedRect = CGRect.init(x: self.collectionView!.contentOffset.x, y: self.collectionView!.contentOffset.y, width: self.collectionView!.bounds.size.width, height: self.collectionView!.bounds.size.height)
        let elementAttributesInRect = super.layoutAttributesForElements(in: proposedRect)
        var attribute:UICollectionViewLayoutAttributes?
        if elementAttributesInRect != nil && elementAttributesInRect!.count >= 2 {
            if velocity.x < 0 {
                attribute = elementAttributesInRect![0]
            } else {
                attribute = elementAttributesInRect![1]
            }
        } else if elementAttributesInRect != nil && elementAttributesInRect!.count == 1 {
            attribute = elementAttributesInRect![0]
        }
        if attribute != nil {
            return CGPoint.init(x: attribute!.frame.origin.x, y: 0)
        }  else {
            return proposedContentOffset;
        }
    }
}
