//***************************************************************************************
// Effects.h by Frank Luna (C) 2011 All Rights Reserved.
//
// Defines lightweight effect wrappers to group an effect and its variables.
// Also defines a static Effects class from which we can access all of our effects.
//***************************************************************************************

#ifndef EFFECTS_H
#define EFFECTS_H

#include "d3dUtil.h"

using namespace DirectX;

#pragma region Effect
class Effect
{
public:
	Effect(ID3D11Device* device, const std::wstring& filename);
	virtual ~Effect();

private:
	Effect(const Effect& rhs);
	Effect& operator=(const Effect& rhs);

protected:
	ID3DX11Effect* mFX;
};
#pragma endregion

#pragma region BasicEffect
class BasicEffect : public Effect
{
public:
	BasicEffect(ID3D11Device* device, const std::wstring& filename);
	~BasicEffect();

	void SetWorldViewProj(CXMMATRIX M)                  { WorldViewProj->SetMatrix(reinterpret_cast<const float*>(&M)); }
	void SetWorld(CXMMATRIX M)                          { World->SetMatrix(reinterpret_cast<const float*>(&M)); }
	void SetWorldInvTranspose(CXMMATRIX M)              { WorldInvTranspose->SetMatrix(reinterpret_cast<const float*>(&M)); }
	void SetTexTransform(CXMMATRIX M)                   { TexTransform->SetMatrix(reinterpret_cast<const float*>(&M)); }
	void SetEyePosW(const XMFLOAT3& v)                  { EyePosW->SetRawValue(&v, 0, sizeof(XMFLOAT3)); }
	void SetFogColor(const FXMVECTOR v)                 { FogColor->SetFloatVector(reinterpret_cast<const float*>(&v)); }
	void SetFogStart(float f)                           { FogStart->SetFloat(f); }
	void SetFogRange(float f)                           { FogRange->SetFloat(f); }
	void SetDirLights(const DirectionalLight* lights)   { DirLights->SetRawValue(lights, 0, 3*sizeof(DirectionalLight)); }
	void SetMaterial(const Material& mat)               { Mat->SetRawValue(&mat, 0, sizeof(Material)); }
	void SetDiffuseMap(ID3D11ShaderResourceView* tex)   { DiffuseMap->SetResource(tex); }
	void SetDisplacementMap(ID3D11ShaderResourceView* tex)   { DisplacementMap->SetResource(tex); }


	void SetWaveIndexCountX(int mWavesVertexCountX) { WaveIndexCountX->SetInt(mWavesVertexCountX); }
	void SetWaveIndexCountZ(int mWavesVertexCountZ) { WaveIndexCountZ->SetInt(mWavesVertexCountZ); }

	ID3DX11EffectTechnique* Light1Tech;
	ID3DX11EffectTechnique* Light2Tech;
	ID3DX11EffectTechnique* Light3Tech;

	ID3DX11EffectTechnique* Light0TexTech;
	ID3DX11EffectTechnique* Light1TexTech;
	ID3DX11EffectTechnique* Light2TexTech;
	ID3DX11EffectTechnique* Light3TexTech;

	ID3DX11EffectTechnique* Light0TexAlphaClipTech;
	ID3DX11EffectTechnique* Light1TexAlphaClipTech;
	ID3DX11EffectTechnique* Light2TexAlphaClipTech;
	ID3DX11EffectTechnique* Light3TexAlphaClipTech;

	ID3DX11EffectTechnique* Light1FogTech;
	ID3DX11EffectTechnique* Light2FogTech;
	ID3DX11EffectTechnique* Light3FogTech;

	ID3DX11EffectTechnique* Light0TexFogTech;
	ID3DX11EffectTechnique* Light1TexFogTech;
	ID3DX11EffectTechnique* Light2TexFogTech;
	ID3DX11EffectTechnique* Light3TexFogTech;

	ID3DX11EffectTechnique* Light0TexAlphaClipFogTech;
	ID3DX11EffectTechnique* Light1TexAlphaClipFogTech;
	ID3DX11EffectTechnique* Light2TexAlphaClipFogTech;
	ID3DX11EffectTechnique* Light3TexAlphaClipFogTech;

	ID3DX11EffectTechnique* WavesTech;

