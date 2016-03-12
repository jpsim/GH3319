//
//  AppDelegate.swift
//  GH3319
//
//  Created by JP Simard on 3/11/16.
//  Copyright © 2016 Realm. All rights reserved.
//

import UIKit
import RealmSwift

class Account: Object {
    dynamic var server: Server?
}

class Server: Object {
    let services = List<Service>()
}

class Service: Object {
    dynamic var id = 0
    dynamic var displayName = ""
    dynamic var installed = true

    override static func indexedProperties() -> [String] {
        return [
            "id",
            "displayName"
        ]
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Delete Realm file to make this sample app deterministic
        do {
            try NSFileManager.defaultManager().removeItemAtPath(Realm.Configuration.defaultConfiguration.path!)
        } catch {}

        do {
            let realm = try Realm()

            do {
                try realm.write {
                    let serviceNames = [
                        "Apache SpamAssassin™",
                        "Apache Web Server",
                        "cPanel Daemon",
                        "cPanel DAV Daemon",
                        "cPanel DNS (Domain Name System) Admin Cache",
                        "cPanel Greylisting Daemon",
                        "cPanel Log and Bandwidth Processor",
                        "cPHulk Daemon",
                        "Cron Daemon",
                        "DNS (Domain Name System) Server",
                        "Exim Mail Server",
                        "Exim Mail Server (on another port)",
                        "FTP (File Transfer Protocol) Server",
                        "IMAP (Internet Mail Access Protocol) Server",
                        "IP (Internet Protocol) Aliases",
                        "Mailman",
                        "MySQL Server",
                        "Name Service Cache Daemon",
                        "Passive OS (Operating System) Fingerprinting Daemon",
                        "PHP-FPM service for cPanel Daemons",
                        "POP3 (Post Office Protocol 3) Server",
                        "rsyslog System Logger Daemon",
                        "SSH (Secure Shell) Daemon",
                        "TailWatch Daemon",
                        "TaskQueue Processor"
                    ]
                    let account = Account()
                    account.server = Server()
                    account.server!.services.appendContentsOf(serviceNames.enumerate().map { id, displayName in
                        let service = Service()
                        service.id = id
                        service.displayName = displayName
                        return service
                    })
                    realm.add(account)
                }
            } catch {
                print("error writing to Realm instance: \(error)")
            }

            let data = realm.objects(Service)

            // This loop is just to print index/values of the Results to make sure the data is good
            for (key, item) in data.enumerate() {
                print(key, item.displayName)
            }

            let predicate = NSPredicate(format: "displayName BEGINSWITH[c] 'P'")
            if let index = data.indexOf(predicate) {
                print(index) // prints 18, as expected
            }
        } catch {
            print("error creating Realm instance: \(error)")
        }
        return true
    }
}
