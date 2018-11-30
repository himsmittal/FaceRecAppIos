//
//  RetinaViewController.swift
//  Neural
//
//  Created by Himanshu Mittal on 11/30/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import UIKit

import Photos
import BSImagePicker
import Alamofire

class RetinaViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    
    var selectedAssets = [PHAsset]()
    var photoArray = [UIImage]()
    
    @IBAction func trainAction(_ sender: Any) {
        
        // calling API to upload photo
        for i in 0..<photoArray.count{
            uploadImage(img: photoArray[i],label: nameField.text!)
        }
    }
    
    func uploadImage(img: UIImage, label:String){
        let ImageData = UIImagePNGRepresentation(img)
        //TODO: change the URL
        let urlReq = "http://apiUrl.php"
        let parameters = ["label": label] //you can comment this if not needed
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(ImageData!, withName: "shop_logo",fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameters {// this will loop the 'parameters' value, you can comment this if not needed
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:urlReq)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    print(response.result.value)
                    if let dic = response.result.value as? NSDictionary{
                        //do your action base on Api Return failed/success
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addFaceClick(_ sender: Any) {
        let vc = BSImagePickerViewController()
        
        bs_presentImagePickerController(vc, animated: true,
                                        select: { (asset: PHAsset) -> Void in
                                            // User selected an asset.
                                            // Do something with it, start upload perhaps?
        }, deselect: { (asset: PHAsset) -> Void in
            // User deselected an assets.
            // Do something, cancel upload?
        }, cancel: { (assets: [PHAsset]) -> Void in
            // User cancelled. And this where the assets currently selected.
        }, finish: { (assets: [PHAsset]) -> Void in
            
            for i in 0..<assets.count
            {
                self.selectedAssets.append(assets[i])
            }
            
            self.convertAssetsToImages()
            // User finished with these assets
        }, completion: nil)
        
    }
    
    func convertAssetsToImages() -> Void {
        
        if selectedAssets.count != 0{
            
            
            for i in 0..<selectedAssets.count{
                
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                
                
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                    
                })
                
                let data = UIImageJPEGRepresentation(thumbnail, 0.7)
                let newImage = UIImage(data: data!)
                
                
                self.photoArray.append(newImage! as UIImage)
                
            }
            
            self.imgView.animationImages = self.photoArray
            self.imgView.animationDuration = 3.0
            self.imgView.startAnimating()
            
        }
        
        
        print("complete photo array \(self.photoArray)")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
