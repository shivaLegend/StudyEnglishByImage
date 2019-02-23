//
//  ResultViewController.swift
//  StudyEnglishByImage
//
//  Created by Nguyen Duc Tai on 2/12/19.
//  Copyright © 2019 Nguyen Duc Tai. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO
import AVFoundation
import SwiftyJSON
import Alamofire

class ResultViewController: ViewController {
  
  //MARK: - IB Outlets
  @IBOutlet weak var photoImg: UIImageView!
  @IBOutlet weak var classificationLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  //MARK: - Create variables
  let wikipediaURl = "https://en.wikipedia.org/w/api.php"
  var takenPhoto: UIImage?
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      if let photo = takenPhoto {
        photoImg.image = photo
        updateClassifications(for: photo)
        
      }
      
    }
  
  //MARK: - Create functions
  /// - Tag: MLModelSetup
  lazy var classificationRequest: VNCoreMLRequest = {
    do {
      /*
       Use the Swift class `MobileNet` Core ML generates from the model.
       To use a different Core ML classifier model, add it to the project
       and replace `MobileNet` with that model's generated Swift class.
       */
      let model = try VNCoreMLModel(for: MobileNet().model)
      
      let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
        self?.processClassifications(for: request, error: error)
      })
      request.imageCropAndScaleOption = .centerCrop
      return request
    } catch {
      fatalError("Failed to load Vision ML model: \(error)")
    }
  }()
  
  /// - Tag: PerformRequests
  func updateClassifications(for image: UIImage) {
    classificationLabel.text = "Classifying..."
    
    let orientation = CGImagePropertyOrientation(image.imageOrientation)
    guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
    
    DispatchQueue.global(qos: .userInitiated).async {
      let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
      do {
        try handler.perform([self.classificationRequest])
      } catch {
        /*
         This handler catches general image processing errors. The `classificationRequest`'s
         completion handler `processClassifications(_:error:)` catches errors specific
         to processing that request.
         */
        print("Failed to perform classification.\n\(error.localizedDescription)")
      }
    }
  }
  
  /// Updates the UI with the results of the classification.
  /// - Tag: ProcessClassifications
  func processClassifications(for request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
      guard let results = request.results else {
        self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
        return
      }
      // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
      let classifications = results as! [VNClassificationObservation]
      
      if classifications.isEmpty {
        self.classificationLabel.text = "Nothing recognized."
      } else {
        // Display top classifications ranked by confidence in the UI.
        let topClassifications = classifications.prefix(2)
        let descriptions = topClassifications.map { classification in
          // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
          return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
        }
        print(descriptions)
//        self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
        self.classificationLabel.text = self.takeSubString(s: descriptions[0])
        self.requestInfo(objectName: self.classificationLabel.text!)
        
      }
    }
  }
  
  //Function take substring
  func takeIndexSubString(s: String) -> Int{
    var count = 0
    for i in s {
      if i == ")" {
        return s.count - (count + 2)
      } else {
        count = count + 1
      }
    }
    return s.count - count
  }
  func takeSubString(s: String) -> String {
    let tempS = String(s.suffix(takeIndexSubString(s: s)))
    var count = 0
    for i in tempS {
      if i == "," {
        break
      } else {
        count = count + 1
      }
    }
    let temp = String(tempS.prefix(count))
    return temp
  }
  
  func requestInfo(objectName: String) {
    let parameters : [String:String] = ["format" : "json", "action" : "query", "prop" : "extracts|pageimages", "exintro" : "", "explaintext" : "", "titles" : objectName, "redirects" : "1", "pithumbsize" : "500", "indexpageids" : ""]
    
    
    // https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts|pageimages&exintro=&explaintext=&titles=barberton%20daisy&redirects=1&pithumbsize=500&indexpageids
    
    Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
      if response.result.isSuccess {
        //                print(response.request)
        //
        //                print("Success! Got the flower data")
        let flowerJSON : JSON = JSON(response.result.value!)
        
        let pageid = flowerJSON["query"]["pageids"][0].stringValue
        
//        let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
        let imageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].url
        
        //                print("pageid \(pageid)")
        //                print("flower Descript \(flowerDescription)")
        //                print(flowerJSON)
        //
//        self.infoLabel.text = flowerDescription
        if imageURL != nil {
        self.imageView.load(url: imageURL!)
        }
        
      }
      else {
        print("Error \(String(describing: response.result.error))")
//        self.infoLabel.text = "Connection Issues"
        
        
      }
    }
  }

  
  
  //MARK: - IB Outlet functions
  @IBAction func click_back_btn(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func click_sound_btn(_ sender: UIButton) {
    UIView.animate(withDuration: 0.6,
                   animations: {
                    sender.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    },
                   completion: { _ in
                    UIView.animate(withDuration: 0.6) {
                      sender.transform = CGAffineTransform.identity
                    }
    })
    let string = self.classificationLabel.text
    let utterance = AVSpeechUtterance(string: string ?? "Hello")
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    
    let synth = AVSpeechSynthesizer()
    DispatchQueue.global().async {
      synth.speak(utterance)
    }
    
  }
  
}
