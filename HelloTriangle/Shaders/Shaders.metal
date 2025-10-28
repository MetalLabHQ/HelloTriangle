//
//  Shaders.metl
//  HelloTriangle
//
//  Created by GH on 10/26/25.
//

#include <metal_stdlib>
using namespace metal;

// 顶点缓冲区(vertex buffer)传入顶点着色器所用的数据结构
struct VertexIn {
    // float3 position 对应 Swift 中 SIMD3，表示顶点的坐标 xyz
    // [[attribute(0)]] 表示让 Metal 从顶点缓冲区中的第 0 个属性提取数据（通常是位置）作为 position 值
    float3 position [[attribute(0)]];
    
    // float4 color 的四个值是 rgba 颜色，同样 [[attribute(1)]] 表示从用顶点缓冲区的第 1 个属性作为 color
    float4 color [[attribute(1)]];
};

// 顶点着色器根据传入数据 VertexIn 进行一系列改动后，将输出数据打包成 VertexOut
struct VertexOut {
    // 根据 VertexIn 的 position 进行坐标转换，变成 屏幕坐标 后传递给下一阶段
    float4 position [[position]];
    // VertexIn 传入的 color，多数情况为原封不动传递给下一个阶段，但具体如何实现还是看顶点着色器
    float4 color;
};

// 顶点着色器函数
// vertex: - Metal 修饰符，用于表示该函数为顶点着色器
// VertexOut: - 函数返回值
// vertex_main: - 函数名
// VertexIn in [[stage_in]]: - 输入参数，顶点数据
vertex VertexOut vertex_main(VertexIn in [[stage_in]]) {
    // 定义 out 变量
    VertexOut out;
    // 将输入的 position 赋值给 out.position，由于 VertexOut 需要 float4，所以先补一个 1.0 作为齐次坐标
    out.position = float4(in.position, 1.0);
    // 将输入的 color 赋值给 out.color
    out.color = in.color;
    // 返回 VertexOut
    return out;
}

// 片元着色器函数
// fragment: - Metal 修饰符，用于表示该函数为片元着色器
// float4: - 函数返回值，表示 RGBA 颜色值
// fragment_main: - 函数名
// VertexOut in: - 输入参数，传入顶点着色器输出的结构体 VertexOut
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;  // 直接使用从顶点着色器传递过来的颜色值
    // 这里只是把顶点着色器的颜色数据，显示在屏幕上
}
