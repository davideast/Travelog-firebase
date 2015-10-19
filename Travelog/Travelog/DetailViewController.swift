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
import UIKit

protocol DetailViewControllerPresenter: NSObjectProtocol {
  func detailViewController(vc: DetailViewController, requestsPresentingTextEditorForLog log: BaseLog)
  func detailViewController(vc: DetailViewController, requestsPresentingPhotoEditorForLog log: BaseLog, withSourceType type: UIImagePickerControllerSourceType)
}

enum DetailViewState {
  case DisplayNone
  case DisplayTextLog
  case DisplayImageLog
  case DisplayVideoLog
}

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet private var photoLibraryButton: UIBarButtonItem!
  @IBOutlet private var cameraButton: UIBarButtonItem!
  @IBOutlet private var editButton: UIBarButtonItem!
  
  @IBOutlet private var textView: UITextView!
  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var errorView: UIView!
  @IBOutlet private var playButton: UIButton!
  
  let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .LongStyle
    formatter.timeStyle = .MediumStyle
    return formatter
    }()
  
  weak var delegate: DetailViewControllerPresenter?
  
  var selectedLog: BaseLog? {
    didSet {
      updateDetailView()
    }
  }
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let hasCamera = UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) ||
      UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)
    cameraButton.enabled = hasCamera
    setDetailViewState(DetailViewState.DisplayNone)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    updateDetailView()
  }
  
  // MARK: IBActions
  
  @IBAction func photoLibraryButtonTapped(sender: UIBarButtonItem?) {
    guard let selectedLog = selectedLog else { return }
    delegate?.detailViewController(self, requestsPresentingPhotoEditorForLog: selectedLog, withSourceType: UIImagePickerControllerSourceType.PhotoLibrary)
  }
  
  @IBAction func cameraButtonTapped(sender: UIBarButtonItem?) {
    guard let selectedLog = selectedLog else { return }
    delegate?.detailViewController(self, requestsPresentingPhotoEditorForLog: selectedLog, withSourceType: UIImagePickerControllerSourceType.Camera)
  }
  
  @IBAction func editButtonTapped(sender: UIBarButtonItem?) {
    guard let selectedLog = selectedLog else { return }
    delegate?.detailViewController(self, requestsPresentingTextEditorForLog: selectedLog)
  }
  
  @IBAction func playButtonTapped(sender: UIButton?) {
    guard let videoLog = selectedLog as? VideoLog else { return }
    playVideoAtURL(videoLog.URL)
  }
  
  // MARK: Private methods
  
  private func updateDetailView() {
    
    guard let textView = textView else { return }
    guard let imageView = imageView else { return }
    
    if let selectedLog = selectedLog {
      titleLabel.text = self.dateFormatter.stringFromDate(selectedLog.date).uppercaseString
    }
    
    if let selectedLog = selectedLog as? TextLog {
      textView.text = selectedLog.text
      setDetailViewState(DetailViewState.DisplayTextLog)
    } else if let selectedLog = selectedLog as? ImageLog {
      imageView.image = selectedLog.image
      setDetailViewState(DetailViewState.DisplayImageLog)
    } else if let selectedLog = selectedLog as? VideoLog {
      imageView.image = selectedLog.previewImage
      setDetailViewState(DetailViewState.DisplayVideoLog)
    } else {
      setDetailViewState(DetailViewState.DisplayNone)
      titleLabel.text = nil
    }
  }
  
  /// Set the state of the Detail View (show or hide UI elements that are relevant).
  private func setDetailViewState(state: DetailViewState) {
    // If it's a text log, update label and hide image view.
    // If it's an image log, update image view and hide label.
    // If it's neither of them, hide both label and image view.
    switch state {
    case .DisplayNone:
      errorView.hidden = false
      textView.hidden = true
      imageView.hidden = true
      titleLabel.hidden = true
      playButton.hidden = true
      
      textView.text = nil
      imageView.image = nil
      navigationItem.setRightBarButtonItems([], animated: true)
      
    case .DisplayTextLog:
      errorView.hidden = true
      textView.hidden = false
      imageView.hidden = true
      titleLabel.hidden = false
      playButton.hidden = true
      
      imageView.image = nil
      navigationItem.setRightBarButtonItems([editButton], animated: true)
      
    case .DisplayImageLog:
      errorView.hidden = true
      textView.hidden = true
      imageView.hidden = false
      titleLabel.hidden = false
      playButton.hidden = true
      
      textView.text = nil
      navigationItem.setRightBarButtonItems([photoLibraryButton, cameraButton], animated: true)
      
    case .DisplayVideoLog:
      errorView.hidden = true
      textView.hidden = true
      imageView.hidden = false
      titleLabel.hidden = false
      playButton.hidden = false
      
      textView.text = nil
      navigationItem.setRightBarButtonItems([photoLibraryButton, cameraButton], animated: true)
    }
  }
  
  /// Plays back a movie item using AVPlayerViewController that's presented modally.
  private func playVideoAtURL(URL: NSURL) {
    let controller = AVPlayerViewController()
    controller.player = AVPlayer(URL: URL)
    presentViewController(controller, animated: true) { () -> Void in
      controller.player?.play()
    }
  }
}
