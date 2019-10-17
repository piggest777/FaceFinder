//
//  ViewController.swift
//  FaceFinder
//
//  Created by Denis Rakitin on 2019-10-16.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var msgLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.hidesWhenStopped = true
        setupImage()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupImage()
    }
    
    func setupImage () {
        guard let image = UIImage(named: "faces") else { return }
        
        guard let cgImage = image.cgImage else {
            print("Could not find CGImage")
            return
            
        }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        
        let scaledView = (view.frame.width / image.size.width) * image.size.height
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledView)
        view.addSubview(imageView)
        
        spinner.startAnimating()
        
//        DispatchQueue.global(qos: .background).async {
//            self.performVisionRequest(for: cgImage, with: scaledView)
//        }
        
        performVisionRequest(for: cgImage, with: scaledView)
       
    }
    
    func createFaceOutline(for rectangle: CGRect) {
        
        let yellowView = UIView()
        yellowView.backgroundColor = .clear
        yellowView.layer.borderColor = UIColor.yellow.cgColor
        yellowView.layer.borderWidth = 3
        yellowView.layer.cornerRadius = 5
        yellowView.alpha = 0.0
        yellowView.frame = rectangle
        self.view.addSubview(yellowView)
        
        UIView.animate(withDuration: 0.3) {
            yellowView.alpha = 0.75
            self.spinner.alpha = 0.0
            self.msgLbl.alpha = 0.0
            
        }
        
        self.spinner.stopAnimating()
        
    }
    
    func performVisionRequest (for image: CGImage, with scaledHight: CGFloat) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest  { (request, error) in
            if error != nil {
                print("Faild to detect face")
                return
            }
            
            request.results?.forEach({ (result) in
                guard let faceObservation = result as? VNFaceObservation else { return }
                
                
                let width = self.view.frame.width * faceObservation.boundingBox.width
                let hight = scaledHight * faceObservation.boundingBox.height
                let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                let y = scaledHight * (1 - faceObservation.boundingBox.origin.y) - hight

                DispatchQueue.main.async {
                    let faceRectangle = CGRect(x: x, y: y, width: width, height: hight)
                    self.createFaceOutline(for: faceRectangle)
                }

            })
        }
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch  {
            print("Failed to perform image request: ", error.localizedDescription)
        }
        
        
    }


}

