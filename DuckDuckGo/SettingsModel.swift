//
//  SettingsState.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import BrowserServicesKit
import Persistence
import Common
import DDGSync
import Combine
import UIKit

#if APP_TRACKING_PROTECTION
import NetworkExtension
#endif

#if NETWORK_PROTECTION
import NetworkProtection
import Core
#endif

class SettingsModel {
    
    // MARK: Dependencies
    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    let appIconManager = AppIconManager.shared
    
    private let bookmarksDatabase: CoreDataDatabase
    private let internalUserDecider: InternalUserDecider
    private lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    private lazy var animator: FireButtonAnimator = FireButtonAnimator(appSettings: AppUserDefaults())
    private(set) lazy var appSettings = AppDependencyProvider.shared.appSettings

    // MARK: Other Properties
    private lazy var isPad = UIDevice.current.userInterfaceIdiom != .pad
    #if NETWORK_PROTECTION
    private let connectionObserver = ConnectionStatusObserverThroughSession()
    #endif
    private var cancellables: Set<AnyCancellable> = []
    
    init(bookmarksDatabase: CoreDataDatabase,
         syncService: DDGSyncing,
         syncDataProviders: SyncDataProviders,
         internalUserDecider: InternalUserDecider) {
        self.bookmarksDatabase = bookmarksDatabase
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.internalUserDecider = internalUserDecider
    }
    
    enum Features {
        case sync
        case autofillAccessCredentialManagement
        case textSize
        #if NETWORK_PROTECTION
        case networkProtection
        #endif
        case voiceSearch
        case addressbarPosition
            
    }
    
    func isFeatureAvailable(_ feature: Features) -> Bool {
        switch feature {
        case .sync:
            return featureFlagger.isFeatureOn(.sync)
        case .autofillAccessCredentialManagement:
            return featureFlagger.isFeatureOn(.autofillAccessCredentialManagement)
        case .textSize:
            return !isPad
        
        #if NETWORK_PROTECTION
        case .networkProtection:
            if #available(iOS 15, *) {
                return featureFlagger.isFeatureOn(.networkProtection)
            } else {
                return false
            }
        #endif
        
        case .voiceSearch:
            return AppDependencyProvider.shared.voiceSearchHelper.isSpeechRecognizerAvailable
        case .addressbarPosition:
            return !isPad
        }
    }
    
    func setTheme(theme: ThemeName) {
        ThemeManager.shared.enableTheme(with: theme)
        ThemeManager.shared.updateUserInterfaceStyle()
    }
    
    func setFireButtonAnimetion(_ value: FireButtonAnimationType) {
        appSettings.currentFireButtonAnimation = value
        NotificationCenter.default.post(name: AppUserDefaults.Notifications.currentFireButtonAnimationChange, object: self)
        
            animator.animate {
                // no op
            } onTransitionCompleted: {
                // no op
            } completion: {
                // no op
            }
    }

}
