/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UserNotifications
import AcousticMobilePushNotification

class NotificationService: MCENotificationService {
    
    static let configurationDict: [AnyHashable: Any] = [
    "baseUrl": "https://sdk6.ibm.xtify.com",
    "appKey": [
        "dev": "ap9cvqzAx8",
        "prod": "ap58k55f9s"
    ],
    "invalidateExistingUser": false,
    "autoReinitialize": true,
    "location": [
        "sync": [
            "syncRadius": 100000,
            "syncInterval": 300
        ],
        "geofence": [
            "choose one of the following values for accuracy: ": ["best", "10m", "100m", "1km", "3km"],
            "accuracy": "3km"
        ],
        "ibeacon": [
            "UUID": "INSERT-IBEACON-UUID-HERE"
        ]
    ],
    "autoInitialize": false,
    "sessionTimeout": 20,
    "Choose one of the following values for loglevel: ": ["none", "error", "info", "warn", "verbose"],
    "logfile": true,
    "Maximum size of log before it's rotated": "default is 10MB",
    "maximumLogSize": 10000000,
    "maximumNumberOfLogFiles": 7,
    "databaseEncryption": false,
    "databaseKeyRotationDays": 30,
    "allowJailbrokenDevices": true,
    "watch": [
        "category": "mce-watch-category",
        "handoff": [
            "Note the userActivityName must be also in the NSUserAcrtivityTypes array in the application's info.plist": "",
            "userActivityName": "com.mce.application",
            
            "This is the name of the interface controller in the Watch storyboard": "",
            "interfaceController": "handoff"
        ]
    ]]
    
    override init() {
        super.init()
        let configuration = NotificationService.configurationDict
        MCEConfig.sharedInstance(with: configuration)
    }
}
