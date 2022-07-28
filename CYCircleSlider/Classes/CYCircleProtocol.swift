//
//  CYCircleProtocol.swift
//  CYCircleSlider_Example
//
//  Created by careyang on 26/7/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CYCircleSlider

@objc public protocol CYCircleProtocol: NSObjectProtocol {

    @objc optional func circularSlider(_ circularSlider: CYCircleSlider, valueForValue value: Float) -> Float

    @objc optional func circularSlider(_ circularSlider: CYCircleSlider, didBeginEditing textfield: UITextField)

    @objc optional func circularSlider(_ circularSlider: CYCircleSlider, didEndEditing textfield: UITextField)

    //  optional func circularSlider(circularSlider: CircularSlider, attributeTextForValue value: Float) -> NSAttributedString
}
