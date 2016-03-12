//
//  ViewController.swift
//  GH3319
//
//  Created by JP Simard on 3/11/16.
//  Copyright © 2016 Realm. All rights reserved.
//

import UIKit
import RealmSwift

class CustomCellBase: UITableViewCell {
    var indexPath = NSIndexPath()
}

class CellWithBadge: CustomCellBase {}

struct Globals {
    static let alphabet = "abcdefghijklmnopqrstuvwxyz"
}

typealias ItemToCellMappingBlock = (cell: CustomCellBase, item: Object) -> Void
class TableViewDataSource<O: Object>: NSObject, UITableViewDataSource {
    var data: Results<O>
    var sortKey: String? {
        didSet {
            if sortKey != nil {
                data = data.sorted(sortKey!, ascending: sortAsc)
            }
        }
    }
    var sortAsc: Bool = true {
        didSet {
            if sortKey != nil {
                data = data.sorted(sortKey!, ascending: sortAsc)
            }
        }
    }
    var identifier: String
    var mappingBlock: ItemToCellMappingBlock?

    var useIndex = false
    var indexKey: String?

    init(data: Results<O>, reuseIdentifier identifier: String, mappingBlock: ItemToCellMappingBlock) {
        self.data = data
        self.identifier = identifier
        self.mappingBlock = mappingBlock
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (useIndex && data.count > 0) ? 1 : data.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (useIndex) ? data.count : 1
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if !useIndex || indexKey == nil || tableView.style == .Grouped { return nil }

        var output: [String] = []
        var orig: [Character] = []

        orig = data
            .filter({
                return ($0.valueForKey(indexKey!) as? String != nil)
                    && ($0.valueForKey(indexKey!) as! String != "")
            })
            .map({
                return ($0.valueForKey(indexKey!) as! String).uppercaseString.characters.first!
            })

        let unique = Array(Set(orig)).sort({$0 < $1})

        for char in Globals.alphabet.characters {
            if let _ = unique.indexOf(char) {
                output.append(String(char))
            }
            output.append(" ")
        }
        return output
    }

    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if !useIndex || indexKey == nil || tableView.style == .Grouped { return 0 }
        var t = title
        if title == " " {
            if index == 0 { return 0 }
            t = sectionIndexTitlesForTableView(tableView)![index - 1]
        }

        let predicate = NSPredicate(format: "%K BEGINSWITH[c] %@", indexKey!, t)
        if let index = data.indexOf(predicate) {
            return index
        }
        return data.count - 1
    }

// I had to comment out this function because UITableViewDelegate doesn't have a `canEditRow` method
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return tableView.delegate?.canEditRow(tableView, indexPath: indexPath) ?? false
//    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = data[(useIndex) ? indexPath.section : indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? CustomCellBase, mapper = mappingBlock {
            cell.indexPath = indexPath
            mapper(cell: cell, item: item)
            return cell
        }
        let cell = CustomCellBase(style: UITableViewCellStyle.Value2, reuseIdentifier: identifier)
        cell.textLabel?.text = "Unable To Load Cell Data"
        return cell
    }
}

class ViewController: UITableViewController {

    var token: NotificationToken!
    var tableData: TableViewDataSource<Service>!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        let account = try! Realm().objects(Account).first
        let services = account?.server?.services.filter("installed = true").sorted("displayName")
        tableData = TableViewDataSource<Service>(data: services!, reuseIdentifier: "CellWithBadge") { cell, item in
            self.configureCell(cell as! CellWithBadge, item: item as! Service)
        }
        tableData.useIndex = true
        tableData.indexKey = "displayName"
        
        tableView.dataSource = tableData
        token = services!.addNotificationBlock { [unowned self] _, _ in
            self.tableView.reloadData()
        }
    }

    func configureCell(cell: CellWithBadge, item: Service) {
        cell.textLabel?.text = item.displayName
    }

    deinit {
        token.stop()
    }
}
