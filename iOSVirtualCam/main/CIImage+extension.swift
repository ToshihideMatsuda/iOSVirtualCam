//
//  CIImage+extension.swift
//  iOSVirtualCam
//
//  Created by tmatsuda on 2022/06/30.
//
//

import Foundation
import CoreImage

fileprivate let ciContext = CIContext()

extension CIImage {

    func pixelBuffer(cgSize size:CGSize, pixcelFormat:OSType = kCVPixelFormatType_32BGRA) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
          
        let width:Int = Int(size.width)
        let height:Int = Int(size.height)

        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            pixcelFormat,
                            attrs,
                            &pixelBuffer)

        // put bytes into pixelBuffer
        ciContext.render(self, to: pixelBuffer!)
        return pixelBuffer

    }
    
    func resizeInContainer(container:CGSize, resizeQ:CGSize?=nil) -> CIImage? {
        let resize:CGSize = resizeQ ?? container
        var image = self

        do {
            let scale = min(resize.width / image.extent.width, resize.height / image.extent.height)
            image = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        }

        //container分の透明なフチを確保
        let point = CGPoint(x: (image.extent.width  - container.width)/2,
                            y: (image.extent.height - container.height)/2)
        let rect:CGRect = CGRect.init(origin: point, size: container)
        guard let cgImage = ciContext.createCGImage(image, from: rect) else { return nil }
        return CIImage(cgImage: cgImage)
        
    }


    func resize(as size: CGSize) -> CIImage {
        let selfSize = extent.size
        let transform = CGAffineTransform(scaleX: size.width / selfSize.width, y: size.height / selfSize.height)
        return transformed(by: transform)
    }

}
