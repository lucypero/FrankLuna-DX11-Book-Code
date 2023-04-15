// compute shader that will calculate the waves (vertical vertex positions)


#define N 16

cbuffer cbConstants 
{
    uint WavesIndexCountX;
    uint WavesIndexCountZ;
    float dt;
}

Texture2D gPrevSolInput;
RWTexture2D<float> gCurrSolOutput;

[numthreads(N, N, 1)]
void WaveUpdateCS(int3 groupThreadID : SV_GroupThreadID,
    int3 dispatchThreadID : SV_DispatchThreadID)
{
    float height_lol = (dispatchThreadID.x % WavesIndexCountX) / (float)WavesIndexCountX;
    gCurrSolOutput[dispatchThreadID.xy] = height_lol;
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
