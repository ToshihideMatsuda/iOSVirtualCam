//
//  Main.swift
//  iOSVirtualCam
//
//  Created by tmatsuda on 2022/06/29.
//

import Foundation
import CoreMediaIO

@_cdecl("iOSVirtualCamMain")
func iOSVirtualCamMain(allocator: CFAllocator, requestedTypeUUID: CFUUID) -> CMIOHardwarePlugInRef {
    return pluginRef
}
