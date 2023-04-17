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
RWTexture2D<float> gCurrSolOutput;

[numthreads(N, N, 1)]
void WaveUpdateCS(int3 groupThreadID : SV_GroupThreadID,
    int3 dispatchThreadID : SV_DispatchThreadID)
{

    // NOTE: the original code is indexing the other texture here so we might have a problem.
    float mk1_value = mK1 * gPrevSolInput[dispatchThreadID.xy];
    float mk2_value = mK2 * gPrevSolInput[dispatchThreadID.xy];

    float mk3_value_b = 0.0f;
    mk3_value_b += gPrevSolInput[dispatchThreadID.xy + int2(1, 0)];
    mk3_value_b += gPrevSolInput[dispatchThreadID.xy + int2(-1, 0)];
    mk3_value_b += gPrevSolInput[dispatchThreadID.xy + int2(0, 1)];
    mk3_value_b += gPrevSolInput[dispatchThreadID.xy + int2(0, -1)];
    float mk3_value = mK3 * mk3_value_b;

    gCurrSolOutput[dispatchThreadID.xy] = mk1_value + mk2_value + mk3_value;
}

// needs
/*
magnitude

*/

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
    gCurrSolOutput[the_texel] = gPrevSolInput[the_texel] + magnitude;
    the_texel = dispatchThreadID.xy + int2(1, 0);
    gCurrSolOutput[the_texel] = gPrevSolInput[the_texel] + halfMag;
    the_texel = dispatchThreadID.xy + int2(-1, 0);
    gCurrSolOutput[the_texel] = gPrevSolInput[the_texel] + halfMag;
    the_texel = dispatchThreadID.xy + int2(0, 1);
    gCurrSolOutput[the_texel] = gPrevSolInput[the_texel] + halfMag;
    the_texel = dispatchThreadID.xy + int2(0, -1);
    gCurrSolOutput[the_texel] = gPrevSolInput[the_texel] + halfMag;
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