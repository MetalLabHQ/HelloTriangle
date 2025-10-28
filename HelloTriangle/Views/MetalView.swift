//
//  MetalView.swift
//  HelloTriangle
//
//  Created by GH on 10/26/25.
//

import SwiftUI
import MetalKit

struct MetalView: ViewRepresentable {
    let device: MTLDevice
    let renderer: Renderer
    
    init() {
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported")
        }
        
        guard defaultDevice.supportsFamily(.metal4) else {  // 检查是否支持 Metal 4
            fatalError("Metal 4 is not supported on this device")
        }
        
        device = defaultDevice
        do {
            self.renderer = try Renderer(device: device)
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
#if os(macOS)
    func makeNSView(context: Context) -> MTKView {
        return makeView()
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
#else
    func makeUIView(context: Context) -> MTKView {
        return makeView()
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {}
#endif
    
    func makeView() -> MTKView {
        let mtkView = MTKView(frame: .zero, device: device)
        // 设置渲染器代理，分离 UI 和 Renderer
        mtkView.delegate = renderer
        // 像素格式
        mtkView.colorPixelFormat = .bgra8Unorm
        // 清屏颜色
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        return mtkView
    }
}

#Preview {
    MetalView()
}
