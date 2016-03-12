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
                    realm.create(Service.self, value: [0, "Apache SpamAssassin™"])
                    realm.create(Service.self, value: [1, "Apache Web Server"])
                    realm.create(Service.self, value: [2, "cPanel Daemon"])
                    realm.create(Service.self, value: [3, "cPanel DAV Daemon"])
                    realm.create(Service.self, value: [4, "cPanel DNS (Domain Name System) Admin Cache"])
                    realm.create(Service.self, value: [5, "cPanel Greylisting Daemon"])
                    realm.create(Service.self, value: [6, "cPanel Log and Bandwidth Processor"])
                    realm.create(Service.self, value: [7, "cPHulk Daemon"])
                    realm.create(Service.self, value: [8, "Cron Daemon"])
                    realm.create(Service.self, value: [9, "DNS (Domain Name System) Server"])
                    realm.create(Service.self, value: [10, "Exim Mail Server"])
                    realm.create(Service.self, value: [11, "Exim Mail Server (on another port)"])
                    realm.create(Service.self, value: [12, "FTP (File Transfer Protocol) Server"])
                    realm.create(Service.self, value: [13, "IMAP (Internet Mail Access Protocol) Server"])
                    realm.create(Service.self, value: [14, "IP (Internet Protocol) Aliases"])
                    realm.create(Service.self, value: [15, "Mailman"])
                    realm.create(Service.self, value: [16, "MySQL Server"])
                    realm.create(Service.self, value: [17, "Name Service Cache Daemon"])
                    realm.create(Service.self, value: [18, "Passive OS (Operating System) Fingerprinting Daemon"])
                    realm.create(Service.self, value: [19, "PHP-FPM service for cPanel Daemons"])
                    realm.create(Service.self, value: [20, "POP3 (Post Office Protocol 3) Server"])
                    realm.create(Service.self, value: [21, "rsyslog System Logger Daemon"])
                    realm.create(Service.self, value: [22, "SSH (Secure Shell) Daemon"])
                    realm.create(Service.self, value: [23, "TailWatch Daemon"])
                    realm.create(Service.self, value: [24, "TaskQueue Processor"])
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
