//
//  ExampleControlView.swift
//  Fastboard_Example
//
//  Created by xuyunshi on 2022/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

let controlHeight = CGFloat(44)
let controlWidth = CGFloat(166)
let margin = CGFloat(3)

class ExampleItem {
    internal init(title: String, status: String? = nil, enable: Bool = true, clickBlock: ((ExampleItem) -> Void)? = nil) {
        self.title = title
        self.status = status
        self.clickBlock = clickBlock
        self.enable = enable
    }
    
    let title: String
    var status: String?
    var clickBlock: ((ExampleItem) ->Void)?
    var enable: Bool
}

class ExampleControlView: UICollectionView {
    let items: [ExampleItem]
    let layout: UICollectionViewFlowLayout
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: controlHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let count: CGFloat
        if bounds.width > bounds.height {
            count = 5
        } else {
            count = 3
        }
        let m = (count - 1) * margin
        let width = (bounds.width - m) / count
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        if width > controlWidth {
            layout.itemSize = CGSize(width: width, height: controlHeight)
        } else {
            layout.itemSize = CGSize(width: controlWidth, height: controlHeight)
        }
        
        layout.scrollDirection = bounds.height <= controlHeight ? .horizontal : .vertical
    }
    
    init(items: [ExampleItem]) {
        self.items = items
        
        layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        register(UINib(nibName: .init(describing: ControlCell.self), bundle: nil), forCellWithReuseIdentifier: .init(describing: ControlCell.self))
        showsHorizontalScrollIndicator = false
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExampleControlView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        let cell = dequeueReusableCell(withReuseIdentifier: .init(describing: ControlCell.self), for: indexPath) as! ControlCell
        cell.controlTitleLabel.text = item.title
        cell.controlStatusLabel.text = item.status
        cell.controlStatusLabel.isHidden = item.status == nil
        cell.alpha = item.enable ? 1 : 0.5
        return cell
    }
}

extension ExampleControlView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.clickBlock?(item)
        collectionView.reloadData()
    }
}
