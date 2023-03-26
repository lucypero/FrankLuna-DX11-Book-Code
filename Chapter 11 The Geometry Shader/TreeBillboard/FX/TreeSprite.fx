cbuffer cbPerFrame
{
	float3 gEyePosW;

	float  gFogStart;
	float  gFogRange;
	float4 gFogColor;
};

cbuffer cbPerObject
{
	float4x4 gViewProj;
};

struct VertexIn
{
	float3 PosL    : POSITION;
	float3 NormalL : NORMAL;
	float2 Tex     : TEXCOORD;
};

struct VertexOut
{
	float3 PosL    : POSITION;
	float3 NormalL : NORMAL;
	float2 Tex     : TEXCOORD;
};

struct GeoOut
{
	float4 PosH    : SV_POSITION;
    float3 PosW    : POSITION;
    float3 NormalW : NORMAL;
    float2 Tex     : TEXCOORD;
};

VertexOut VS(VertexIn vin)
{
	VertexOut vout;

	// Just pass data over to geometry shader.
	vout.PosL = vin.PosL;
	vout.NormalL   = vin.NormalL;
	vout.Tex   = vin.Tex;
	return vout;
}

// read here on sunday:

/*

u figured it out. you were complicating things too much by worrying about triangle strips.

NewSubdivide will return a triangle list every time.
4 triangles per 1 input triangle.

then on the GS just restart the strip every 3 vertices.

done.

*/

[maxvertexcount(3)]
void GS(triangle VertexOut gin[3], 
		uint primID : SV_PrimitiveID,
        inout TriangleStream<GeoOut> triStream)
{	

	VertexOut out_verts[3];
	GeoOut gout[3];

	// this just initializes all the buffers to 0 so it stops erroring out
	//   (i don't know how else to do this in hlsl, maybe there's a memcpy?)
	for(int i = 0; i < 3 ; ++i) {
		out_verts[i].PosL = float3(0.0f,0.0f,0.0f);
		out_verts[i].NormalL = float3(0.0f,0.0f,0.0f);
		out_verts[i].Tex = float2(0.0f, 0.0f);

		gout[i].PosH = float4(0.0f,0.0f,0.0f, 0.0f);
		gout[i].PosW = float3(0.0f,0.0f,0.0f);
		gout[i].NormalW = float3(0.0f,0.0f,0.0f);
		gout[i].Tex = float2(0.0f, 0.0f);
	}

	float3 v_a = gin[1].PosL - gin[0].PosL;
	float3 v_b = gin[2].PosL - gin[0].PosL;

	// normalize this if u want
	float3 face_normal = cross(v_a, v_b);


	out_verts[0] = gin[0];
	out_verts[1] = gin[1];
	out_verts[2] = gin[2];

	float variance = (1.0 + float(primID)) * 0.3 * 2.0;

	// float new_time = fmod(gFogStart, 3.0);
	float new_time = clamp(sin(gFogStart), 0.0, 1.0);

	out_verts[0].PosL += face_normal * new_time * variance;
	out_verts[1].PosL += face_normal * new_time * variance;
	out_verts[2].PosL += face_normal * new_time * variance;

	[unroll]
	for(int j = 0; j < 3; ++j)
	{
		// Transform to world space space.
		gout[j].PosH = mul(float4(out_verts[j].PosL, 1.0f), gViewProj);
		gout[j].PosW = out_verts[j].PosL.xyz;
		gout[j].NormalW = out_verts[j].NormalL;
		// Transform to homogeneous clip space.
		gout[j].Tex = out_verts[j].Tex;

		triStream.Append(gout[j]);
	}
}

float4 PS(GeoOut pin, uniform int gLightCount, uniform bool gUseTexure, uniform bool gAlphaClip, uniform bool gFogEnabled) : SV_Target
{
	return float4(0.0f, 1.0f, 0.0f, 1.0f);
}

//---------------------------------------------------------------------------------------
// Techniques--just define the ones our demo needs; you can define the other 
//   variations as needed.
//---------------------------------------------------------------------------------------
technique11 Light3
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader( CompileShader( gs_5_0, GS() ) );
        SetPixelShader( CompileShader( ps_5_0, PS(3, false, false, false) ) );
    }
}

technique11 Light3TexAlphaClip
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader( CompileShader( gs_5_0, GS() ) );
        SetPixelShader( CompileShader( ps_5_0, PS(3, true, true, false) ) );
    }
}
            
technique11 Light3TexAlphaClipFog
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader( CompileShader( gs_5_0, GS() ) );
        SetPixelShader( CompileShader( ps_5_0, PS(3, true, true, true) ) );
    }
}
