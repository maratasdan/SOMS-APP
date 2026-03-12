//
//  NetworkConnectionAlert.swift
//  SOMS
//
//  Created by Codex on 3/13/26.
//

import Foundation
import Network

final class NetworkConnectionAlert {
    static let shared = NetworkConnectionAlert()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkConnectionAlert")
    private var lastStatus: NWPath.Status?

    var onNoInternet: (() -> Void)?
    var onInternetRestored: (() -> Void)?

    private init() {}

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let status = path.status
            guard status != self.lastStatus else { return }
            self.lastStatus = status

            DispatchQueue.main.async {
                if status == .satisfied {
                    self.onInternetRestored?()
                } else {
                    self.onNoInternet?()
                }
            }
        }

        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
