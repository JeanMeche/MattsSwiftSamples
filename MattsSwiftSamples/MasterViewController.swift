//
//  MasterViewController.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 25/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {
    
    var editable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if editable {
            self.navigationItem.leftBarButtonItem = self.editButtonItem()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        DetailProvider.clearViewControllersCache()
    }

    // MARK: - Segues
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                return DetailProvider.hasDetailForIndex((indexPath as NSIndexPath).row)
            }
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow, navigationViewController = (segue.destinationViewController as? UINavigationController),
                childVC = DetailProvider.viewControllerForIndex((indexPath as NSIndexPath).row) {
                navigationViewController.viewControllers = [childVC]
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return DetailProvider.storyboards.count > 0 ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // let sectionInfo = self.fetchedResultsController.sections![section]
        // sectionInfo.numberOfObjects
        return DetailProvider.storyboards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = DetailProvider.titleForIndex((indexPath as NSIndexPath).row)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
}


extension MasterViewController:NSFetchedResultsControllerDelegate  {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                break
                //self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */
}

