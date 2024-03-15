//
//  DefaultNetworkProtectionVisibility.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

#if NETWORK_PROTECTION

import Foundation
import BrowserServicesKit
import Waitlist
import NetworkProtection
import Core

struct DefaultNetworkProtectionVisibility: NetworkProtectionFeatureVisibility {
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let networkProtectionTokenStore: NetworkProtectionTokenStore?
    private let networkProtectionAccessManager: NetworkProtectionAccess?
    private let featureFlagger: FeatureFlagger

    init(privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         networkProtectionTokenStore: NetworkProtectionTokenStore? = NetworkProtectionKeychainTokenStore(),
         networkProtectionAccessManager: NetworkProtectionAccess? = NetworkProtectionAccessController(),
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.privacyConfigurationManager = privacyConfigurationManager
        self.networkProtectionTokenStore = networkProtectionTokenStore
        self.networkProtectionAccessManager = networkProtectionAccessManager
        self.featureFlagger = featureFlagger
    }

    /// A version with fewer dependencies that can't check for isWaitlistUser()
    static func availablity() -> DefaultNetworkProtectionVisibility {
        DefaultNetworkProtectionVisibility(networkProtectionTokenStore: nil, networkProtectionAccessManager: nil)
    }

    func isWaitlistBetaActive() -> Bool {
        privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(NetworkProtectionSubfeature.waitlistBetaActive)
    }
    
    func isWaitlistUser() -> Bool {
        guard let networkProtectionTokenStore, let networkProtectionAccessManager else {
            preconditionFailure("networkProtectionTokenStore and networkProtectionAccessManager must be non-nil")
        }

        let hasLegacyAuthToken = {
            guard let authToken = try? networkProtectionTokenStore.fetchToken(),
                  !authToken.hasPrefix(NetworkProtectionKeychainTokenStore.authTokenPrefix) else {
                return false
            }
            return true
        }()
        let hasBeenInvited = {
            let vpnAccessType = networkProtectionAccessManager.networkProtectionAccessType()
            return vpnAccessType == .waitlistInvited || vpnAccessType == .inviteCodeInvited
        }()

        return hasLegacyAuthToken || hasBeenInvited
    }

    // todo - https://app.asana.com/0/0/1206844038943626/f
    func isPrivacyProLaunched() -> Bool {
#if SUBSCRIPTION && ALPHA
        true
#else
        featureFlagger.isFeatureOn(.subscription)
#endif
    }
    
    // todo - https://app.asana.com/0/0/1206844038943626/f
    func shouldMonitorEntitlement() -> Bool {
#if SUBSCRIPTION && ALPHA
        true
#else
        isPrivacyProLaunched()
#endif
    }
}

#endif