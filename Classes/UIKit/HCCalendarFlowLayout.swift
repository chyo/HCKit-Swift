//
//  HCCalendarFlowLayout.swift
//  HCKit-Swift
//
//  Created by 陈宏超 on 2018/6/6.
//  Copyright © 2018年 陈宏超. All rights reserved.
//

import UIKit

class HCCalendarFlowLayout: UICollectionViewFlowLayout {

    var sectionDictionary:Dictionary<String,Int>?
    var attributes:Array<UICollectionViewLayoutAttributes>?
    
    override init() {
        super.init()
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func setup () {
        self.scrollDirection = UICollectionViewScrollDirection.horizontal
    }
    
    override func prepare() {
        super.prepare()
        
        self.sectionDictionary = Dictionary<String, Int>.init()
        self.attributes = []
        let numberOfSections = self.collectionView?.numberOfSections
        for i in 0 ..< numberOfSections! {
            let numberOfItems = self.collectionView?.numberOfItems(inSection: i)
            for j in 0 ..< numberOfItems! {
                let attr = self.layoutAttributesForItem(at: IndexPath.init(item: j, section: i))
                if attr != nil {
                    self.attributes?.append(attr!)
                }
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /// 此处返回所有的attributes而不是返回可视范围的attributes是因为，默认情况下横向滚动的collectionview是先绘制第一排数据的，当我们横向排列数据后，如果只返回视野返回的attributes，则第一排下半部分会被推迟绘制
        return self.attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        /// 这边需要使用copy，否则会报xxx is modifying attributes returned by UICollectionViewFlowLayout without copying them警告
        let attr = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        /// 让item横向排列
        if attr?.representedElementKind == nil {
            let itemSize = attr!.frame.size
            let index = attr!.indexPath.item
            let section = attr!.indexPath.section
            let numberOfItem = self.collectionView!.numberOfItems(inSection: section)
            let xCount = Int(self.collectionView!.frame.size.width / itemSize.width)
            let yCount = Int(self.collectionView!.frame.size.height / itemSize.height)
            let numberPerPage = xCount * yCount
            let currentPage = index / numberPerPage
            let remain = index % xCount
            let merchant = (index - currentPage*numberPerPage)/xCount
            var xCellOffset = CGFloat(remain) * itemSize.width
            let yCellOffset = CGFloat(merchant) * itemSize.height
            let pagesOfSection = numberOfItem % numberPerPage == 0 ? numberOfItem / numberPerPage : (numberOfItem / numberPerPage + 1)
            self.sectionDictionary![String(section)] = pagesOfSection
            var actualLo = 0
            for key in self.sectionDictionary!.keys {
                actualLo += self.sectionDictionary![key]!
            }
            actualLo -= self.sectionDictionary![String(self.sectionDictionary!.keys.count-1)]!
            xCellOffset += CGFloat(actualLo+currentPage)*self.collectionView!.frame.size.width
            attr?.frame = CGRect.init(x: xCellOffset, y: yCellOffset, width: itemSize.width, height: itemSize.height)
        }
        return attr
    }
}
