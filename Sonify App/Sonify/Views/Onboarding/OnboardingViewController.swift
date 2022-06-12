//
//  OnboardingViewController.swift
//  Sonify
//
//  Created by Meghan Blyth on 09/07/2021.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var PageControl: UIPageControl!
    
    var slides : [OnboardingSlide] = []
    var currentPage = 0 {
        didSet {
            PageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                NextButton.setTitle("Get Started", for:
                                        .normal)
            } else {
                NextButton.setTitle ("Next", for: .normal)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slides = [
            OnboardingSlide(title:"Let's Sonify an image!", description: "Use Sonification to hear an image or photograph from your gallery.", image: UIImage(named: "undraw_Camera_re_cnp4")!),
            OnboardingSlide(title:"Let's Sonify a color!", description: "Point your camera at your environment to hear a frequency representation of the colors.", image: UIImage(named:"undraw_happy_music_g6wc")!),
            OnboardingSlide(title:"My audio gallery", description: "Listen to your saved sounds.", image: UIImage(named: "undraw_Playlist_re_1oed")!),
        ]
    }
    
    @IBAction func nextBtnClicked(_ sender: UIButton)
    {
        if currentPage == slides.count - 1 {
            let controller = storyboard?.instantiateViewController(identifier: "HomeNC") as! UINavigationController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            
            present(controller, animated: true,
                    completion: nil)
            
        }  else {
            currentPage += 1
            let indexPath = IndexPath (item:
                                        currentPage, section: 0)
            CollectionView.scrollToItem(at:
                                            indexPath, at: .centeredHorizontally,
                                        animated: true)
        }
    }
    
    
    
    
}
extension OnboardingViewController:
    UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView:
                            UICollectionView, numberOfItemsInSection
                                section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView:
                            UICollectionView, cellForItemAt indexPath:
                                IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath)
            as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])        //passing every slide to collection view cell to populate label, title and descriptions.
        return cell
        
        
        
        
    }
    func collectionView(_ collectionView:
                            UICollectionView, layout
                                collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width:
                        collectionView.frame.width, height:
                            collectionView.frame.height)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let currentPage = Int(scrollView.contentOffset.x/width)
        self.currentPage = currentPage          //going outside of current scope to include the class.  Modifying line 16.
        
    }
}

