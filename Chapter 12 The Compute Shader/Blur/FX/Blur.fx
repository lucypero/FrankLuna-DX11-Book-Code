// Constants
#define N 16

// not used for now
// #define CacheSize (N + 2*gBlurRadius)
// groupshared float4 gCache[CacheSize];

// BilateralBlur.hlsl

// Shader resources
Texture2D<float4> inputTexture : register(t0);
RWTexture2D<float4> outputTexture : register(u0);

// Constants
#define blurRadius 5.0f
#define sigmaSpace 1.0f
#define sigmaColor 0.1f

// Helper functions
float Gaussian(float x, float sigma)
{
    return exp(-(x * x) / (2 * sigma * sigma)) / (sigma * sqrt(2 * 3.141592));
}

float4 DoBlur(uint3 id : SV_DispatchThreadID)
{
    float2 texSize;
    inputTexture.GetDimensions(texSize.x, texSize.y);

    float2 texCoord = id.xy / texSize;

    float4 centerColor = inputTexture[id.xy];
    float4 sum = float4(0, 0, 0, 0);
    float totalWeight = 0;

    for (int y = -blurRadius; y <= blurRadius; ++y)
    {
        for (int x = -blurRadius; x <= blurRadius; ++x)
        {
            float2 offset = float2(x, y);
            float4 currentColor = inputTexture[id.xy + offset];

            float spatialWeight = Gaussian(length(float2(x, y)), sigmaSpace);
            float colorWeight = Gaussian(length(centerColor.rgb - currentColor.rgb), sigmaColor);

            float weight = spatialWeight * colorWeight;

            sum += currentColor * weight;
            totalWeight += weight;
        }
    }

    return sum / totalWeight;
}

// Main compute shader function
[numthreads(N, N, 1)]
void BlurCS(uint3 id : SV_DispatchThreadID)
{
    outputTexture[id.xy] = DoBlur(id);
}

[numthreads(N, N, 1)]
void CopyCS(int3 groupThreadID : SV_GroupThreadID,
				int3 dispatchThreadID : SV_DispatchThreadID)
{   
    // Read from the SRV and write to the UAV
    float4 srcData = inputTexture[dispatchThreadID.xy]; // Load data from SRV
    outputTexture[dispatchThreadID.xy] = srcData; // Write data to UAV
}

technique11 BilateralBlur
{
    pass P0
    {
		SetVertexShader( NULL );
        SetPixelShader( NULL );
		SetComputeShader( CompileShader( cs_5_0, BlurCS() ) );
    }
}


technique11 Copy
{
    pass P0
    {
		SetVertexShader( NULL );
        SetPixelShader( NULL );
		SetComputeShader( CompileShader( cs_5_0, CopyCS() ) );
    }
}


