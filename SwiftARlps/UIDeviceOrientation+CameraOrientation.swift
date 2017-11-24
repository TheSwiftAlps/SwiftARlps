//
//  UIDeviceOrientation+CameraOrientation.swift
//  SwiftARlps
//
//  Created by Eran Jalink on 24/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

extension UIDeviceOrientation {
    func cameraOrientation() -> CGImagePropertyOrientation {
        switch self {
        case .landscapeLeft: return .up
        case .landscapeRight: return .down
        case .portraitUpsideDown: return .left
        default: return .right
        }
    }
}
