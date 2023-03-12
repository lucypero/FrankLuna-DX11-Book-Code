//***************************************************************************************
// RenderStates.cpp by Frank Luna (C) 2011 All Rights Reserved.
//***************************************************************************************

#include "RenderStates.h"

ID3D11RasterizerState* RenderStates::WireframeRS = 0;
ID3D11RasterizerState* RenderStates::NoCullRS    = 0;
	 
ID3D11BlendState*      RenderStates::AlphaToCoverageBS = 0;
ID3D11BlendState*      RenderStates::TransparentBS     = 0;
ID3D11BlendState*      RenderStates::AdditiveBS     = 0;


ID3D11DepthStencilState* RenderStates::NoDepthWritesDSS = 0;

void RenderStates::InitAll(ID3D11Device* device)
{
	//
	// WireframeRS
	//
	D3D11_RASTERIZER_DESC wireframeDesc;
	ZeroMemory(&wireframeDesc, sizeof(D3D11_RASTERIZER_DESC));
	wireframeDesc.FillMode = D3D11_FILL_WIREFRAME;
	wireframeDesc.CullMode = D3D11_CULL_BACK;
	wireframeDesc.FrontCounterClockwise = false;
	wireframeDesc.DepthClipEnable = true;

	HR(device->CreateRasterizerState(&wireframeDesc, &WireframeRS));

	//
	// NoCullRS
	//
	D3D11_RASTERIZER_DESC noCullDesc;
	ZeroMemory(&noCullDesc, sizeof(D3D11_RASTERIZER_DESC));
	noCullDesc.FillMode = D3D11_FILL_SOLID;
	noCullDesc.CullMode = D3D11_CULL_NONE;
	noCullDesc.FrontCounterClockwise = false;
	noCullDesc.DepthClipEnable = true;

	HR(device->CreateRasterizerState(&noCullDesc, &NoCullRS));

	//
	// AlphaToCoverageBS
	//

	D3D11_BLEND_DESC alphaToCoverageDesc = {0};
	alphaToCoverageDesc.AlphaToCoverageEnable = true;
	alphaToCoverageDesc.IndependentBlendEnable = false;
	alphaToCoverageDesc.RenderTarget[0].BlendEnable = false;
	alphaToCoverageDesc.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;

	HR(device->CreateBlendState(&alphaToCoverageDesc, &AlphaToCoverageBS));

	//
	// TransparentBS
	//

	D3D11_BLEND_DESC transparentDesc = {0};
	transparentDesc.AlphaToCoverageEnable = false;
	transparentDesc.IndependentBlendEnable = false;

	transparentDesc.RenderTarget[0].BlendEnable = true;
	transparentDesc.RenderTarget[0].SrcBlend       = D3D11_BLEND_SRC_ALPHA;
	transparentDesc.RenderTarget[0].DestBlend      = D3D11_BLEND_INV_SRC_ALPHA;
	transparentDesc.RenderTarget[0].BlendOp        = D3D11_BLEND_OP_ADD;
	transparentDesc.RenderTarget[0].SrcBlendAlpha  = D3D11_BLEND_ONE;
	transparentDesc.RenderTarget[0].DestBlendAlpha = D3D11_BLEND_ZERO;
	transparentDesc.RenderTarget[0].BlendOpAlpha   = D3D11_BLEND_OP_ADD;
	transparentDesc.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;

	HR(device->CreateBlendState(&transparentDesc, &TransparentBS));

	//
	// AdditiveBS
	//

	{
		D3D11_BLEND_DESC desc = {0};
		desc.AlphaToCoverageEnable = false;
		desc.IndependentBlendEnable = false;

		desc.RenderTarget[0].BlendEnable = true;
		desc.RenderTarget[0].SrcBlend       = D3D11_BLEND_ONE;
		desc.RenderTarget[0].DestBlend      = D3D11_BLEND_ONE;
		desc.RenderTarget[0].BlendOp        = D3D11_BLEND_OP_ADD;
		desc.RenderTarget[0].SrcBlendAlpha  = D3D11_BLEND_ONE;
		desc.RenderTarget[0].DestBlendAlpha = D3D11_BLEND_ZERO;
		desc.RenderTarget[0].BlendOpAlpha   = D3D11_BLEND_OP_ADD;
		desc.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;
		HR(device->CreateBlendState(&desc, &AdditiveBS));
	}

	// no depth writes ds state

	{
		D3D11_DEPTH_STENCIL_DESC blend_desc;
		blend_desc.DepthEnable      = true;
		blend_desc.DepthWriteMask   = D3D11_DEPTH_WRITE_MASK_ZERO;
		blend_desc.DepthFunc        = D3D11_COMPARISON_LESS; 
		blend_desc.StencilEnable    = false;
		blend_desc.StencilReadMask  = 0x00;
		blend_desc.StencilWriteMask = 0x00;

		blend_desc.FrontFace.StencilFailOp      = D3D11_STENCIL_OP_KEEP;
		blend_desc.FrontFace.StencilDepthFailOp = D3D11_STENCIL_OP_KEEP;
		blend_desc.FrontFace.StencilPassOp = D3D11_STENCIL_OP_INCR;
		blend_desc.FrontFace.StencilFunc   = D3D11_COMPARISON_EQUAL;

		// We are not rendering backfacing polygons, so these settings do not matter.
		blend_desc.BackFace.StencilFailOp      = D3D11_STENCIL_OP_KEEP;
		blend_desc.BackFace.StencilDepthFailOp = D3D11_STENCIL_OP_KEEP;
		blend_desc.BackFace.StencilPassOp = D3D11_STENCIL_OP_INCR;
		blend_desc.BackFace.StencilFunc   = D3D11_COMPARISON_EQUAL;

		HR(device->CreateDepthStencilState(&blend_desc, &NoDepthWritesDSS));
	}

}

void RenderStates::DestroyAll()
{
	ReleaseCOM(WireframeRS);
	ReleaseCOM(NoCullRS);
	ReleaseCOM(AlphaToCoverageBS);
	ReleaseCOM(TransparentBS);
}