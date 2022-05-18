//
//  MetalDescriptors.swift
//  Render
//
//  Created by John Christopher Ferris
//

import MetalKit

struct MetalDescriptor {
    let vertexBufferLayout = MDLVertexBufferLayout(stride: MemoryLayout<Float>.size * 8)
    let vertexAttributePosition = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
    let vertexAttributeNormal = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: MemoryLayout<Float>.size * 3, bufferIndex: 0)
    let vertexAttributeTextureCoordinate = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: MemoryLayout<Float>.size * 6, bufferIndex: 0)

    func makeRenderPipelineDescriptor(device: MTLDevice?) -> MTLRenderPipelineDescriptor? {
        guard let library = device?.makeDefaultLibrary() else {
            return nil
        }
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "Render Pipeline"
        descriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        descriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        descriptor.depthAttachmentPixelFormat = .depth32Float
        descriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(makeVertexDescriptor())
        return descriptor
    }

    func makeVertexDescriptor() -> MDLVertexDescriptor {
        let descriptor = MDLVertexDescriptor()
        descriptor.attributes[0] = vertexAttributePosition
        descriptor.attributes[1] = vertexAttributeNormal
        descriptor.attributes[2] = vertexAttributeTextureCoordinate
        descriptor.layouts[0] = vertexBufferLayout
        return descriptor
    }

    func makeDepthStencilDescriptor() -> MTLDepthStencilDescriptor {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return descriptor
    }
}
