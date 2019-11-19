//
//  ListViewController.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import ReactiveKit
import Swinject
import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private weak var container: Container?
    private var disposeBag: DisposeBag = DisposeBag()
    private var collectionViewBag: DisposeBag = DisposeBag()
    private var viewModel = ListViewModel()
    
    private enum Constants {
        static let errorTitle = "Error"
        static let dismiss = "Dismiss"
    }
    
    public init(container: Container) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    
    required public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Book"
        
        // get list of items - if in cache, then use it, otherwise call to get items
        setupCollectionView(collectionView: self.collectionView)
        viewModel.registerCollectionViewCells(collectionView: collectionView)
        
        if let containerExists = container {
            viewModel.setRepository(repository: MarvelRepository(container: containerExists))
        }
        
        setupObservers()
    }
    
    deinit {
        viewModel.shutdown()
        
        disposeBag.dispose()
        disposeBag = DisposeBag()

        collectionViewBag.dispose()
        collectionViewBag = DisposeBag()
        
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
    
    // MARK: - Support Methods
    
    /// Setup collection view.  Set delegates here.  Define data source here.
    /// Configure cell as one would for cellAtIndexPath.
    ///
    /// - Parameter collectionView: collection view to initialize
    private func setupCollectionView(collectionView: UICollectionView) {
        collectionView.delegate = self
        
        viewModel.items.bind(to: collectionView) { (items, indexPath, collectionView) -> UICollectionViewCell in
            
            let item = items[indexPath.item]            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.cellName, for: indexPath as IndexPath)
            
            if let cellCanConfig = cell as? CollectionViewCellProtocol {
                cellCanConfig.configureCell(cellData: item.cellData)
            }
            
            return cell
        }.dispose(in: self.collectionViewBag)
    }
    
    private func setupObservers() {
        viewModel.error.observeNext { [weak self] (error) in
            guard let strongSelf = self, error != nil else {
                return
            }
            
            let alert = UIAlertController(title: Constants.errorTitle,
                                          message: error?.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.dismiss, style: .cancel, handler: nil))
            DispatchQueue.main.async {
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }.dispose(in: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.item]
        guard let media = item.cellData as? Media else {
            return
        }

        let detailController = DetailViewController(container: container, media: media)
        self.navigationController?.pushViewController(detailController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    /// Get the size of the cell at the given index
    ///
    /// - Parameters:
    ///   - collectionView: collection view requesting the cell size
    ///   - collectionViewLayout: collection view layout used
    ///   - indexPath: index path of the cell needing the size
    /// - Returns: CGSize of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard !viewModel.items.isEmpty else {
            return CGSize.zero
        }
        
        let item = viewModel.items[indexPath.item]
        let cellWidth = collectionView.frame.size.width
        
        if item.isInSection == .copyright || item.isInSection == .loading {
            return CGSize(width: cellWidth, height: 44.0)
        }
        
        // verify the cell name exists AND conforms to the protocol
        if let aClass = NSClassFromString("ComicReader.\(item.cellName)") as? CollectionViewCellProtocol.Type {
            return aClass.cellSize(collectionView: collectionView, indexPath: indexPath, cellData: item.cellData)
        }
        
        // couldn't find a size so return a default size - not ideal but can at least see the cell
        return CGSize(width: cellWidth, height: 44.0)
    }
}
