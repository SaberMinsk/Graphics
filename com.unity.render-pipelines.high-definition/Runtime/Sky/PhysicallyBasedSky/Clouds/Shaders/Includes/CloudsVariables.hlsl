#ifndef CLOUDS_VARIABLES_INCLUDED
#define CLOUDS_VARIABLES_INCLUDED

// Texture
sampler3D _VolumeTex;
float4 _VolumeTex_ST;
float _Octave;
float4 _Sculptures;
float _Warp;
float  _Softness;
float  _Density;
float  _Scale;
float _Resolution;
float _Phase;

// Shape
float  _HorizontalSoftnessTop;
float  _HorizontalSoftnessBottom;
float  _HorizontalSoftnessFigure;
float  _Thickness;
float  _FromHeight;
float  _FromDistance;
float  _MaxDistance;
float  _RelativeHeight;
float  _Fade;

// Lighting
float  _Lighting;
half   _LightingQuality;
float  _LightScattering;
float  _Shading;
float _Coloring;
float _ShadingDist;
float _ShadingDistance;
float _Mie;

// Shadow
float _Shadow;
float _ShadowSoftness;
float _ShadowQuality;
float _ShadowStrength;
float _ShadowThreshold;
half4 _ShadowColor;

#endif