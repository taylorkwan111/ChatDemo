//
//  FilterViewController.swift
//  ProjectDemo
//
//  Created by 邓唯 on 2020/11/19.
//  Copyright © 2020 Binatir. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum SelectedImageEnum {
    
    /// The enum of enum
    enum UploadStatus {
        case pending, uploading, succeeded(AssetImage), failed(Error)
    }
    
    enum Style: Int, CaseIterable {
        case appearance         =   1000
        case insideLabel        =   1001
        case backOfInsole       =   1002
        case insoleStitching    =   1003
        case boxLabel           =   1004
        case dateCode           =   1005
        case additional         =   1006
        
        var title: String {
            switch self {
            case .appearance:
                return "Appearance"
            case .insideLabel:
                return "Inside Label"
            case .backOfInsole:
                return "Insole Stitching"
            case .insoleStitching:
                return "Insole"
            case .boxLabel:
                return "Box Label"
            case .dateCode:
                return "Date Code"
            case .additional:
                return "Additional"
            }
        }
        
    }
    
    
    case image(UIImage, UploadStatus, Style)
    case add
    case uploadedImage(ProductCheckRequestImage)
    
    var associatedImage: UIImage? {
        switch self {
        case .add, .uploadedImage:
            return nil
        case .image(let image, _, _):
            return image
        }
    }
    
    
    
    mutating func resetToPendingIfFailed() {
        if case let .image(image, status, style) = self, case .failed = status {
            self = .image(image, .pending, style)
        }
    }
}


class FilterViewController: UIViewController {
    var newAvatar = UIImage(){
        didSet {
            configurefiler()
        }
    }
    
    var filterImage = UIImage() {
        didSet {
            filterCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    private var selectedImageAtIndexAction: ((UIImage) -> Void)?
    private var selectedImagesEnum: [SelectedImageEnum] = [.image(placeholderEmptyImage, .pending, .appearance ),
                                                           .image(placeholderEmptyImage, .pending, .insideLabel),
                                                           .image(placeholderEmptyImage, .pending, .backOfInsole),
                                                           .image(placeholderEmptyImage, .pending, .insoleStitching),
                                                           .image(placeholderEmptyImage, .pending, .boxLabel),
                                                           .image(placeholderEmptyImage, .pending, .dateCode),
                                                           .image(placeholderEmptyImage, .pending, .additional)        ]
        {
        didSet {
            photoCollectionView.reloadData()
        }
    }
    private var productImageSelectionResultHandler: ((UIImage) -> Void)?
    static let placeholderEmptyImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        
         
        // Do any additional setup after loading the view.
    }
    
    private func configurefiler() {
//        let imgData = newAvatar.orientationFixed.jpegData(compressionQuality: 0.8)!
//        NetworkManager.shared.uploadAsset(image: newAvatar, description: nil)
//            .onError { error in
//                self.showFailureAlert(title: NSLocalizedString("Unabled to upload image. Please try again.", bundle: .language, comment: "Alert message"))
//                print("222")
//        }
//        .onSuccess { json in
//            let asset = AssetImage(json: json)
//            print(asset)
//            print("333")
//
//        }
//
        var headers: HTTPHeaders = [:]
        let imgData = newAvatar.orientationFixed.jpegData(compressionQuality: 0.1)!
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
        },
        to: "http://vd4enx.natappfree.cc/photo/process?model=rain_princess",
        headers: headers).response { response in
            if let data = response.value {
                let image = UIImage(data: data!)
                self.filterImage = image ?? UIImage()
                print(image)
            }
        }

    }
    

   
    
    private func configureCollectionView() {
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(UploadImageCollectionViewCell.nib, forCellWithReuseIdentifier: "cell")
        photoCollectionView.isScrollEnabled = false
        
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        filterCollectionView.register(UploadImageCollectionViewCell.nib, forCellWithReuseIdentifier: "cell")
        filterCollectionView.isScrollEnabled = false
        
    }
    
    
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        paginationManager.fetchIfNeeded(by: scrollView, targetContentOffset: targetContentOffset)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UploadImageCollectionViewCell
        switch collectionView {
        case self.photoCollectionView:
            let selectedImage = selectedImagesEnum[indexPath.item]
            switch selectedImage {
            case .image(let image, _, _):
                cell.iconImageView.isHidden = false
                cell.setImage(image)
    //            newAvatar = image
            case .add:
                // Returns the `add` button cell instead a normal image cell.
                cell.iconImageView.isHidden = false
                cell.reset()
            case .uploadedImage(let image):
                cell.setImageWithUrL(image.imageUrl)
                cell.iconImageView.isHidden = false
            }
            return cell
        default:
            cell.iconImageView.isHidden = true
            cell.setImage(filterImage)
            return cell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = selectedImagesEnum[indexPath.item]
        switch collectionView {
        case self.filterCollectionView:
            ImageBrowserViewController(contentSource: .image([self.filterImage])).do {
                $0.preselectedIndex = indexPath.row
//                $0.isShareImagesEnabled = true
//                $0.isSaveToAlbumEnabled = true
                present($0, animated: true, completion: nil)
            }
        default:
            switch selectedImage {
            case .uploadedImage:
                break
            default:
                presentPickPhotoActionSheet(atIndex: indexPath.item)
            }
        }
    }
}

