//
//  SwiftUIView.swift
//  
//
//  Created by Alex Tsyganov on 09/06/2023.
//

import SwiftUI
import Combine

final class VehicleStatusTabViewModel : ObservableObject {
    @Published var value = 1
    var navStackVehicleRouter: NavStackVehicleRouter
    
    private init(_ di: DI = DI.shared) {
        navStackVehicleRouter = di.router
        print("init: \(type(of: self))")
        Publishers.AML.delayed(timeInterval: .seconds(1))
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in
                print("status tab - timer !")
            })
            .assign(to: &$value)
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    func tyrePressurePressed() {
        navStackVehicleRouter.tyrePressureAnimate(show: true)
    }
}

extension VehicleStatusTabViewModel {
    class Provider {
        static func `default`() -> VehicleStatusTabViewModel {
            VehicleStatusTabViewModel()
        }
    }
}


struct VehicleStatusTabScreen: View {
    @StateObject var viewModel: VehicleStatusTabViewModel = .Provider.default()
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.2)
            VStack {
                Text("Value: \(viewModel.value)")
                Button("Show Tyre pressure") {
                    viewModel.tyrePressurePressed()
                }
            }
//            NavigationLink(destination: TyrePressureScreen(), isActive: $viewModel.navStackVehicleRouter.tyrePressure) { EmptyView() }
            AMLNavigationLink(
                TyrePressureScreen(),
                showing: viewModel.navStackVehicleRouter.$tyrePressure,
                dismissing: $viewModel.navStackVehicleRouter.tyrePressure)
        }
        .onAppear {
            print("onAppear: \(type(of: self))")
        }
        .onDisappear {
            print("onDisappear: \(type(of: self))")
        }
        .navigationBar(title: "Status")
    }
}

struct VehicleStatusTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        VehicleStatusTabScreen(viewModel: .Provider.default())
    }
}
