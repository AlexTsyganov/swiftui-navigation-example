//
//  RVSScreen.swift
//
//
//  Created by Alex Tsyganov on 09/06/2023.
//

import SwiftUI
import Combine

final class VehicleViewModel : ObservableObject {
    @Published var value = 1
    var navStackVehicleRouter: NavStackVehicleRouter
    
    init(_ di: DI = DI.shared) {
        navStackVehicleRouter = di.router
        print("init VehicleViewModel")
        Publishers.AML.delayed(timeInterval: .seconds(4))
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in
                print("timer !")
            })
            .assign(to: &$value)
    }

    func vehicleStatusPressed() {
        navStackVehicleRouter.showVehicleStatus(true)
    }
    
    @MainActor
    func vehicleStatusTyrePressurePressed() async {
        navStackVehicleRouter.showVehicleStatus(true)
        await Task.sleep(.milliseconds(600))
        navStackVehicleRouter.tyrePressure = true
    }
}

struct VehicleScreen: View {
    @StateObject var viewModel = VehicleViewModel()
    
    var body: some View {
        AMLNavigationView {
            ZStack {
                Color.yellow.opacity(0.3)
                VStack(spacing: 20) {
                    Text("View model: \(viewModel.value)")
                    Button("Show Vehicle Status Tab") {
                        viewModel.vehicleStatusPressed()
                    }
                    Button("Show Vehicle Status Tab \\ Tyre pressure") {
                        Task { await viewModel.vehicleStatusTyrePressurePressed() }
                    }
//                    NavigationLink(destination: VehicleStatusTabScreen(), isActive: $viewModel.navStackVehicleRouter.vehicleStatus) { EmptyView() }
                    AMLNavigationLink(
                        VehicleStatusTabScreen(),
                        showing: viewModel.navStackVehicleRouter.$vehicleStatus,
                        dismissing: $viewModel.navStackVehicleRouter.vehicleStatus)
                }
            }
            .amlNavigationBarHideLegacy()
            .onAppear {
                print("onAppear: \(type(of: self))")
            }
            .onDisappear {
                print("onDisappear: \(type(of: self))")
            }
        }
    }
}

struct RVSScreen_Previews: PreviewProvider {
    static var previews: some View {
        VehicleScreen(viewModel: .init())
    }
}
