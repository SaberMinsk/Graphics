Shader "Clouds"
{
	Properties
	{
	    [HideInInspector]
		_MainTex ("Texture", 2D) = "white" {}
    }

	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			HLSLPROGRAM

			#pragma target 5.0
			#pragma vertex CloudsVert
			#pragma fragment CloudsFrag

			#include "Includes/Clouds.hlsl"
            
			ENDHLSL
		}
	}
}