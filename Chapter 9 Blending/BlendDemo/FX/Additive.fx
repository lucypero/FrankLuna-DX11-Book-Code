// effect for particles and additive stuff
// no lighting, no fog

// Nonnumeric values cannot be added to a cbuffer.
Texture2D gDiffuseMap;

SamplerState samAnisotropic
{
	Filter = ANISOTROPIC;
	MaxAnisotropy = 4;

	AddressU = WRAP;
	AddressV = WRAP;
};

cbuffer cbPerObject
{
	float4x4 gWorldViewProj;
	float4x4 gTexTransform;
}; 

struct VertexIn
{
	float3 PosL    : POSITION;
	float3 NormalL : NORMAL;
	float2 Tex     : TEXCOORD;
};

struct VertexOut
{
	float4 PosH    : SV_POSITION;
	float2 Tex     : TEXCOORD;
};

VertexOut VS(VertexIn vin)
{
	VertexOut vout;
	
	// Transform to homogeneous clip space.
	vout.PosH = mul(float4(vin.PosL, 1.0f), gWorldViewProj);
	
	// Output vertex attributes for interpolation across triangle.
	vout.Tex = mul(float4(vin.Tex, 0.0f, 1.0f), gTexTransform).xy;

	return vout;
}
 
float4 PS(VertexOut pin, uniform bool gAlphaClip) : SV_Target
{
    // Default to multiplicative identity.
    float4 texColor = float4(1, 1, 1, 1);
    // Sample texture.
    texColor = gDiffuseMap.Sample( samAnisotropic, pin.Tex );

    if(gAlphaClip)
    {
        // Discard pixel if texture alpha < 0.1.  Note that we do this
        // test as soon as possible so that we can potentially exit the shader 
        // early, thereby skipping the rest of the shader code.
        clip(texColor.a - 0.1f);
    }

    return texColor;
}

technique11 AdditiveTech
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_5_0, PS(false) ) );
    }
}