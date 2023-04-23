// compute shader that will calculate the waves (vertical vertex positions)


#define N 16

#define mK1 -0.991040
#define mK2 1.901443
#define mK3 0.022399

cbuffer cbConstants 
{
    uint WavesIndexCountX;
    uint WavesIndexCountZ;
    float dt;
    float magnitude;
    uint disturbPosX;
    uint disturbPosY;
}

Texture2D gPrevSolInput;
Texture2D gCurrSolInput;
RWTexture2D<float> gNextSolOutput;

[numthreads(N, N, 1)]
void WaveUpdateCS(int3 groupThreadID : SV_GroupThreadID,
    int3 dispatchThreadID : SV_DispatchThreadID)
{

    // NOTE: the original code is indexing the other texture here so we might have a problem.
    float mk1_value = mK1 * gPrevSolInput[dispatchThreadID.xy].r;
    float mk2_value = mK2 * gCurrSolInput[dispatchThreadID.xy].r;

    float mk3_value_b = 0.0f;
    mk3_value_b += gCurrSolInput[dispatchThreadID.xy + int2(1, 0)].r;
    mk3_value_b += gCurrSolInput[dispatchThreadID.xy + int2(-1, 0)].r;
    mk3_value_b += gCurrSolInput[dispatchThreadID.xy + int2(0, 1)].r;
    mk3_value_b += gCurrSolInput[dispatchThreadID.xy + int2(0, -1)].r;
    float mk3_value = mK3 * mk3_value_b;

    gNextSolOutput[dispatchThreadID.xy] = mk1_value + mk2_value + mk3_value;
}

[numthreads(N, N, 1)]
void WaveDisturbCS(int3 groupThreadID : SV_GroupThreadID,
    int3 dispatchThreadID : SV_DispatchThreadID)
{

    int2 disturbPos = int2(disturbPosX, disturbPosY);

    if(disturbPos.x != dispatchThreadID.x || disturbPos.y != dispatchThreadID.y)
    {
        return;
    }

    // disturb
    float halfMag = 0.5f*magnitude;

    int2 the_texel = dispatchThreadID.xy;
    gNextSolOutput[the_texel] = gCurrSolInput[the_texel].r + magnitude;
    the_texel = dispatchThreadID.xy + int2(1, 0);
    gNextSolOutput[the_texel] = gCurrSolInput[the_texel].r + halfMag;
    the_texel = dispatchThreadID.xy + int2(-1, 0);
    gNextSolOutput[the_texel] = gCurrSolInput[the_texel].r + halfMag;
    the_texel = dispatchThreadID.xy + int2(0, 1);
    gNextSolOutput[the_texel] = gCurrSolInput[the_texel].r + halfMag;
    the_texel = dispatchThreadID.xy + int2(0, -1);
    gNextSolOutput[the_texel] = gCurrSolInput[the_texel].r + halfMag;
}

technique11 WaveUpdate
{
    pass P0
    {
		SetVertexShader( NULL );
        SetPixelShader( NULL );
		SetComputeShader( CompileShader( cs_5_0, WaveUpdateCS() ) );
    }
}

technique11 WaveDisturb
{
    pass P0
    {
		SetVertexShader( NULL );
        SetPixelShader( NULL );
		SetComputeShader( CompileShader( cs_5_0, WaveDisturbCS() ) );
    }
}