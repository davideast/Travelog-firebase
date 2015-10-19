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

class TextViewController: UIViewController {
  
  @IBOutlet private var textView: UITextView!
  
  // MARK: ActionProtocol
  
  typealias SaveActionBlock = ((text: String) -> Void)
  typealias CancelActionBlock = (() -> Void)
  
  var saveActionBlock: SaveActionBlock?
  var cancelActionBlock: CancelActionBlock?
  
  // MARK: Public
  
  func setText(text: String?) {
    textView.text = text
  }
  
  // MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Position text view respecting the readableContentGuide.
    let readableContentGuide = view.readableContentGuide
    var constraints = view.constraints
    constraints += [
      textView.leadingAnchor.constraintEqualToAnchor(readableContentGuide.leadingAnchor),
      textView.trailingAnchor.constraintEqualToAnchor(readableContentGuide.trailingAnchor),
    ]
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  override func viewDidAppear(animated: Bool) {
    textView.becomeFirstResponder()
  }
  
  // MARK: IBActions
  
  @IBAction func cancelButtonTapped(sender: UIBarButtonItem?) {
    guard let cancelActionBlock = cancelActionBlock else { return }
    cancelActionBlock()
  }
  
  @IBAction func saveButtonTapped(sender: UIBarButtonItem?) {
    guard let saveActionBlock = saveActionBlock else { return }
    saveActionBlock(text: textView.text)
  }
  
}