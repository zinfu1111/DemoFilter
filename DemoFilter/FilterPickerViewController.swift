//
//  FilterPickerViewController.swift
//  FilterPickerViewController
//
//  Created by 連振甫 on 2021/8/6.
//

import UIKit
import CoreImage.CIFilterBuiltins

private let reuseIdentifier = "FilterViewCell"

class FilterPickerViewController: UICollectionViewController {
    
    var lastOffsetWithSound: CGFloat = 0
    var selectedItem = 0
    var delegate: PhotoManagerDelegate?
    
    init?(coder: NSCoder, delegate:PhotoManagerDelegate) {
        self.delegate = delegate
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Do any additional setup after loading the view.
        setupImageData()
    }
    func setupImageData() {
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return PhotoManager.shared.filters.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FilterViewCell
    
        // Configure the cell
        cell.titleLabel.text = PhotoManager.shared.titleData[indexPath.row]
        cell.filterImageView.image = PhotoManager.shared.sampleImageData[indexPath.row]
        cell.layer.borderColor = selectedItem == indexPath.row ? UIColor.yellow.cgColor : UIColor.clear.cgColor
        cell.layer.borderWidth = 2
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = indexPath.row
        collectionView.reloadData()
        delegate?.makePhoto(with: selectedItem)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let flowLayout = ((scrollView as? UICollectionView)?.collectionViewLayout as? UICollectionViewFlowLayout) {
            let lineHeight = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            let offset = scrollView.contentOffset.x
            let roundedOffset = offset - offset.truncatingRemainder(dividingBy: lineHeight)
            if abs(lastOffsetWithSound - roundedOffset) >= lineHeight {
                lastOffsetWithSound = roundedOffset
                UIDevice.peek()
            }
        }
    }
}


extension CIFilter {
    
    var image: UIImage? {
        guard let outputImage = self.outputImage else { return nil }
        return UIImage(ciImage: outputImage)
    }
    
    func getOriginFilterImage(by originalUIImage:UIImage) -> UIImage? {
        guard let outputImage = self.outputImage else { return nil }
        let rotateCIImage = outputImage.oriented(CGImagePropertyOrientation(originalUIImage.imageOrientation))
        return UIImage(ciImage: rotateCIImage)
    }
    
}
extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
