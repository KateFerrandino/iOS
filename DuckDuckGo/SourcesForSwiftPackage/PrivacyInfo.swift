//
//  PrivacyInfo.swift
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import TrackerRadarKit

public final class PrivacyInfo {
    
    public private(set) var url: URL
    private(set) var parentEntity: Entity?
    private(set) var isProtected: Bool
    
    @Published public var trackerInfo: TrackerInfo
    @Published public var serverTrust: ServerTrust?
    @Published public var connectionUpgradedTo: URL?
    
    public init(url: URL, parentEntity: Entity?, isProtected: Bool) {
        self.url = url
        self.parentEntity = parentEntity
        self.isProtected = isProtected
        trackerInfo = TrackerInfo()
    }
    
}