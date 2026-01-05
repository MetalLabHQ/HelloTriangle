//
//  Renderer.swift
//  HelloTriangle
//
//  Created by GH on 10/26/25.
//

import SwiftUI
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice                           // GPU 设备
    
    // MARK: - Command Queue
    let commandQueue: MTL4CommandQueue              // 命令队列
    let commandBuffer: MTL4CommandBuffer            // Metal 命令 Buffer
    let commandAllocator: MTL4CommandAllocator      // 命令分配器
    
    // MARK: - Buffers
    let vertexBuffer: MTLBuffer                     // 顶点缓冲区
    
    // MARK: - State
    let pipelineState: MTLRenderPipelineState       // 渲染管线状态
    let argumentTable: MTL4ArgumentTable            // 参数表
    
    init(device: MTLDevice) throws {
        self.device = device
        
        // MARK: - 配置命令队列 Command Queue
        self.commandQueue = device.makeMTL4CommandQueue()!
        self.commandBuffer = device.makeCommandBuffer()!
        self.commandAllocator = device.makeCommandAllocator()!
        
        
        // MARK: - 顶点描述符
        // 描述顶点内存布局
        let vertexDescriptor = MTLVertexDescriptor()
        // 配置 position 属性
        vertexDescriptor.attributes[0].format = .float3 // 数据类型：3 个浮点数
        vertexDescriptor.attributes[0].offset = 0 // position 的偏移量是 0
        vertexDescriptor.attributes[0].bufferIndex = 0 // 从第 0 个缓冲区读取数据
        
        // 配置 color 属性
        vertexDescriptor.attributes[1].format = .float4 // 数据类型：4 个浮点数
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride // 偏移量是 16 字节
        vertexDescriptor.attributes[1].bufferIndex = 0 // 也从第 0 个缓冲区读取数据
        
        // 定义顶点内存布局
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride // 32 字节
        // vertexDescriptor.layouts[0].stepRate = 1                         // 步频为 1，不跳过任何顶点
        // vertexDescriptor.layouts[0].stepFunction = .perVertex            // 逐顶点处理
        
        
        // MARK: - 设置 Buffer
        // 使用三角形的顶点数组创建 Buffer
        self.vertexBuffer = device.makeBuffer(
            // 传递给 GPU 的数据
            bytes: vertices,
            // 数据的字节长度，以 Vertex 的内存大小 * 数组长度计算得出
            length: vertices.count * MemoryLayout<Vertex>.stride
        )!
        
        
        // MARK: - 加载 Shader
        let library = device.makeDefaultLibrary()!
        
        // 顶点着色器
        let vertexFunctionDescriptor       = MTL4LibraryFunctionDescriptor()
        vertexFunctionDescriptor.library   = library
        vertexFunctionDescriptor.name      = "vertex_main"
        
        // 片元着色器
        let fragmentFunctionDescriptor     = MTL4LibraryFunctionDescriptor()
        fragmentFunctionDescriptor.library = library
        fragmentFunctionDescriptor.name    = "fragment_main"
        
        
        // MARK: - 描述符 Descriptor
        // 渲染管线描述符
        let pipelineDescriptor = MTL4RenderPipelineDescriptor()
        pipelineDescriptor.vertexFunctionDescriptor        = vertexFunctionDescriptor
        pipelineDescriptor.fragmentFunctionDescriptor      = fragmentFunctionDescriptor
        pipelineDescriptor.vertexDescriptor                = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm // 像素格式
//        pipelineDescriptor.inputPrimitiveTopology          = .triangle // 默认值
        // 参数表
        let argTableDescriptor = MTL4ArgumentTableDescriptor()
        argTableDescriptor.maxBufferBindCount = 1 // 最多可以绑定一个 Buffer
        self.argumentTable = try device.makeArgumentTable(descriptor: argTableDescriptor)
        self.argumentTable.setAddress(vertexBuffer.gpuAddress, index: 0) // 将三角形顶点 Buffer 设为第 0 个 Buffer
        
        
        // MARK: - 状态 State
        // 创建渲染管线状态
        self.pipelineState = try device
            .makeCompiler(descriptor: MTL4CompilerDescriptor())
            .makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        super.init()
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        // MARK: - 开始命令编码 Begin Command Buffer
        self.commandQueue.waitForDrawable(drawable)
        self.commandAllocator.reset()
        self.commandBuffer.beginCommandBuffer(allocator: commandAllocator)
        
        
        // MARK: - Render Pass
        guard let mtl4RenderPassDescriptor = view.currentMTL4RenderPassDescriptor else { return }
        mtl4RenderPassDescriptor.colorAttachments[0].clearColor  = MTLClearColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        
        
        // MARK: - 开始编码渲染 Begin Render Encoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: mtl4RenderPassDescriptor,
            options: MTL4RenderEncoderOptions()
        ) else { return }
        
        
        // MARK: - 设置渲染状态
        renderEncoder.setRenderPipelineState(pipelineState)
        // 传递顶点数据给 Shader
        renderEncoder.setArgumentTable(argumentTable, stages: .vertex)
        
        
        // MARK: - 绘制 Draw
        renderEncoder.drawPrimitives(
            primitiveType: .triangle,
            vertexStart: 0,
            vertexCount: vertices.count
        )
        
        // MARK: - 结束渲染编码 End Render Encoder
        renderEncoder.endEncoding()
        
        
        // MARK: - 结束命令编码 End Command Buffer
        self.commandBuffer.endCommandBuffer()
        self.commandQueue.commit([commandBuffer], options: nil)
        self.commandQueue.signalDrawable(drawable)
        drawable.present()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

#Preview {
    MetalView()
}
