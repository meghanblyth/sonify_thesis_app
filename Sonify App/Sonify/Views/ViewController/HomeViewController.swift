//
//  HomeViewController.swift
//  Sonify
//
//  Created by Meghan Blyth on 14/07/2021.
//

import UIKit
import AVKit
import ProgressHUD
import AVFoundation
import CircleProgressBar

class HomeViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var circularProgressView: CircleProgressBar!
    @IBOutlet weak var sonifyingTItleLbl: UILabel!
    @IBOutlet var circularProgressContainerView: UIView!
    
    var home: [Home] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.home = UserDefaults.standard.sonifiedAudioList.map { $0.asHome }
        print("Home: \(home)")
        collectionView.dataSource = self
        collectionView.delegate =  self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
    }
    
    @IBAction func openColorToSound(_ sender: UIBarButtonItem) {
        let controller = storyboard?.instantiateViewController(identifier: "ColorToSoundViewController") as! ColorToSoundViewController
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func addBtnClicked(_ sender: UIBarButtonItem) {
        selectImageSource()
    }
    
    private func startSonification(_ image: UIImage) {
        toggleCircularProgress(show: true, sonifying: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            self?.toggleCircularProgress(show: true, sonifying: false)
            self?.circularProgressView.setProgress(0, animated: false)
            
            NetworkService.shared.downloadImage { [weak self] (result) in
                switch result {
                case .success(let tempUrl):
                    do {
                        let imageName = "\(UUID().uuidString).MIDI"
                        let audioUrl = imageName.fullPathFromDocuments
                        try FileManager.default.moveItem(at: tempUrl, to: audioUrl)
                        let newData = Home(title: "", image: image, name: imageName)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                            self?.toggleCircularProgress(show: false, sonifying: false)
                            ProgressHUD.showSuccess("Sonification Complete")
                            
                            self?.home.insert(newData, at: 0)
                            UserDefaults.standard.sonifiedAudioList = self?.home.map { $0.asSonifiedData } ?? []
                            self?.collectionView.reloadData()
                        }
                    } catch {
                        self?.toggleCircularProgress(show: false, sonifying: false)
                        ProgressHUD.showError("Error saving audio file to phone")
                        print("Error: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    ProgressHUD.showError(error.localizedDescription)
                }
                
            } progress: { [weak self] (progress) in
                self?.circularProgressView.setProgress(progress, animated: true)
            }
        }
    }
    
    private func selectImageSource(){
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertStyle = UIAlertController.Style.alert
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { (_) in
            self.chooseImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: { (_) in
            self.chooseImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func chooseImage(fromSourceType sourceType: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }else{
            print("Source type not supported")
        }
    }
    
    private func toggleCircularProgress(show: Bool, sonifying: Bool) {
        sonifyingTItleLbl.isHidden = !sonifying
        circularProgressView.hintHidden = sonifying
        circularProgressView.setProgress(1, animated: true, duration: 20)
        circularProgressContainerView.frame = view.frame
        circularProgressContainerView.frame.size.height += 50
        
        if show {
            UIApplication.shared.keyWindow?.addSubview(circularProgressContainerView)
        } else {
            circularProgressContainerView.removeFromSuperview()
        }
    }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            ProgressHUD.show("Uploading image")
            NetworkService.shared.uploadImage(image) { [weak self] (error) in
                if let error = error {
                    ProgressHUD.showError(error)
                } else {
                    ProgressHUD.dismiss()
                    self?.startSonification(image)
                    self?.toggleCircularProgress(show: true, sonifying: true)
                }
            }
            dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection
        section: Int) -> Int {
        return home.count      //going to create n number of cells
    }
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellClicked))
        tap.name = String(indexPath.row)
        cell.addGestureRecognizer(tap)
        cell.setup(with:home[indexPath.row])
        
        return cell 
    }
    
    @objc private func cellClicked(_ sender: UITapGestureRecognizer) {
//        let player = AVPlayer(url: URL(fileURLWithPath: self.home[Int(sender.name ?? "0")!].url!))
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        print("Playing audio from URL: \(self.home[Int(sender.name ?? "0")!].url!)")
//        present(playerController, animated: true) {
//            player.play()
//        }
        let controller = storyboard?.instantiateViewController(identifier: AudioPreviewViewController.identifier) as! AudioPreviewViewController
        controller.selectedImage = self.home[Int(sender.name ?? "0")!]
        navigationController?.pushViewController(controller, animated: true)
    }
}
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexpath: IndexPath)
        -> CGSize {
        return CGSize(width: (collectionView.frame.width/2) - 10, height: 300) //logic to specify fixed width and height
        
    }
}
extension HomeViewController: UICollectionViewDelegate{
    
}
