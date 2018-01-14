//
//  UIImage+.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/11/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit

extension UIImage {
    
    func pixelBuffer() -> CVPixelBuffer? {
        
        guard let cgImage = self.cgImage else { return nil }
        
        let options: [String : Any] = [kCVPixelBufferCGImageCompatibilityKey as String : true, kCVPixelBufferCGBitmapContextCompatibilityKey as String : true]
    
        let frameWidth = Int(cgImage.width)
        let frameHeight = Int(cgImage.height)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, frameWidth, frameHeight, kCVPixelFormatType_32ARGB, options as CFDictionary?, &pixelBuffer)
        
        guard (status == kCVReturnSuccess) && (pixelBuffer != nil) else { return nil }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(data: pixelData, width: frameWidth, height: frameHeight, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { return nil }
        
        context.concatenate(CGAffineTransform.identity)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
