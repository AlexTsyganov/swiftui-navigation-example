//
//  Other.swift
//  Example
//
//  Created by Alex Tsyganov on 09/06/2023.
//

import SwiftUI
import Combine

struct AMLNavigationView<Content: View>: View {
    let conent: () -> Content
    
    var body: some View {
//        if #available(iOS 16.0, *) {
//            NavigationStack {
//                conent()
//            }
//            .navigationViewStyle(.stack)
//        } else {
//            NavigationView {
//                conent()
//            }
//            .navigationViewStyle(.stack)
//        }
        NavigationView {
            conent()
        }
        .navigationViewStyle(.stack)
    }
}

struct AMLNavigationLink<Screen: View>: View {
    let screen: Screen
    let showing: Published<Bool>.Publisher
    @State var show = false
    @Binding var dismissing: Bool

    var body: some View {
        NavigationLink(destination: screen, isActive: $show) { EmptyView() }
            .onReceive(showing, perform: {
                if show != $0 {
                    show = $0
                }
            })
            .onChange(of: show, perform: {
                if dismissing != $0 {
                    dismissing = $0
                }
            })
    }

    init(_ screen: @autoclosure @escaping () -> Screen, showing: Published<Bool>.Publisher, dismissing: Binding<Bool>) {
        self.screen = screen()
        self.showing = showing
        self._dismissing = dismissing
    }
}

struct NaigationHeaderModifier: ViewModifier {
    @Environment(\.dismiss) var dismisser
    
    var title: String?
    var trailingText: String?
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(title ?? "")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let trailingText {
                        Text(trailingText)
                            .padding(.vertical)
                    }
                }
            }
    }
    
    init(title: String, trailingText: String?) {
        self.title = title
        self.trailingText = trailingText
    }
    
    @ViewBuilder
    private var BackButton: some View {
        Button(action: { dismisser() }) {
            Image(systemName: "chevron.backward")
                .renderingMode(.template)
                .foregroundColor(.black)
        }
        .accessibilityIdentifier("navigationBackButton")
        .padding(.vertical)
    }
}

extension View {
    func navigationBar(title: String, trailingText: String? = nil) -> some View {
        modifier(NaigationHeaderModifier(title: title, trailingText: trailingText))
    }
    
    func amlNavigationBarHideLegacy() -> some View {
        if #available(iOS 16.0, *) {
            return self
        } else {
            return navigationBarHidden(true)
        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

extension Publishers {
    class AML { private init() { } }
}

extension Publishers.AML {
    static func delayed<Value>(value: @escaping (Int) -> Value = { $0 }, timeInterval: DispatchTimeInterval) -> AnyPublisher<Value, Never> {
        delayed(value: value, timeInterval: { _ in timeInterval })
    }
    
    static func delayed<Value>(value: @escaping (Int) -> Value = { $0 }, timeInterval: @escaping (Int) -> DispatchTimeInterval) -> AnyPublisher<Value, Never> {
        (0...).publisher
            .eraseToAnyPublisher()
            .flatMap(maxPublishers: .max(1)) { i in
                Just(value(i))
                    .delay(for: .nanoseconds(timeInterval(i).nanoseconds), scheduler: RunLoop.main)
            }
            .eraseToAnyPublisher()
    }
}

extension DispatchTimeInterval {
    var nanoseconds: Int {
        switch self {
        case .seconds(let i):
            return i * 1_000_000_000
        case .milliseconds(let i):
            return i * 1_000_000
        case .microseconds(let i):
            return i * 1_000
        case .nanoseconds(let i):
            return i
        case .never:
            return 0
        @unknown default:
            return 0
        }
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(_ time: DispatchTimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(time.nanoseconds))
    }
}
