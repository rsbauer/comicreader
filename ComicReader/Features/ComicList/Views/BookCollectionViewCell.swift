//
//  BookCollectionViewCell.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/18/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import ReactiveKit
import SDWebImage
import UIKit

class BookCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
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

extension BookCollectionViewCell: CollectionViewCellProtocol {
    func configureCell(cellData: AnyObject?) {
        guard let media = cellData as? Media else {
            return
        }
        
        titleLabel.text = media.title
        imageView.sd_setImage(with: URL(string: media.thumbnail), completed: nil)
    }
    
    static func cellSize(collectionView: UICollectionView, indexPath: IndexPath, cellData: AnyObject?) -> CGSize {
        let cellWidth = collectionView.frame.size.width / 2
        return CGSize(width: cellWidth, height: 300)
    }
}
