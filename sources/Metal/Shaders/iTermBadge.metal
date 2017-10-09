#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#import "iTermShaderTypes.h"

typedef struct {
    float4 clipSpacePosition [[position]];
    float2 textureCoordinate;
} iTermBadgeVertexFunctionOutput;

vertex iTermBadgeVertexFunctionOutput
iTermBadgeVertexShader(uint vertexID [[ vertex_id ]],
                       constant float2 *offset [[ buffer(iTermVertexInputIndexOffset) ]],
                       constant iTermVertex *vertexArray [[ buffer(iTermVertexInputIndexVertices) ]],
                       constant vector_uint2 *viewportSizePointer  [[ buffer(iTermVertexInputIndexViewportSize) ]]) {
    iTermBadgeVertexFunctionOutput out;

    float2 pixelSpacePosition = vertexArray[vertexID].position.xy + offset[0];
    float2 viewportSize = float2(*viewportSizePointer);

    out.clipSpacePosition.xy = pixelSpacePosition / viewportSize;
    out.clipSpacePosition.z = 0.0;
    out.clipSpacePosition.w = 1;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;

    return out;
}

fragment float4
iTermBadgeFragmentShader(iTermBadgeVertexFunctionOutput in [[stage_in]],
                         texture2d<half> texture [[ texture(iTermTextureIndexPrimary) ]]) {
    constexpr sampler textureSampler(mag_filter::linear,
                                     min_filter::linear);

    const half4 colorSample = texture.sample(textureSampler, in.textureCoordinate);
    colorSample.w *= 0.75;
    return float4(colorSample);
}

