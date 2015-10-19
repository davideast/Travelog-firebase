/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

@IBDesignable
class BorderedImageView: UIImageView {
  
  var maskLayer: CAShapeLayer?
  var maskLayerRect = CGRect()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if !CGRectEqualToRect(maskLayerRect, bounds) {
      maskLayer?.removeFromSuperlayer()
      maskLayer = nil
    }
    
    if maskLayer == nil {
      let outterPath = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
      let innerRect = CGRectInset(bounds, 4, 4)
      let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: 10)
      outterPath.appendPath(innerPath)
      outterPath.usesEvenOddFillRule = true
      
      maskLayer = CAShapeLayer()
      maskLayer!.path = outterPath.CGPath
      maskLayer!.fillRule = kCAFillRuleEvenOdd;
      maskLayer!.fillColor = UIColor.whiteColor().CGColor
      maskLayer!.opacity = 1.0
      
      layer.masksToBounds = true
      layer.addSublayer(maskLayer!)
      
      maskLayerRect = bounds
    }
  }
}