//
//  Helper.swift
//  StudyEnglishByImage
//
//  Created by Nguyen Duc Tai on 2/25/19.
//  Copyright © 2019 Nguyen Duc Tai. All rights reserved.
//

import UIKit

class Helper: NSObject {
  static var sharedInstance = Helper()
  
  func saveInstalled(){
    UserDefaults.standard.set(true, forKey: "Installed")
  }
  
  func isInstalledAndUsed() -> Bool {
    let result = UserDefaults.standard.value(forKey: "Installed")
    
    if result == nil {
      return false
    }
    
    return (result != nil)
  }
}