	ID3DX11EffectMatrixVariable* WorldViewProj;
	ID3DX11EffectMatrixVariable* World;
	ID3DX11EffectMatrixVariable* WorldInvTranspose;
	ID3DX11EffectMatrixVariable* TexTransform;
	ID3DX11EffectVectorVariable* EyePosW;
	ID3DX11EffectVectorVariable* FogColor;
	ID3DX11EffectScalarVariable* FogStart;
	ID3DX11EffectScalarVariable* FogRange;
	ID3DX11EffectVariable* DirLights;
	ID3DX11EffectVariable* Mat;

	ID3DX11EffectScalarVariable* WaveIndexCountX;
	ID3DX11EffectScalarVariable* WaveIndexCountZ;

	ID3DX11EffectShaderResourceVariable* DiffuseMap;
	ID3DX11EffectShaderResourceVariable* DisplacementMap;
};
#pragma endregion

#pragma region BlurEffect
class BlurEffect : public Effect
{
public:
	BlurEffect(ID3D11Device* device, const std::wstring& filename);
	~BlurEffect();

	void SetWeights(const float weights[9])           { Weights->SetFloatArray(weights, 0, 9); }
	void SetInputMap(ID3D11ShaderResourceView* tex)   { InputMap->SetResource(tex); }
	void SetOutputMap(ID3D11UnorderedAccessView* tex) { OutputMap->SetUnorderedAccessView(tex); }

	ID3DX11EffectTechnique* HorzBlurTech;
	ID3DX11EffectTechnique* VertBlurTech;
	ID3DX11EffectTechnique* CopyTech;

	ID3DX11EffectScalarVariable* Weights;
	ID3DX11EffectShaderResourceVariable* InputMap;
	ID3DX11EffectUnorderedAccessViewVariable* OutputMap;
};
#pragma endregion

// Compute shader that computes the displacement map each frame
class WaveEffect : public Effect
{
public:
	WaveEffect(ID3D11Device* device, const std::wstring& filename);
	~WaveEffect();

	void SetPrevSolInput(ID3D11ShaderResourceView* tex)   { PrevSolInput->SetResource(tex); }
	void SetCurSolInput(ID3D11ShaderResourceView* tex)   { CurSolInput->SetResource(tex); }

	void SetCurSolOutput(ID3D11UnorderedAccessView* tex) { CurSolOutput->SetUnorderedAccessView(tex); }
	void SetNextSolOutput(ID3D11UnorderedAccessView* tex) { NextSolOutput->SetUnorderedAccessView(tex); }

	void SetWaveIndexCountX(int mWavesVertexCountX) { WaveIndexCountX->SetInt(mWavesVertexCountX); }
	void SetWaveIndexCountZ(int mWavesVertexCountZ) { WaveIndexCountZ->SetInt(mWavesVertexCountZ); }

	void SetDisturbPos(int x, int y) { disturbPosX->SetInt(x); disturbPosY->SetInt(y); }

	void SetDT(float dt) { Dt->SetFloat(dt); }
	void SetMagnitude(float m) { magnitude->SetFloat(m); }

	ID3DX11EffectScalarVariable* WaveIndexCountX;
	ID3DX11EffectScalarVariable* WaveIndexCountZ;
	ID3DX11EffectScalarVariable* Dt;
	ID3DX11EffectScalarVariable* magnitude;

	ID3DX11EffectScalarVariable* disturbPosX;
	ID3DX11EffectScalarVariable* disturbPosY;

	ID3DX11EffectTechnique* WaveUpdateTech;
	ID3DX11EffectTechnique* WaveDisturbTech;

	ID3DX11EffectShaderResourceVariable* PrevSolInput;
	ID3DX11EffectShaderResourceVariable* CurSolInput;

	ID3DX11EffectUnorderedAccessViewVariable* CurSolOutput;
	ID3DX11EffectUnorderedAccessViewVariable* NextSolOutput;
};

#pragma region Effects
class Effects
{
public:
	static void InitAll(ID3D11Device* device);
	static void DestroyAll();

	static BasicEffect* BasicFX;
	static BlurEffect* BlurFX;
	static WaveEffect* WaveFX;
};
#pragma endregion

#endif // EFFECTS_H