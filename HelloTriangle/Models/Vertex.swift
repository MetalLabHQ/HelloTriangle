//
//  Vertex.swift
//  HelloTriangle
//
//  Created by GH on 10/26/25.
//

import simd

struct Vertex { // 顶点数据结构
    /// 顶点坐标 XYZ
    let position: SIMD3<Float>
    /// 颜色 RGBA
    let color: SIMD4<Float>
}

let vertices: [Vertex] = [
    Vertex(position: SIMD3<Float>(0.0,  0.5, 0.0), color: SIMD4<Float>(1.0, 0.0, 0.0, 1.0)),   // 顶点 1 (红色)
    Vertex(position: SIMD3<Float>(-0.5, -0.5, 0.0), color: SIMD4<Float>(0.0, 1.0, 0.0, 1.0)),  // 顶点 2 (绿色)
    Vertex(position: SIMD3<Float>(0.5, -0.5, 0.0), color: SIMD4<Float>(0.0, 0.0, 1.0, 1.0))    // 顶点 3 (蓝色)
]
