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

import Foundation

/// Provides the app with some sample data to start with.
class LogsSeed {
    
    class func preload() {
        
        let collection = LogStore.sharedStore.logCollection
        
        let intro_date = NSDate()
        let intro_text = "I was lucky to get a WWDC15 ticket this year. I expect a lot about the Apple Watch software developer kit."
        let intro_log = TextLog(text: text1, date: date1)
        collection.addLog(intro_log)
        
        let moscone_date  = intro_date.dateByAddingTimeInterval(3400)
        let moscone_image = UIImage("moscon-west")!
        let moscone_log = ImageLog(image: moscone_image, date: moscone_date)
        collection.addLog(moscone_log)
        
        let meet_ray_date = intro_date.dateByAddingTimeInterval(457800)
        let meet_ray_text = "I met Ray and some RW Tutorial Team members today in San Francisco!"
        let meet_ray_log = TextLog(text: meet_ray_text, date: meet_ray_date)
        collection.addLog(meet_ray_log)
        
        let meet_ray_image = UIImage(named: "ray-and-friends")!
        let meet_ray_image_log = ImageLog(image: meet_ray_image, date: meet_ray_date)
        collection.addLog(meet_ray_image_log)
        
        LogStore.sharedStore.save()
    }
}