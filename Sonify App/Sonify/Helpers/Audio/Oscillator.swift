//
//  Oscillator.swift
//  Swift Synth
//
//  Created by Grant Emerson on 7/21/19.
//  Copyright © 2019 Grant Emerson. All rights reserved.
//
// Five type wave form Oscillator in Swift.


import Foundation

typealias Signal = (_ frequency: Float, _ time: Float) -> Float

enum Waveform: Int {
    case sine, triangle, sawtooth, square, whiteNoise
}

struct Oscillator {
    
    static var amplitude: Float = 1
    //Sine wave oscillator
    static let sine: Signal = { frequency, time in
        return Oscillator.amplitude * sin(2.0 * Float.pi * frequency * time)
    }
  //triangle wave oscillator 
    static let triangle: Signal = { frequency, time in
        let period = 1.0 / Double(frequency)
        let currentTime = fmod(Double(time), period)
        
        let value = currentTime / period
        
        var result = 0.0
        if value < 0.25 {
            result = value * 4
        } else if value < 0.75 {
            result = 2.0 - (value * 4.0)
        } else {
            result = value * 4 - 4.0
        }
        
        return Oscillator.amplitude * Float(result)
    }
    // Sawtooth wave oscillator
    static let sawtooth: Signal = { frequency, time in
        let period = 1.0 / frequency
        let currentTime = fmod(Double(time), Double(period))
        return Oscillator.amplitude * ((Float(currentTime) / period) * 2 - 1.0)
    }
   //square wave oscillator
    static let square: Signal = { frequency, time in
        let period = 1.0 / Double(frequency)
        let currentTime = fmod(Double(time), period)
        return ((currentTime / period) < 0.5) ? Oscillator.amplitude : -1.0 * Oscillator.amplitude
    }
    //white noise oscillator
    static let whiteNoise: Signal = { frequency, time in
        return Oscillator.amplitude * Float.random(in: -1...1)
    }
}
