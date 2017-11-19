/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for choosing virtual objects to place in the AR scene.
*/

import UIKit

// MARK: - ObjectCell

class ObjectCell: UITableViewCell {
    static let reuseIdentifier = "ObjectCell"
    
    @IBOutlet weak var objectTitleLabel: UILabel!
    @IBOutlet weak var objectImageView: UIImageView!
        
    var modelName = "" {
        didSet {
            objectTitleLabel.text = modelName.capitalized
            objectImageView.image = UIImage(named: modelName)
        }
    }
}

// MARK: - ModelObjectSelectionViewControllerDelegate

/// A protocol for reporting which objects have been selected.
protocol ModelObjectSelectionViewControllerDelegate: class {
    func modelObjectSelectionViewController(_ selectionViewController: ModelObjectSelectionViewController, didSelectObject: ModelObject)
    func modelObjectSelectionViewController(_ selectionViewController: ModelObjectSelectionViewController, didDeselectObject: ModelObject)
}

/// A custom table view controller to allow users to select `ModelObject`s for placement in the scene.
class ModelObjectSelectionViewController: UITableViewController {
    
    /// The collection of `ModelObject`s to select from.
    var modelObjects = [ModelObject]()
    
    /// The rows of the currently selected `ModelObject`s.
    var selectedModelObjectRows = IndexSet()
    
    weak var delegate: ModelObjectSelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 250, height: tableView.contentSize.height)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = modelObjects[indexPath.row]
        
        // Check if the current row is already selected, then deselect it.
        if selectedModelObjectRows.contains(indexPath.row) {
            delegate?.modelObjectSelectionViewController(self, didDeselectObject: object)
        } else {
            delegate?.modelObjectSelectionViewController(self, didSelectObject: object)
        }

        dismiss(animated: true, completion: nil)
    }
        
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelObjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as? ObjectCell else {
            fatalError("Expected `\(ObjectCell.self)` type for reuseIdentifier \(ObjectCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        cell.modelName = modelObjects[indexPath.row].modelName

        if selectedModelObjectRows.contains(indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .clear
    }
}
