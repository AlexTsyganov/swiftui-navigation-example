//
//  MainScreen.swift
//  Example
//
//  Created by Alex Tsyganov on 09/06/2023.
//

import SwiftUI
import Combine

final class MainViewModel : ObservableObject {
    @Published var value = 1
    @Published var currentTab: Int = 0
    lazy var router = AppDI.router
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        print("init MainViewModel")
        $currentTab
            .dropFirst()
            .sink { [unowned self] selected in
                if selected == 0, selected == currentTab {
                    guard router.vehicleStatus else { return }
                    router.showVehicleStatus(false)
                    router.tyrePressureAnimate(show: false)
                }
            }
            .store(in: &cancellables)
        Publishers.AML.delayed(timeInterval: .seconds(3))
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in
                print("main model - timer !")
            })
            .assign(to: &$value)
    }
}

struct MainScreen: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var vehicleViewModel = VehicleViewModel()
    @State private var selfUpdate = UUID()
    
    var body: some View {
        VStack {
            HStack {
                Text("Text: \(viewModel.value)")
            }
            TabView(selection: $viewModel.currentTab) {
                VehicleScreen(viewModel: vehicleViewModel)
                    .id(selfUpdate)
                    .tabItem {
                        Text("RVS")
                    }
                    .tag(0)
                Text("Nav")
                    .tabItem {
                        Text("Nav")
                    }
                    .tag(1)
            }
        }
        .onReceive(viewModel.router
            .$vehicleStatus
            .delay(for: .milliseconds(300), scheduler: RunLoop.main)) { showing in
                if #available(iOS 16.0, *) {
                    guard !showing else { return }
                    selfUpdate = .init()
                }
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
