//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 16/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: Properties
    override var isSelected: Bool {
        didSet {
            self.alpha = isSelected ? 0.5 : 1
        }
    }
    var downloadTask: URLSessionDataTask?
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
    }
    
    // MARK: - Configuration
    func configureWithImageData(_ imageData: Data?) {
        DispatchQueue.main.async {
            guard let data = imageData else {
                self.imageView.image = UIImage(named: "no-image")
                return
            }
            self.imageView.image = UIImage(data: data)
        }
    }
    
    func configureWithImageNamed(_ name: String!) {
        DispatchQueue.main.async {
            self.imageView.image = UIImage(named: name)
        }
    }
    
}
