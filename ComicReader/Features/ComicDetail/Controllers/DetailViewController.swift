//
//  DetailViewController.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/13/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import ReactiveKit
import Swinject
import UIKit

public class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageCountLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    private weak var container: Container?
    private var disposeBag: DisposeBag = DisposeBag()
    private var viewModel = BookDetailViewModel()
    private let media: Media

    public init(container: Container?, media: Media) {
        self.container = container
        self.media = media
        super.init(nibName: "DetailViewController", bundle: nil)
    }
    
    required public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        media = Media()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public  override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        
        subscribeToEvents()
        viewModel.setMedia(media: media)
    }
    
    deinit {
        viewModel.shutdown()
        
        disposeBag.dispose()
        disposeBag = DisposeBag()
    }
    
    private func subscribeToEvents() {
        viewModel.title.observeNext { [weak self] (value) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.titleLabel.text = value
            strongSelf.title = value
        }.dispose(in: disposeBag)
        
        viewModel.thumbnail.observeNext { [weak self] (value) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.imageView.sd_setImage(with: URL(string: value), completed: nil)
        }.dispose(in: disposeBag)
        
        viewModel.id.observeNext { [weak self] (value) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.idLabel.text = "\(value)"
        }.dispose(in: disposeBag)
        
        viewModel.pageCount.observeNext { [weak self] (value) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.pageCountLabel.text = "\(value)"
        }.dispose(in: disposeBag)
    }
}
