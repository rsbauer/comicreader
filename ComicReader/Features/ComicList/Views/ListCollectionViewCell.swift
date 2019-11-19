//
//  ListCollectionViewCell.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

struct ListCollectionViewData {
    let title: String
}

class ListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var testLabel: UILabel!
    
    private let onReuseBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// Cell is about to be reused
    override func prepareForReuse() {
        super.prepareForReuse()
        self.onReuseBag.dispose()
    }

    deinit {
        onReuseBag.dispose()
    }
}

extension ListCollectionViewCell: CollectionViewCellProtocol {
    func configureCell(cellData: AnyObject?) {
        guard let config = cellData as? ListCollectionViewData else {
            return
        }
        
        testLabel.text = config.title
    }
    
    static func cellSize(collectionView: UICollectionView, indexPath: IndexPath, cellData: AnyObject?) -> CGSize {
        let cellWidth = collectionView.frame.size.width / 2
        return CGSize(width: cellWidth, height: 100)
    }
}
