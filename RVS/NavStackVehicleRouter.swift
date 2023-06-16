//
//  File.swift
//  
//
//  Created by Alex Tsyganov on 15/06/2023.
//

import Foundation
import Combine

class DI {
    static let shared = DI()
    lazy var router = NavStackVehicleRouter()
}

let AppDI = DI.shared

final class NavStackVehicleRouter: ObservableObject {
    @Published var vehicleStatus = false
    @Published var tyrePressure = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $vehicleStatus
            .sink { value in
                print("$vehicleStatus = \(value)")
            }
            .store(in: &cancellables)
        $tyrePressure
            .sink { value in
                print("$tyrePressure = \(value)")
            }
            .store(in: &cancellables)
    }

    func showVehicleStatus(_ show: Bool) {
        vehicleStatus = show
    }
    
    func tyrePressureAnimate(show: Bool) {
        tyrePressure = show
    }
}
