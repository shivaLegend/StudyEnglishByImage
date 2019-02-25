//
//  TutorialViewController.swift
//  StudyEnglishByImage
//
//  Created by Nguyen Duc Tai on 2/24/19.
//  Copyright © 2019 Nguyen Duc Tai. All rights reserved.
//

import UIKit

class TutorialViewController: ViewController {

  //MARK: - IBOutlet
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  
  //MARK: - Create Variable
  let imgArray = ["img1","img2"]
  let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
        super.viewDidLoad()

        
    }
  
  //MARK: - IBAction
  
  @IBAction func click_back_btn(_ sender: UIButton) {
    if pageControl.currentPage == 1 {
      pageControl.currentPage = 0
      let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
  }
  
  @IBAction func click_next_btn(_ sender: UIButton) {
    if pageControl.currentPage == 0 {
      pageControl.currentPage = 1
      let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
       collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    } else {
      //Show New View Controller
      print("click")
      Helper.sharedInstance.saveInstalled()
      let newVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
      
      DispatchQueue.main.async {
        
        self.navigationController?.pushViewController(newVC, animated: true)
      }
      
    }
  }
}

//MARK: - UIColellection View Delegate & Datasource
extension TutorialViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TutorialCollectionViewCell
      cell.imageView.image = UIImage(named: imgArray[indexPath.row])
      return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
    if indexPath.row == 1 {
      pageControl.currentPage = 1
    } else {
      pageControl.currentPage = 0
    }
  }
//  func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    print(scrollView.contentOffset.x)
//    if scrollView.contentOffset.x < UIScreen.main.bounds.width/2 {
//      pageControl.currentPage = 0
//    }
//    else {
//        self.pageControl.currentPage = 1
//      }
//    }
  
}

