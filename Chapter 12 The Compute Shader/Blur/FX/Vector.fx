// structured buffer which is an array of 3d vectors
Buffer<float3> gInput;

// Output float buffer to store the computed lengths
Buffer<float> gOutput;

[numthreads(64, 1, 1)]
void CS(int3 dtid : SV_DispatchThreadID)
{

	// calculate length of float3 and put it in outputLengths buffer
	gOutput[dtid.x] = length(gInput[dtid.x]);
}

technique11 Tech
{
    pass P0
    {
		SetVertexShader( NULL );
        SetPixelShader( NULL );
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
    }
}
