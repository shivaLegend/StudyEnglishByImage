//
//  UIImageLoad.swift
//  StudyEnglishByImage
//
//  Created by Nguyen Duc Tai on 2/15/19.
//  Copyright © 2019 Nguyen Duc Tai. All rights reserved.
//

import UIKit

extension UIImageView {
  func load(url: URL) {
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: url) {
        if let image = UIImage(data: data) {
          DispatchQueue.main.async {
            self?.image = image
          }
        }
      }
    }
  }
}
