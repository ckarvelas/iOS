/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UIKit
import AcousticMobilePush

@objc class AppDelegate : UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow? 
    
    @objc func inboxUpdate() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = Int(MCEInboxDatabase.shared.unreadMessageCount())
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let controller = UIAlertController(title: "Custom URL Clicked", message: url.absoluteString, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
            
        }))
        window?.rootViewController?.present(controller, animated: true, completion: {
            
        })
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let splitViewController = window?.rootViewController as? UISplitViewController, let navigationController = splitViewController.viewControllers.last as? UINavigationController {
            navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            splitViewController.delegate = self
        }
        
        if #available(iOS 12.0, *) {
            MCESdk.shared.openSettingsForNotification = { notification in
                let alert = UIAlertController(title: "Should show app settings for notifications", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                }))
                MCESdk.shared.findCurrentViewController().present(alert, animated: true, completion: {
                    
                })
            }
        }
        
        inboxUpdate()
        setupGeofenceObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.inboxUpdate), name:
            MCENotificationName.InboxCountUpdate.rawValue, object: nil)

        MCESdk.shared.presentNotification = {(userInfo) -> Bool in
            return true
        }
        
        UserDefaults.standard.register(defaults: ["action":"update", "standardType":"dial",  "standardDialValue":"\"8774266006\"",  "standardUrlValue":"\"http://acoustic.co\"",  "customType":"sendEmail",  "customValue":"{\"subject\":\"Hello from Sample App\",  \"body\": \"This is an example email body\",  \"recipient\":\"fake-email@fake-site.com\"}",  "categoryId":"example", "button1":"Accept", "button2":"Reject"])

        if #available(iOS 10.0, *) {
            application.registerForRemoteNotifications()

            // iOS 10+ Example static action category:
            let acceptAction = UNNotificationAction(identifier: "Accept", title: "Accept", options: [.foreground])
            let rejectAction = UNNotificationAction(identifier: "Reject", title: "Reject", options: [.destructive])
            let category = UNNotificationCategory(identifier: "example", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [.customDismissAction])
            
            var categories = Set<UNNotificationCategory>()
            categories.insert(category)
            
            // iOS 10+ Push Message Registration
            let options: UNAuthorizationOptions = {
#if canImport(NaturalLanguage)
            if #available(iOS 12.0, *) {
                return [.alert, .sound, .carPlay, .badge, .providesAppNotificationSettings]
            }
#endif
                return [.alert, .sound, .carPlay, .badge]
            }()

            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: options, completionHandler: { (granted, error) in
                if let error = error {
                    print("Could not request authorization from APNS \(error.localizedDescription)")
                }
                center.setNotificationCategories(categories)
            })
        }
        else if #available(iOS 8.0, *) {
            // iOS 8+ Example static action category:
            let acceptAction = UIMutableUserNotificationAction()
            acceptAction.identifier = "Accept"
            acceptAction.title = "Accept"
            acceptAction.isDestructive=false
            acceptAction.isAuthenticationRequired=false
            
            let rejectAction = UIMutableUserNotificationAction()
            rejectAction.identifier = "Reject"
            rejectAction.title = "Reject"
            rejectAction.isDestructive=true
            rejectAction.isAuthenticationRequired=false
            
            let category = UIMutableUserNotificationCategory()
            category.identifier="example"
            category.setActions([acceptAction, rejectAction], for: .default)
            category.setActions([acceptAction, rejectAction], for: .minimal)
            
            // iOS 8+ Push Message Registration
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: [category])
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // iOS < 8 Push Message Registration
            application.registerForRemoteNotifications(matching: [.badge, .alert, .sound])
        }

        return true
    }
    
    override init() {
        super.init()
        
        // MCE InApp Templates Plugins
        MCEInAppVideoTemplate.register()
        MCEInAppImageTemplate.register()
        MCEInAppBannerTemplate.register()

        // MCE Action Plugins
        DisplayWebViewPlugin.register()
        ActionMenuPlugin.register()
        AddToCalendarPlugin.register()
        AddToPassbookPlugin.register()
        SnoozeActionPlugin.register()
        ExamplePlugin.register()
        CarouselAction.registerPlugin()
        
        // MCE Inbox Templates Plugins
        MCEInboxActionPlugin.register()
        MCEInboxDefaultTemplate.register()
        MCEInboxPostTemplate.register()

        // Custom Send Email Plugin
        let mail = MailDelegate();
        MCEActionRegistry.shared.registerTarget(mail, with: #selector(mail.sendEmail(action:)), forAction: "sendEmail")
        
        TextInputActionPlugin.register()
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        MCEInAppManager.shared.processPayload(notification.userInfo);
    }
    
    func isExampleCategory(userInfo: NSDictionary) -> Bool {
        if let aps = userInfo["aps"] as? NSDictionary, let category = aps["category"] as? String, category == "example" {
            return true
        }
        return false
    }
    
    func setupGeofenceObserver() {
        NotificationCenter.default.addObserver(forName: MCENotificationName.EnteredGeofence.rawValue,
                                               object: self,
                                               queue: .main) { (notification) in
            // use note.userInfo[@"region"].center
            // use note.userInfo[@"region"].radius
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if isExampleCategory(userInfo: userInfo as NSDictionary) {
            let alert = UIAlertController(title: "Static category handler", message: "Static Category, no choice made", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            application.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        if !isExampleCategory(userInfo: userInfo as NSDictionary) {
            return
        }
        
        if let aps = userInfo["aps"] as? NSDictionary {
            if let values = aps["category-values"] as? NSDictionary {
                let name = values["name"]
                let quantity = values["quantity"]
                let persist = values["persist"]
                let other = values["other"] as? NSDictionary
                if name != nil && quantity != nil && persist != nil && other != nil {
                    let message = other!["deniedMessage"]
                    if identifier == "Accept" {
                        let alert = UIAlertController(title: "Static category handler", message: "User pressed \(identifier ?? "") for \(name ?? "") quantity \(quantity ?? "")", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        application.keyWindow?.rootViewController?.present(alert, animated: true)
                        return
                    }
                    if identifier == "Reject" {
                        let alert = UIAlertController(title: "Static category handler", message: "User pressed \(identifier ?? "") persistance \(persist ?? ""), reason \(message ?? "")", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        application.keyWindow?.rootViewController?.present(alert, animated: true)
                        return
                    }
                }
            }
        
            let alert = UIAlertController(title: "Static category handler", message: "Static Category, \(identifier ?? "") button clicked", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            application.keyWindow?.rootViewController?.present(alert, animated: true)
            
            // Send event to Xtify Servers
            let eventName = "Name of event"
            let eventType = "Type of event"
            let attributes = NSDictionary()
            let event = MCEEvent()
            let attribution = aps["attribution"] as? String
            let mailingId = aps["mailingId"] as? String
            event.fromDictionary(["name":eventName, "type": eventType, "timestamp": NSDate.init(), "attributes": attributes])
            if let attrib = attribution {
                event.attribution = attrib
            }
            if let mailingId = mailingId {
                event.mailingId = mailingId
            }

            MCEEventService.shared.add(event, immediate: false)
        }
        completionHandler()
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
