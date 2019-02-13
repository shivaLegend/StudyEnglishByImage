//
//  ViewController.swift
//  StudyEnglishByImage
//
//  Created by Nguyen Duc Tai on 2/6/19.
//  Copyright © 2019 Nguyen Duc Tai. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
  @IBOutlet weak var previewView: UIView!
  let captureSession = AVCaptureSession()
  var previewLayer =  AVCaptureVideoPreviewLayer()
  var photoOutput = AVCapturePhotoOutput()
  
  var imageResult: UIImage!
//  override func viewDidLayoutSubviews() {
//    super.viewDidLayoutSubviews()
//
//  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
    captureSession.startRunning()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if previewView != nil {
      print("preview view is not nil")
      previewLayer.frame = self.previewView.bounds
    }
  
  }
  
  override func viewDidLoad() {
    
    self.request()
    
    self.input()
    
    self.output()
    
    self.setupPreview()
    
    captureSession.startRunning()
  }
  
  //MARK: - IBOutlet function
  @IBAction func click_Camera_Btn(_ sender: UIButton) {
    self.capturePhoto()
  }
  
  //MARK: - Create function
  func request() {
    //Request authorized camera
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized: // The user has previously granted access to the camera.
      //      self.setupCaptureSession()
      print("authorized")
      
    case .notDetermined: // The user has not yet been asked for camera access.
      AVCaptureDevice.requestAccess(for: .video) { granted in
        if granted {
          //          self.setupCaptureSession()
        }
      }
      
    case .denied: // The user has previously denied access.
      self.camDenied()
      return
    case .restricted: // The user can't grant access due to restrictions.
      return
    }
  }
  
  func camDenied()
  {
    DispatchQueue.main.async
      {
        var alertText = "It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Turn the Camera on.\n\n5. Open this app and try again."
        
        var alertButton = "OK"
        var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)
        
        if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)
        {
          alertText = "It looks like your privacy settings are preventing us from accessing your camera to do barcode scanning. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Turn the Camera on.\n\n3. Open this app and try again."
          
          alertButton = "Go"
          
          goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
          })
        }
        
        let alert = UIAlertController(title: "Error", message: alertText, preferredStyle: .alert)
        alert.addAction(goAction)
        self.present(alert, animated: true, completion: nil)
    }
  }
  
  //Capture device input
  func input() {
    captureSession.beginConfiguration()
    let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                              for: .video, position: .unspecified)
    guard
      let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
      captureSession.canAddInput(videoDeviceInput)
      else { return }
    captureSession.addInput(videoDeviceInput)
  }
  
  func output() {
    guard captureSession.canAddOutput(photoOutput) else { return }
    captureSession.sessionPreset = .photo
    captureSession.addOutput(photoOutput)
    captureSession.commitConfiguration()
  }
  
//  func getDeviceOrientation() {
//    //Get statis of devide bar orientation
//    switch UIApplication.shared.statusBarOrientation.isPortrait {
//    case true:
//      deviceOrientation = AVCaptureVideoOrientation.portrait
//    case false:
//      deviceOrientation = AVCaptureVideoOrientation.landscapeRight
//    }
//  }
  
  func setupPreview() {
    self.previewLayer.session = self.captureSession
    self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
    
    //Capture photo have orientation
    photoOutput.connection(with: .video)?.videoOrientation = AVCaptureVideoOrientation.portrait
    
    if previewView != nil {
    previewView.layer.addSublayer(previewLayer)
    }
  }
  
}

extension ViewController: AVCapturePhotoCaptureDelegate {
  func capturePhoto() {
    
    let settings = AVCapturePhotoSettings()
    
    //set format for preview like main photo
    let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
    let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                         kCVPixelBufferWidthKey as String: 160,
                         kCVPixelBufferHeightKey as String: 160]
    settings.previewPhotoFormat = previewFormat
    
    self.photoOutput.capturePhoto(with: settings, delegate: self)
    
  }
  
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
    if let error = error {
      print(error.localizedDescription)
    }
    
    if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
      //Stop running
      captureSession.stopRunning()
      print(UIImage(data: dataImage)!.size) // Your Image
      if let img = UIImage(data: dataImage) {
      let photoVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
      photoVC.takenPhoto = img
        DispatchQueue.main.async {
          self.navigationController?.pushViewController(photoVC, animated: true)
        }
      }
    }
  }

}
