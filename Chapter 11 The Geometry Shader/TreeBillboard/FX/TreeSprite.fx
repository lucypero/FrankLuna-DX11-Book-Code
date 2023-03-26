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

void Subdivide(inout VertexOut inVerts[3 * 4 * 4], int num_triangles, inout VertexOut outVerts[3 * 4 * 4])
{
	int triangle_c = 1;

	[unroll]
	for(int i = 0; i < num_triangles; ++i) {
		VertexOut v0 = inVerts[i*3+0];
		VertexOut v1 = inVerts[i*3+1];
		VertexOut v2 = inVerts[i*3+2];

		v0.PosL = normalize(v0.PosL);
		v1.PosL = normalize(v1.PosL);
		v2.PosL = normalize(v2.PosL);

		//
		// Generate the midpoints.
		//

		VertexOut m[3];

		m[0].PosL = 0.5f*(v0.PosL+v1.PosL);
		m[1].PosL = 0.5f*(v1.PosL+v2.PosL);
		m[2].PosL = 0.5f*(v2.PosL+v0.PosL);

		m[0].PosL = normalize(m[0].PosL);
		m[1].PosL = normalize(m[1].PosL);
		m[2].PosL = normalize(m[2].PosL);

		// Derive normals.
		m[0].NormalL = m[0].PosL;
		m[1].NormalL = m[1].PosL;
		m[2].NormalL = m[2].PosL;

		// Interpolate texture coordinates.
		m[0].Tex = 0.5f*(v0.Tex+v1.Tex);
		m[1].Tex = 0.5f*(v1.Tex+v2.Tex);
		m[2].Tex = 0.5f*(v2.Tex+v0.Tex);

		int offset = i * 3 * 4;

		// bottom left corner triangle
		outVerts[offset+0] = v0;
		outVerts[offset+1] = m[0];
		outVerts[offset+2] = m[2];

		// top triangle
		outVerts[offset+3] = m[0];
		outVerts[offset+4] = v1;
		outVerts[offset+5] = m[1];

		// bottom right triangle
		outVerts[offset+6] = m[2];
		outVerts[offset+7] = m[1];
		outVerts[offset+8] = v2;

		// center triangle
		outVerts[offset+9] = m[2];
		outVerts[offset+10] = m[0];
		outVerts[offset+11] = m[1];
	}
};

[maxvertexcount(3 * 4 * 4)]
void GS(triangle VertexOut gin[3], 
        inout TriangleStream<GeoOut> triStream)
{	
	// we only need the magnitude of eye postiion world (bc the sphere is at the origin lol)
	float distance = length(gEyePosW);

	int num_subdivisions = clamp(3 - int(distance / 10.0f), 0, 2);
	int num_vertices = 3 * pow(4, num_subdivisions);

	VertexOut out_verts[3 * 4 * 4];
	VertexOut out_verts_2[3 * 4 * 4];
	GeoOut gout[3 * 4 * 4];

	// this just initializes all the buffers to 0 so it stops erroring out
	//   (i don't know how else to do this in hlsl, maybe there's a memcpy?)
	for(int i = 0; i < 3 * 4 * 4; ++i) {
		out_verts[i].PosL = float3(0.0f,0.0f,0.0f);
		out_verts[i].NormalL = float3(0.0f,0.0f,0.0f);
		out_verts[i].Tex = float2(0.0f, 0.0f);

		out_verts_2[i].PosL = float3(0.0f,0.0f,0.0f);
		out_verts_2[i].NormalL = float3(0.0f,0.0f,0.0f);
		out_verts_2[i].Tex = float2(0.0f, 0.0f);

		gout[i].PosH = float4(0.0f,0.0f,0.0f, 0.0f);
		gout[i].PosW = float3(0.0f,0.0f,0.0f);
		gout[i].NormalW = float3(0.0f,0.0f,0.0f);
		gout[i].Tex = float2(0.0f, 0.0f);
	}

	out_verts[0] = gin[0];
	out_verts[1] = gin[1];
	out_verts[2] = gin[2];

	[flatten]
	if (num_subdivisions >= 1) {
		Subdivide(out_verts, 1, out_verts_2);
		out_verts = out_verts_2;
	}

	[flatten]
	if (num_subdivisions == 2) {
		Subdivide(out_verts_2, 4, out_verts);
	}

	[unroll]
	for(int j = 0; j < num_vertices; ++j)
	{
		// Transform to world space space.
		gout[j].PosH = mul(float4(out_verts[j].PosL, 1.0f), gViewProj);
		gout[j].PosW = out_verts[j].PosL.xyz;
		gout[j].NormalW = out_verts[j].NormalL;
		// Transform to homogeneous clip space.
		gout[j].Tex = out_verts[j].Tex;

		triStream.Append(gout[j]);

		if((j + 1) % 3 == 0) {
			triStream.RestartStrip();
		}
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
