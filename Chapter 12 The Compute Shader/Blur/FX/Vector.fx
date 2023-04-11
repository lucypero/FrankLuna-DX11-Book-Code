// structured buffer which is an array of 3d vectors
ConsumeStructuredBuffer<float3> gInput;

// Output float buffer to store the computed lengths
AppendStructuredBuffer<float> gOutput;

[numthreads(64, 1, 1)]
void CS(int3 dtid : SV_DispatchThreadID)
{
  float3 v = gInput.Consume();
	// calculate length of float3 and put it in outputLengths buffer
  gOutput.Append(length(v));
  // gOutput.Append(0.5f);
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
