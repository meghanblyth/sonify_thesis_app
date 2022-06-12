//
//  AudioPreviewViewController.swift
//  Sonify
//
//  Created by Meghan Blyth on 30/07/2021.
//

import UIKit
import AVFoundation
import Pulsator
import ProgressHUD

class AudioPreviewViewController: UIViewController {
    
    static let identifier = "AudioPreviewViewController"

    @IBOutlet weak var sonifiedImageView: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    
    let pulsator = Pulsator()
    var selectedImage: Home?
    var isPlayingAudio = false
    var progressLink: CADisplayLink? = nil
    
    var audioPlayer: AVMIDIPlayer? //To take midi from the python VM and play in IOS
    var soundbank: URL?           //Using sound bank from resources folder to play MIDI
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIView!
    var isDraggingAudio = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurePulse()
        populateView()
        setupAudio()
        progressView.roundCorners(corners: [.topRight, .bottomRight], radius: 10)
        addPanGesture()
    }
    
    private func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        pan.delegate = self
        progressView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            isDraggingAudio = true
            processProgressMovement(sender: sender, view: progressView)
        case .ended:
            isDraggingAudio = false
            let progress = Double(progressWidthConstraint.constant / view.frame.width)
            moveToPointInAudio(time: progress * (audioPlayer?.duration ?? 0))
        break
        default: break
        }
    }
    
    func processProgressMovement(sender: UIPanGestureRecognizer, view: UIView) {
        let translation = sender.translation(in: view)
        progressWidthConstraint.constant = progressWidthConstraint.constant + translation.x
        sender.setTranslation(.zero, in: view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupProgressLink()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        progressLink?.invalidate()
    }
    
    private func setupProgressLink() {
        progressLink = CADisplayLink(target: self,
                                     selector: #selector(playerProgress))
        if let progressLink = progressLink {
            progressLink.preferredFramesPerSecond = 2
            progressLink.add(to: RunLoop.current, forMode: .default)
        }
    }
    
    deinit {
        audioPlayer?.stop()
        pulsator.stop()
        print("Deinitialized")
    }
    
    private func setupAudio() {
        do {
            self.soundbank = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2")
            guard let audioUrl = selectedImage?.name.fullPathFromDocuments else { return }
            print("Audio path: \(audioUrl)")
            audioPlayer = try AVMIDIPlayer(contentsOf: audioUrl, soundBankURL: soundbank)
            audioPlayer?.prepareToPlay()
        } catch {
            ProgressHUD.showError(error.localizedDescription)
        }
    }
    
    @objc func playerProgress() {
        var progress = CGFloat(0)
        if let audioPlayer = audioPlayer {
            progress = ((audioPlayer.duration > 0)
                            ? CGFloat(audioPlayer.currentPosition/audioPlayer.duration)
                            : 0)
        }
        if !isDraggingAudio {
            progressWidthConstraint.constant = progress * view.frame.width
        }
    }
    
    private func configurePulse() {
        pulsator.backgroundColor = CGColor(srgbRed: 89/255, green: 199/255, blue: 184/255, alpha: 1)
        playBtn.layer.superlayer?.insertSublayer(pulsator, below: playBtn.layer)
        pulsator.numPulse = 5
        pulsator.radius = 200
        pulsator.animationDuration = 5.6
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = playBtn.layer.position
    }
    
    private func populateView() {
        sonifiedImageView.image = selectedImage?.image
    }
    
    @IBAction func playBtnClicked(_ sender: UIButton) {
        isPlayingAudio = !isPlayingAudio
        
        if isPlayingAudio {
            pulsator.start()
            playBtn.setImage(UIImage(named: "stop"), for: .normal)
            
            self.audioPlayer?.play({ [weak self] () -> Void in
                self?.resetAudio()
            })
        } else {
            resetAudio()
        }
    }
    
    private func resetAudio() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isPlayingAudio = false
            self.pulsator.stop()
            self.audioPlayer?.currentPosition = 0
            self.playBtn.setImage(UIImage(named: "play"), for: .normal)
            
            if self.audioPlayer?.isPlaying ?? false {
                self.audioPlayer?.stop()
            }
        }
    }
    
    private func moveToPointInAudio(time: TimeInterval) {
        audioPlayer?.currentPosition = time
    }
}

extension AudioPreviewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
