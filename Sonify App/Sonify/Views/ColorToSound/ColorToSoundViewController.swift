//
//  ColorToSoundViewController.swift
//  Sonify
//
//  Created by Meghan Blyth on 25/07/2021.
//

import UIKit
import AVFoundation

class ColorToSoundViewController: UIViewController {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var targetView: UIImageView!
    @IBOutlet weak var instructionLbl: UILabel!
    
    private var liveModeOn = false      //the first time the page is opened the sound is turned off
    
    override func viewDidLoad() {
        super.viewDidLoad()

        closeBtn.layer.zPosition = 2
        targetView.layer.zPosition = 2
        prepScanCamera()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.toggleLiveMode))      //tap gesture added to conifirm allowing sound.
        previewView.addGestureRecognizer(tap)
    }
    
    deinit {
        setPlaybackStateTo(false)
    }
    //colour conversion start / stop
    @objc private func toggleLiveMode() {
        liveModeOn = !liveModeOn            //true becomes false or false becomes true
        setPlaybackStateTo(liveModeOn)
        instructionLbl.isHidden = liveModeOn        //instructions for the user. Sound is being produced.If live mode is true, the user won't be asked to click on live mode.
        targetView.isHidden = !liveModeOn           //target is only visible when true and live mode on.
    }
    
    @objc private func setPlaybackStateTo(_ state: Bool) {  //use synth class to 0.5 amplitude if true and 0 if false.
        Synth.shared.volume = state ? 0.5 : 0
        if !state { Synth.shared.frequency = 0 }            //checking that false = audio freq 0.
    }
    
    private func setSynthParametersFrom(_ coord: CGPoint) {
        Oscillator.amplitude = Float((view.bounds.height - coord.y) / view.bounds.height)   //Oscillator requires amplitude.
        Synth.shared.frequency = Float(coord.x / view.bounds.width) * 1014 + 32            //Synth requires the frequency.
        
        let amplitudePercent = Int(Oscillator.amplitude * 100)
        let frequencyHertz = Int(Synth.shared.frequency)
        
        print("Frequency: \(frequencyHertz) Hz  Amplitude: \(amplitudePercent)%")
    }
    
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func prepScanCamera() {
        captureSession = AVCaptureSession()
        let metadataOutput = AVCaptureMetadataOutput()
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: .main)
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput),
              captureSession.canAddOutput(metadataOutput),
              captureSession.canAddOutput(videoOutput) else {
            print("Your device does not support scanning a code from an item. Please use a device with a camera.")
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.captureSession.addInput(videoInput)
            self.captureSession.addOutput(metadataOutput)
            self.captureSession.addOutput(videoOutput)
            
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer.frame = self.view.layer.bounds
                self.previewLayer.videoGravity = .resizeAspectFill
                self.previewView.layer.addSublayer(self.previewLayer)
                self.startScanning()
            }
        }
    }
    
    func stopScanning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func startScanning() {
        guard captureSession != nil else {
            prepScanCamera()
            return
        }
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
}
//target for colour.
extension ColorToSoundViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        let image = self.convert(cmage: ciimage)
        
        let heightInPoints = image.size.height
        let heightInPixels = (heightInPoints * image.scale) / 2

        let widthInPoints = image.size.width
        let widthInPixels = (widthInPoints * image.scale) / 2
        
        let (color, x, y) = image.getPixelColor(pos: CGPoint(x: widthInPixels, y: heightInPixels))
        targetView.tintColor = color
        setSynthParametersFrom(.init(x: x, y: y))               
    }
    
    func convert(cmage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(cmage, from: cmage.extent)!
        let image = UIImage(cgImage: cgImage)
        return image
    }
}
