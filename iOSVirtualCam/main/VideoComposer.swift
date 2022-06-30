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
        
        if output == cameraCapture.output {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            
            // 1980x1080に収まるように縮小変換
            guard let pixcelbuffer = ciImage.resizeInContainer(container: Stream.size)?.pixelBuffer(cgSize: Stream.size) else { return }
            
            delegate?.videoComposer(self, didComposeImageBuffer: pixcelbuffer)
        }
    }
    
}
