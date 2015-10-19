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

public class BaseLog: NSObject, NSCoding {
  
  public let date: NSDate
  public var ref: Firebase?
  
  public init(snap: FDataSnapshot) {
    let stamp = snap.value["date"] as! NSTimeInterval
    date = NSDate(timeIntervalSince1970: stamp/1000)
    ref = snap.ref
    super.init()
  }
  
  public init(date: NSDate) {
    self.date = date
    super.init()
  }
  
  // MARK: NSCoding
  
  public required init?(coder aDecoder: NSCoder) {
    self.date = aDecoder.decodeObjectForKey("date") as! NSDate
    super.init()
  }
  
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.date, forKey: "date")
  }
  
  func toAnyObject() -> AnyObject {
    return [
      "date": date.timeIntervalSince1970 * 1000
    ]
  }
  
}

public class TextLog: BaseLog {
  
  public let text: String
  
  public override init(snap: FDataSnapshot) {
    text = snap.value["text"] as! String
    super.init(snap: snap)
  }
  
  public init(text: String, date: NSDate) {
    self.text = text
    super.init(date: date)
  }
  
  // MARK: NSCoding
  
  public required init?(coder aDecoder: NSCoder) {
    self.text = aDecoder.decodeObjectForKey("text") as! String
    super.init(coder: aDecoder)
  }
  
  public override func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.text, forKey: "text")
    super.encodeWithCoder(aCoder)
  }
  
  override func toAnyObject() -> AnyObject {
    return [
      "date": date.timeIntervalSince1970 * 1000,
      "text": text
    ]
  }
  
}

public class ImageLog: BaseLog {
  
  public let image: UIImage
  
  public required init(image: UIImage, date: NSDate) {
    self.image = image
    super.init(date: date)
  }
  
  // MARK: NSCoding
  
  public required init?(coder aDecoder: NSCoder) {
    let data = aDecoder.decodeObjectForKey("image") as! NSData
    let image = UIImage(data: data)!
    self.image = image
    super.init(coder: aDecoder)
  }
  
  public override func encodeWithCoder(aCoder: NSCoder) {
    let data = UIImageJPEGRepresentation(self.image, 1.0)
    aCoder.encodeObject(data, forKey: "image")
    super.encodeWithCoder(aCoder)
  }
  
}

public class VideoLog: BaseLog {
  
  public let URL: NSURL
  public let previewImage: UIImage
  
  public required init(URL: NSURL, previewImage: UIImage, date: NSDate) {
    self.URL = URL
    self.previewImage = previewImage
    super.init(date: date)
  }
  
  // MARK: NSCoding
  
  public required init?(coder aDecoder: NSCoder) {
    self.URL = aDecoder.decodeObjectForKey("URL") as! NSURL
    let data = aDecoder.decodeObjectForKey("previewImage") as! NSData
    let image = UIImage(data: data)!
    self.previewImage = image
    super.init(coder: aDecoder)
  }
  
  public override func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.URL, forKey: "URL")
    let data = UIImageJPEGRepresentation(self.previewImage, 1.0)
    aCoder.encodeObject(data, forKey: "previewImage")
    super.encodeWithCoder(aCoder)
  }
  
}