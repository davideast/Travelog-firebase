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

import AVFoundation
import AVKit
import MobileCoreServices
import UIKit

extension LogsViewController {
  
  // MARK: UITableView data source and delegate
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return logs.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LogCellIdentifier", forIndexPath: indexPath) as! LogCell
    let log = logs[indexPath.row]
    cell.setLog(log)
    cell.selected = (log == selectedLog)
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let newlySelectedLog = logs[indexPath.row]
    if selectedLog == newlySelectedLog {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      selectedLog = nil
      selectedIndexPath = nil
    } else {
      selectedLog = newlySelectedLog
      selectedIndexPath = indexPath
    }
    presentDetailViewControllerWithSelectedLog(selectedLog)
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.Delete
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      let log = logs[indexPath.row]
      deleteLog(log)
    }
  }
  
}

extension LogsViewController {
  
  // MARK: Helper
  
  /// Present a text view controller. Optionally you may pass in a text object to be edited.
  func presentTextViewController(textToEdit: String?) {
    guard let textViewNavigationController = storyboard?.instantiateViewControllerWithIdentifier("TextViewNavigationController") as? UINavigationController else { return }
    guard let controller = textViewNavigationController.viewControllers.first as? TextViewController else { return }
    unowned let weakSelf = self
    controller.saveActionBlock = { (text: String) -> () in
      
      let textLogToSave: TextLog
      
      // If it was an edit to the existing log, update the log.
      if let selectedLog = weakSelf.selectedLog {
        textLogToSave = TextLog(text: text, date: selectedLog.date)
      } else {
        // It is a new note (text log).
        textLogToSave = TextLog(text: text, date: NSDate())
      }
      
      // Save it.
      let entryRef = self.ref.childByAppendingPath("userLogs").childByAppendingPath(self.user.uid).childByAutoId()
      entryRef.setValue(textLogToSave.toAnyObject())
      
      // Transaction Save
      let totalPostsRef = self.ref.childByAppendingPath("totalPosts")
      
      totalPostsRef.runTransactionBlock({
        (currentData:FMutableData!) in
        var value = currentData.value as? Int
        if !(value != nil) {
          value = 0
        }
        currentData.value = value! + 1
        return FTransactionResult.successWithValue(currentData)
      })
      
      weakSelf.dismissViewControllerAnimated(true, completion: nil)
      weakSelf.selectedLog = textLogToSave
      weakSelf.presentDetailViewControllerWithSelectedLog(textLogToSave)
    }
    controller.cancelActionBlock = {
      weakSelf.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Present text view controller and pass on the textToEdit if any.
    // Otherwise provide a placeholder.
    textViewNavigationController.modalPresentationStyle = .FormSheet
    presentViewController(textViewNavigationController, animated: true) { () -> Void in
      if let textToEdit = textToEdit { controller.setText(textToEdit) }
      else { controller.setText("Today, I'm going to write about ...") }
    }
  }
  
  /// Create or reuse a Detail View Controller object.
  func detailViewController() -> DetailViewController {
    if splitViewController?.traitCollection.horizontalSizeClass == .Compact {
      let detailViewController = storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
      return detailViewController
    }
    
    let navController = splitViewController?.viewControllers.last as! UINavigationController
    let detailViewController = navController.viewControllers.first as! DetailViewController
    return detailViewController
  }
  
  /// Present DetailViewController with a given log.
  /// For convenience, returns a pointer to the controller that's just presented.
  func presentDetailViewControllerWithSelectedLog(log: BaseLog?) -> DetailViewController {
    let vc = detailViewController()
    vc.selectedLog = log
    vc.delegate = self
    navigationController?.popViewControllerAnimated(false)
    showDetailViewController(vc, sender: nil)
    return vc
  }
  
  func deleteLog(log: BaseLog) {
    
    // Delete log
    if let deleteRef = log.ref {
      deleteRef.removeValue()
    }
    
    let totalPostsRef = self.ref.childByAppendingPath("totalPosts")
    
    totalPostsRef.runTransactionBlock({
      (currentData:FMutableData!) in
      var value = currentData.value as? Int
      if !(value != nil) {
        value = 0
      }
      currentData.value = value! - 1
      return FTransactionResult.successWithValue(currentData)
    })
    
    if selectedLog == log && splitViewController?.traitCollection.horizontalSizeClass == .Regular {
      selectedIndexPath = nil
      let vc = detailViewController()
      vc.selectedLog = nil
    }
  }
  
}

extension LogsViewController: UISplitViewControllerDelegate {
  
  func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
    if splitViewController.traitCollection.horizontalSizeClass == .Compact {
      let navigationController = splitViewController.viewControllers.first as! UINavigationController
      navigationController.pushViewController(vc, animated: true)
    }
    return true
  }
  
  func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
    clearsSelectionOnViewWillAppear = false
    let primaryNavController = primaryViewController as! UINavigationController
    primaryNavController.popToRootViewControllerAnimated(false)
    
    let detailNavigationController = storyboard!.instantiateViewControllerWithIdentifier("DetailNavigationController") as! UINavigationController
    let detailViewController = detailNavigationController.viewControllers.first as! DetailViewController
    detailViewController.selectedLog = selectedLog
    return detailNavigationController
  }
  
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
    clearsSelectionOnViewWillAppear = true
    if selectedIndexPath == nil {
      navigationController?.popToRootViewControllerAnimated(false)
      return true
    }
    return false
  }
  
}

extension LogsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  // MARK: UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    var logToSave: BaseLog?
    
    // What did user pick? Is it a movie or is it an image?
    let mediaType = info[UIImagePickerControllerMediaType] as! String
    if mediaType == String(kUTTypeImage) {
      let image = info[UIImagePickerControllerOriginalImage] as! UIImage
      
      // If it was an edit to the existing log, update the log.
      if let selectedLog = selectedLog {
        logToSave = ImageLog(image: image, date: selectedLog.date)
      } else {
        // It is a new image log.
        logToSave = ImageLog(image: image, date: NSDate())
      }
    } else if mediaType == String(kUTTypeMovie) {
      let assetURL = info[UIImagePickerControllerMediaURL] as! NSURL
      let previewImage = snapshotFromMovieAtURL(assetURL)
      
      // If it was an edit to the existing log, update the log.
      if let selectedLog = selectedLog {
        logToSave = VideoLog(URL: assetURL, previewImage: previewImage, date: selectedLog.date)
      } else {
        // It is a new image log.
        logToSave = VideoLog(URL: assetURL, previewImage: previewImage, date: NSDate())
      }
    }
    
    picker.dismissViewControllerAnimated(false, completion: nil)
    
    // Save it.
    
  }
  
  /// Create an snapshot of a movie at a given URL and return UIImage.
  func snapshotFromMovieAtURL(movieURL: NSURL) -> UIImage {
    let asset = AVAsset(URL: movieURL)
    let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time: CMTime = CMTimeMake(1, 60)
    do {
      let imageRef: CGImageRef = try generator.copyCGImageAtTime(time, actualTime: nil)
      let snapshot = UIImage(CGImage: imageRef)
      return snapshot
    }
    catch {}
    return UIImage()
  }
  
}