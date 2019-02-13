//
//  ResultViewController.swift
//  StudyEnglishByImage
//
//  Created by Nguyen Duc Tai on 2/12/19.
//  Copyright © 2019 Nguyen Duc Tai. All rights reserved.
//

import UIKit

class ResultViewController: ViewController {
  
  @IBOutlet weak var photoImg: UIImageView!
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
      }
        
    }
  
  //MARK: - IB Outlet function
  @IBAction func click_back_btn(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  

}
