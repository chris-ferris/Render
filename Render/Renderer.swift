//
//  Renderer.swift
//  Render
//
//  Created by John Christopher Ferris
//

import MetalKit

struct Uniforms {
    var modelViewMatrix: float4x4
    var projectionMatrix: float4x4
}

class Renderer: NSObject {
    let metalFactory = MetalFactory()
    let resourceURL: URL
    var meshes = [MTKMesh]()
    var time: Float = 0.0

    init?(resource: String) {
        guard let resourceURL = Bundle.main.url(forResource: resource, withExtension: "obj") else {
            return nil
        }
        self.resourceURL = resourceURL
        super.init()
        meshes = newMeshes(for: resourceURL)
    }

    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let buffer = metalFactory.makeCommandBuffer(),
            let encoder = metalFactory.makeRenderCommandEncoder(view: view, buffer: buffer)
         else {
            return
        }
        time += 1 / Float(view.preferredFramesPerSecond)
        let angle = -time
        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        let projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 3, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100)
        let modelMatrix = float4x4(rotationAbout: SIMD3<Float>(0, 1, 0.1), by: angle) * float4x4(scaleBy: 2)
        let viewMatrix = float4x4(translationBy: SIMD3<Float>(0, 0, -2))
        let modelViewMatrix = viewMatrix * modelMatrix
        var uniforms = Uniforms(modelViewMatrix: modelViewMatrix, projectionMatrix: projectionMatrix)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        for mesh in meshes {
            guard let vertexBuffer = mesh.vertexBuffers.first else {
                return
            }
            encoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
            for submesh in mesh.submeshes {
                let indexBuffer = submesh.indexBuffer
                encoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                              indexCount: submesh.indexCount,
                                              indexType: submesh.indexType,
                                              indexBuffer: indexBuffer.buffer,
                                              indexBufferOffset: indexBuffer.offset)
            }
        }
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
    }

    private func newMeshes(for resourceURL: URL) -> [MTKMesh] {
        guard let device = metalFactory.device else {
            return [MTKMesh]()
        }
        let vertexDescriptor = MetalDescriptor().makeVertexDescriptor()
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: resourceURL, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        var meshes: [MTKMesh]
        do {
            (_, meshes) = try MTKMesh.newMeshes(asset: asset, device: device)
        } catch {
            return [MTKMesh]()
        }
        return meshes
    }
}
