//
//  HistoryCapture.swift
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

import Foundation
import History

// macos:
// didCommit: add visit and remember current URL
// on webview title updated: update title
// when url changes "save" previous entry

public class HistoryCapture {

    enum VisitState {
        case added
        case expected
    }

    let historyManager: HistoryManaging
    var coordinator: HistoryCoordinating {
        historyManager.historyCoordinator
    }

    var url: URL?

    public init(historyManager: HistoryManaging) {
        self.historyManager = historyManager
    }

    public func webViewDidCommit(url: URL) {
        print("***", #function, "IN", url)
        self.url = url
        coordinator.addVisit(of: url.urlOrDuckDuckGoCleanQuery)
    }

    public func titleDidChange(_ title: String?, forURL url: URL?) {
        print("***", #function, "IN", title ?? "nil title", url?.absoluteString ?? "nil url")
        guard self.url == url else {
            print("***", #function, "EXIT 1")
            return
        }

        guard let url = url?.urlOrDuckDuckGoCleanQuery, let title, !title.isEmpty else {
            print("***", #function, "EXIT 2")
            return
        }
        print("***", #function, "UPDATING", title, url)
        coordinator.updateTitleIfNeeded(title: title, url: url)
        coordinator.commitChanges(url: url)
        print("***", #function, "OUT")
    }

}

extension URL {

    var urlOrDuckDuckGoCleanQuery: URL {
        guard isDuckDuckGoSearch,
                let searchQuery,
                let url = URL.makeSearchURL(query: searchQuery)?.removingInternalSearchParameters() else { return self }
        return url
    }

}
