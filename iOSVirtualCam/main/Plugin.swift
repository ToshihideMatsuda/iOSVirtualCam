import Foundation

class Plugin: Object {
    var objectID: CMIOObjectID = 0
    let name = "iOSVirtualCam"

    lazy var properties: [Int : Property] = [
        kCMIOObjectPropertyName: Property(name),
    ]
}
