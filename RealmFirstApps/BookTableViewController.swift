//
//  BookTableViewController.swift
//  RealmFirstApps
//
//  Created by anhxa100 on 5/4/19.
//  Copyright © 2019 anhxa100. All rights reserved.
//

import UIKit
import RealmSwift

class BookTableViewController: UITableViewController {
    
    private var books: Results<BookItem>?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("REALMFILE: \(Realm.Configuration.defaultConfiguration.fileURL)")
        books = BookItem.getAll()
    }

    // MARK: - Table view data source
    @IBAction func onAddButtonClicked(_ sender: Any) {
        showInputBookAlert("Add book name") { name in
            BookItem.add(name: name)
        }
    }
    
    func showInputBookAlert(_ title: String, isSecure: Bool = false, text: String? = nil, callback: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { field in
            field.isSecureTextEntry = isSecure
            field.text = text
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else {
                
//                userInputAlert(title, callback: callback)
                
                return
            }
            
            callback(text)
        })
        let root = UIApplication.shared.keyWindow?.rootViewController
        root?.present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookTableViewCell, let book = books?[indexPath.row] else {
            return BookTableViewCell(frame: .zero)
        }

        cell.configureWith(book) { [weak self] book in
            book.toggleCompleted()
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BookTableViewCell else {
            return
        }
        
        cell.toggleCompleted()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let book = books?[indexPath.row],
            editingStyle == .delete else { return }
        book.delete()
    }
    
    
    private var token: NotificationToken?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        token = books?.observe({ [weak tableView] changes in
            guard let tableView = tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let updates):
                tableView.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
            case .error: break
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        token?.invalidate()
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITableView {
    func applyChanges(deletions: [Int], insertions: [Int], updates: [Int]) {
        beginUpdates()
        deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        reloadRows(at: updates.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        endUpdates()
    }
}
