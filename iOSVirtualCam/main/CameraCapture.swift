import Cocoa
import AVFoundation

@objcMembers
class CameraCapture: NSObject {

    private let session = AVCaptureSession()
    let output = AVCaptureVideoDataOutput()
    private var observer: NSObjectProtocol?

    override init() {
        super.init()
        log()
        session.sessionPreset = .high
    }
    
    private func configureDevice(device: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.inputs.forEach{ session.removeInput($0) }
            session.outputs.forEach{ session.removeOutput($0) }
            if session.canAddInput(input) {
                session.addInput(input)
                if session.canAddOutput(output) {
                    output.alwaysDiscardsLateVideoFrames = true
                    session.addOutput(output)
                }
            }
        } catch {
            print(error)
        }
    }
    

    func startRunning() {
        log("CameraCapture")
        // opt-in settings to find iOS physical devices
        var prop = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
        var allow: UInt32 = 1;
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &prop, 0, nil, UInt32(MemoryLayout.size(ofValue: allow)), &allow)
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: nil, position: .unspecified).devices
        
        log("devices.count are \(devices.count)")
        devices.forEach{log($0)}
        // configure device if found, or wait notification
        if let device = devices.filter({ $0.modelID == "iOS Device" && $0.manufacturer == "Apple Inc." }).last {
            log(device)
            self.configureDevice(device: device)
        } else {
            observer = NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: .main) { (notification) in
                log("AVCaptureDeviceWasConnected")
                log(notification)
                guard let device = notification.object as? AVCaptureDevice else { return }
                self.configureDevice(device: device)
            }
        }
        
        session.startRunning()
    }

    func stopRunning() {
        session.stopRunning()
    }
}
