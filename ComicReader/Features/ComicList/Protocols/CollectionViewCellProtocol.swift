//
//  CollectionViewCellProtocol.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit

/// Protocol used to define the bare minimum for a cell to be
/// compatible with the ArticleStory collection view.
protocol CollectionViewCellProtocol: class {
    
    /// Give the cell the view model and let it configure itself
    /// - Parameter cellData: AnyObject? containing cell specific data
    func configureCell(cellData: AnyObject?)

    /// Get the cell size.  This is static to ensure a developer (me) doesn't
    /// try calling this from a dequeued cell which likely won't work since the
    /// cell isn't setup yet and not committed to the collection view and
    /// memory.
    ///
    /// - Parameters:
    ///   - collectionView: collection view requesting the size
    ///   - indexPath: index path of the requested cell size
    ///   - cellData: AnyObject? containing cell specific data
    /// - Returns: CGSize of the cell
    static func cellSize(collectionView: UICollectionView,
                         indexPath: IndexPath,
                         cellData: AnyObject?) -> CGSize
}
