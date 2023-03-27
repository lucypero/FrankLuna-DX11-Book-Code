//=============================================================================
// Basic.fx by Frank Luna (C) 2011 All Rights Reserved.
//
// Basic effect that currently supports transformations, lighting, and texturing.
//=============================================================================

#include "LightHelper.fx"
 
cbuffer cbPerFrame
{
	DirectionalLight gDirLights[3];
	float3 gEyePosW;

	float  gFogStart;
	float  gFogRange;
	float4 gFogColor;
};

cbuffer cbPerObject
{
	float4x4 gWorld;
	float4x4 gWorldInvTranspose;
	float4x4 gViewProj;
	float4x4 gWorldViewProj;
	float4x4 gTexTransform;
	Material gMaterial;
};

// Nonnumeric values cannot be added to a cbuffer.
Texture2D gDiffuseMap;

SamplerState samAnisotropic
{
	Filter = ANISOTROPIC;
	MaxAnisotropy = 4;

	AddressU = WRAP;
	AddressV = WRAP;
};

struct VertexIn
{
	float3 PosL    : POSITION;
	float3 NormalL : NORMAL;
	float2 Tex     : TEXCOORD;
};

struct GeoOut
{
	float4 PosH    : SV_POSITION;
};

VertexIn VS(VertexIn vin)
{
	VertexIn vout;

    vout.PosL = vin.PosL;
    vout.NormalL = vin.NormalL;
    vout.Tex = vin.Tex;

	return vout;
}

[maxvertexcount(2)]
void GS(point VertexIn gin[1], 
        inout LineStream<GeoOut> lineStream)
{
    GeoOut p1, p2;

    float3 p1_w = mul(float4(gin[0].PosL, 1.0f), gWorld).xyz;
    float3 p2_w = p1_w + normalize(gin[0].NormalL) * 3.0f;

    p1.PosH = mul(float4(p1_w, 1.0f), gViewProj);
    p2.PosH = mul(float4(p2_w, 1.0f), gViewProj);

    lineStream.Append(p1);
    lineStream.Append(p2);
}
 
float4 PS(GeoOut pin, uniform int gLightCount, uniform bool gUseTexure, uniform bool gAlphaClip, uniform bool gFogEnabled) : SV_Target
{
    // return litColor;
    return float4(0.0, 0.0, 1.0, 1.0);
}

technique11 TheTech
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader( CompileShader( gs_5_0, GS() ) );
        SetPixelShader( CompileShader( ps_5_0, PS(3, true, true, true) ) );
    }
}