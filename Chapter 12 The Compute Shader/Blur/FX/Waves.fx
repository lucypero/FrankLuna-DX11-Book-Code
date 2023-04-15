// compute shader that will calculate the waves (vertical vertex positions)


#define N 16


[numthreads(N, N, 1)]
void WaveUpdateCS(int3 groupThreadID : SV_GroupThreadID,
    int3 dispatchThreadID : SV_DispatchThreadID)
{
    

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
