//
//  MetalViewRepresentable.swift
//  Render
//
//  Created by John Christopher Ferris
//

import SwiftUI
import MetalKit

struct MetalViewRepresentable: NSViewRepresentable {
    let renderer = Renderer(resource: "teapot")

    class Coordinator: NSObject, MTKViewDelegate {
        var viewRepresentable: MetalViewRepresentable

        init(_ viewRepresentable: MetalViewRepresentable) {
            self.viewRepresentable = viewRepresentable
            super.init()
        }

        func draw(in view: MTKView) {
            viewRepresentable.renderer?.draw(in: view)
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: NSViewRepresentableContext<MetalViewRepresentable>) -> MTKView {
        let view = MetalFactory().makeView()
        view.delegate = context.coordinator
        return view
    }

    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalViewRepresentable>) {}
}