extension FilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func setSelectedImageAtIndexAction(index: Int) {
        selectedImageAtIndexAction = { [weak self] image in
            guard let self = self else { return }
            if case .image(_,_,let style) = self.selectedImagesEnum[index] {
                if style ~= .additional {
//                    self.newAvatar = image
                    self.selectedImagesEnum.insert(.image(image, .pending, .additional), at: self.selectedImagesEnum.count - 1 )
                } else {
//                    self.newAvatar = image
                    self.selectedImagesEnum[index] = .image(image, .pending, style )
                }
            }
        }
    }
    
    private func presentPickPhotoActionSheet(atIndex index: Int) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Camera", bundle: .language, comment: "Action sheet button title guiding users to pick an image from Camera or Album"), style: .default) { _ in
            self.presentImagePickerController(type: .camera, failureMessage: NSLocalizedString("Unable to capture new photos with your camera", bundle: .language, comment: "Alert message"))
            self.setSelectedImageAtIndexAction(index: index)
        })
        ac.addAction(UIAlertAction(title: NSLocalizedString("Album", bundle: .language, comment: "Action sheet button title guiding users to pick an image from Camera or Album"), style: .default) { _ in
            self.presentImagePickerController(type: .photoLibrary, failureMessage: NSLocalizedString("Unable to load the album", bundle: .language, comment: "Alert message"))
            self.setSelectedImageAtIndexAction(index: index)
           
        })
        
        let selectEnum = selectedImagesEnum[index]
        if selectedImagesEnum.count <= 7  {
            switch selectEnum {
            case .image(let image, _, let style):
                if image != UIImage() {
                    let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", bundle: .language, comment: "Button title"), style: .destructive) { _ in
                        self.selectedImagesEnum[index] = .image(FilterViewController.placeholderEmptyImage, .pending, style)
                    }
                    ac.addAction(deleteAction)
//                    self.configurefiler()
                }
            default:
                break
            }
        } else {
            if index != selectedImagesEnum.count - 1 {
                let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", bundle: .language, comment: "Button title"), style: .destructive) { _ in
                    self.selectedImagesEnum.remove(at: index)
                }
                ac.addAction(deleteAction)
            }
        }
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .language, comment: "Button title"), style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func presentImagePickerController(type: UIImagePickerController.SourceType, failureMessage: String) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            showFailureAlert(title: failureMessage)
            return
        }
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            showFailureAlert(title: NSLocalizedString("Please select an image", bundle: .language, comment: "Alert message"))
            return
        }
        selectedImageAtIndexAction?(image)
        newAvatar = image
        selectedImageAtIndexAction = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        productImageSelectionResultHandler = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
