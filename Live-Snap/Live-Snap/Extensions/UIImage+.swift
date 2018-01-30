//
//  UIImage+.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/11/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit
import GPUImage

extension UIImage {
    
    public convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(cgImage: image?.cgImage ?? UIImage().cgImage!)
    }
    
    func resized(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
    
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
    
    func iOSBlurred() -> UIImage {
        
        let blurFilter = GPUImageiOSBlurFilter()
        blurFilter.blurRadiusInPixels = 30.0
        return blurFilter.image(byFilteringImage: self)
    }
    
    func darkenedAndBlurred(darkness: Double, blurRadius: Int) -> UIImage? {
        
        guard let cgImage = cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        guard let blurredCIImage = blurFilter.outputImage else { return nil }
        
        guard let darknessFilter = CIFilter(name: "CIColorControls") else { return nil }
        darknessFilter.setValue(blurredCIImage, forKey: kCIInputImageKey)
        darknessFilter.setValue(-darkness, forKey: kCIInputBrightnessKey)
        
        guard let darkenedCIImage = darknessFilter.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        if let newCGImage = context.createCGImage(darkenedCIImage, from: ciImage.extent) {
            return UIImage(cgImage: newCGImage)
        }
        
        return nil
    }
    
    func blurred(blurRadius: Int) -> UIImage? {
        
        guard let cgImage = cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let context = CIContext(options: nil)
        if let outputImage = filter.outputImage, let newCGImage = context.createCGImage(outputImage, from: ciImage.extent) {
            return UIImage(cgImage: newCGImage)
        }
        
        return nil
    }
    
    func darkened(darkness: Double) -> UIImage? {
        
        guard let cgImage = cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(-darkness, forKey: kCIInputBrightnessKey)
        
        let context = CIContext(options: nil)
        if let outputImage = filter.outputImage, let newCGImage = context.createCGImage(outputImage, from: ciImage.extent) {
            return UIImage(cgImage: newCGImage)
        }
        
        return nil
    }
}
