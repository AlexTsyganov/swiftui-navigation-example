//
//  TyrePressureScreen.swift
//  
//
//  Created by Alex Tsyganov on 09/06/2023.
//

import SwiftUI

final class TyrePressureViewModel : ObservableObject {
    init() {
        print("init: \(type(of: self))")
    }
}

struct TyrePressureScreen: View {
    @StateObject var viewModel = TyrePressureViewModel()
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.2)
        }
        .onAppear {
            print("onAppear: \(type(of: self))")
        }
        .onDisappear {
            print("onDisappear: \(type(of: self))")
        }
        .navigationBar(title: "Tyre Pressure")
    }
}

struct TyrePressureScreen_Previews: PreviewProvider {
    static var previews: some View {
        TyrePressureScreen()
    }
}
