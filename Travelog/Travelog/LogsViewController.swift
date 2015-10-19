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

class LogsViewController: UITableViewController, DetailViewControllerPresenter {
  
  @IBOutlet var photoLibraryButton: UIBarButtonItem!
  @IBOutlet var cameraButton: UIBarButtonItem!
  @IBOutlet var addNoteButton: UIBarButtonItem!
  
  var user: User!
  var logs = [BaseLog]()
  var selectedLog: BaseLog?
  var selectedIndexPath: NSIndexPath?
  let ref = Firebase(url: "https://logtravel.firebaseio.com")
  var fbDataSource: FirebaseDataSource!
  var handle: UInt!
  
  // MARK: View Life Cycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    splitViewController?.preferredDisplayMode = .AllVisible
    splitViewController?.delegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)
    
    let hasCamera = UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) ||
      UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)
    cameraButton.enabled = hasCamera
    
    tableView.cellLayoutMarginsFollowReadableWidth = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if clearsSelectionOnViewWillAppear == true {
      selectedIndexPath = nil
      selectedLog = nil
    } else if let selectedIndexPath = selectedIndexPath {
      tableView.scrollToRowAtIndexPath(selectedIndexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
    }
    
    // Sync log data when view is visible
    let userLogsRef = ref.childByAppendingPath("userLogs").childByAppendingPath(user.uid)
    
    handle = userLogsRef.observeEventType(.Value) { (snap: FDataSnapshot!) in
      
      var newLogs = [BaseLog]()
      
      for child in snap.children {
        let childSnap = child as! FDataSnapshot
        newLogs.append(TextLog(snap: childSnap))
      }
      
      self.logs = newLogs
      self.tableView.reloadData()
    }
    
    // Online users
    let onlineRef = ref.childByAppendingPath("online").childByAppendingPath(user.uid)
    onlineRef.onDisconnectRemoveValue()
    onlineRef.setValue(true)
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    // Remove listener when view disappears
    ref.removeObserverWithHandle(handle)
  }
  
  // MARK: IBActions
  
  @IBAction func photoLibraryButtonTapped(sender: UIBarButtonItem?) {
    presentImagePickerControllerWithSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
  }
  
  @IBAction func cameraButtonTapped(sender: UIBarButtonItem?) {
    presentImagePickerControllerWithSourceType(UIImagePickerControllerSourceType.Camera)
  }
  
  @IBAction func addNoteButtonTapped(sender: UIBarButtonItem?) {
    presentTextViewController(nil)
  }
  
  //// A helper method to configure and display image picker controller based on the source type.
  func presentImagePickerControllerWithSourceType(sourceType: UIImagePickerControllerSourceType) {
    let controller = UIImagePickerController()
    controller.delegate = self
    controller.sourceType = sourceType
    controller.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
    controller.view.tintColor = UIColor.themeTineColor()
    if sourceType == UIImagePickerControllerSourceType.PhotoLibrary {
      controller.modalPresentationStyle = .Popover
      let presenter = controller.popoverPresentationController
      presenter?.sourceView = view
      presenter?.barButtonItem = photoLibraryButton
      presenter?.delegate = self
    }
    presentViewController(controller, animated: true, completion: nil)
  }
  
  // MARK: DetailViewControllerPresenter
  
  func detailViewController(vc: DetailViewController, requestsPresentingPhotoEditorForLog log: BaseLog, withSourceType type: UIImagePickerControllerSourceType) {
    presentImagePickerControllerWithSourceType(type)
  }
  
  func detailViewController(vc: DetailViewController, requestsPresentingTextEditorForLog log: BaseLog) {
    guard let textLog = log as? TextLog else { return }
    presentTextViewController(textLog.text)
  }
  
}

extension LogsViewController : UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    
    guard traitCollection.userInterfaceIdiom == .Pad else {
      return .FullScreen
    }
    
    if splitViewController?.view.bounds.width > 320 {
      return .None
    } else {
      return .FullScreen
    }
  }
}
