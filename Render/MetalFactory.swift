//
//  MetalFactory.swift
//  Render
//
//  Created by John Christopher Ferris on 5/17/22.
//

import MetalKit

struct MetalFactory {
    let device = MTLCreateSystemDefaultDevice()
    let clearColor = MTLClearColorMake(0, 0, 0, 1)

    func makeView() -> MTKView {
        let view = MTKView()
        view.device = device
        view.clearColor = clearColor
        view.colorPixelFormat = .bgra8Unorm_srgb
        view.depthStencilPixelFormat = .depth32Float
        view.sampleCount = 1
        return view
    }

    func makeCommandBuffer() -> MTLCommandBuffer? {
        let commandQueue = device?.makeCommandQueue()
        return commandQueue?.makeCommandBuffer()
    }

    func makeRenderCommandEncoder(view: MTKView, buffer: MTLCommandBuffer) -> MTLRenderCommandEncoder? {
        guard
            let renderCommandEncoderDescriptor = view.currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: renderCommandEncoderDescriptor),
            let renderPipelineDescriptor = MetalDescriptor().makeRenderPipelineDescriptor(device: device),
            let renderPipelineState = try? device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor),
            let depthStencilState = device?.makeDepthStencilState(descriptor: MetalDescriptor().makeDepthStencilDescriptor())
        else {
            return nil
        }
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setDepthStencilState(depthStencilState)
        encoder.setFrontFacing(.counterClockwise)
        return encoder
    }
}
