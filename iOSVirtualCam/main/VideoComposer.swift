import Cocoa
import AVFoundation

@objc
protocol VideoComposerDelegate: AnyObject {
    func videoComposer(_ composer: VideoComposer, didComposeImageBuffer imageBuffer: CVImageBuffer)
}

@objcMembers
class VideoComposer: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    weak var delegate: VideoComposerDelegate?

    private let cameraCapture = CameraCapture()
    private let context = CIContext()
    private var settingsTimer: Timer?


    private let CVPixelBufferCreateOptions: [String: Any] = [
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        kCVPixelBufferIOSurfacePropertiesKey as String: [:]
    ]

    deinit {
        stopRunning()
    }

    func startRunning() {
        log("VideoComposer:startRunning")
        cameraCapture.output.setSampleBufferDelegate(self, queue: .main)
        cameraCapture.startRunning()
    }

    func stopRunning() {
        log("VideoComposer:stopRunning")
        settingsTimer?.invalidate()
        settingsTimer = nil
        cameraCapture.stopRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        log("VideoComposer:captureOutput")
        if output == cameraCapture.output {
            log("VideoComposer:captureOutput1")

            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            log("VideoComposer:captureOutput2")
            let cameraImage = CIImage(cvImageBuffer: imageBuffer)

            var pixelBuffer: CVPixelBuffer?

            _ = CVPixelBufferCreate(
                kCFAllocatorDefault,
                Int(cameraImage.extent.size.width),
                Int(cameraImage.extent.height),
                kCVPixelFormatType_32BGRA,
                self.CVPixelBufferCreateOptions as CFDictionary,
                &pixelBuffer
            )

            if let pixelBuffer = pixelBuffer {
                context.render(cameraImage, to: pixelBuffer)
                delegate?.videoComposer(self, didComposeImageBuffer: pixelBuffer)
            }
        }
    }
}
