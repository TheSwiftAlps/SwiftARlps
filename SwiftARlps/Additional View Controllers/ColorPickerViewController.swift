/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility class for showing messages above the AR view.
*/

import Foundation
import ARKit
import CoreGraphics

protocol ColorPickerViewControllerDelegate: class {
    func colorPicked(color: UIColor)
}

class ColorPickerViewController: UIViewController {
    weak var delegate: ColorPickerViewControllerDelegate?
    
    @IBOutlet private var button: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for buttonColor in button {
            buttonColor.addTarget(self, action: #selector(colorPicked(button:)), for: .touchUpInside)
            buttonColor.layer.borderWidth = 1
            buttonColor.layer.borderColor = UIColor.lightGray.cgColor
            buttonColor.layer.cornerRadius = buttonColor.frame.size.width/2
        }
    }
    
    @objc func colorPicked(button: UIButton) {
        delegate?.colorPicked(color: button.backgroundColor!)
        dismiss(animated: true, completion: nil)
    }
}
