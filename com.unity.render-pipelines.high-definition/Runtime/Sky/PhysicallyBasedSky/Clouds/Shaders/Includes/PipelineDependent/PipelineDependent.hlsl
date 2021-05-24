#ifndef MASSIVE_CLOUDS_PIPELINE_DEPENDENT_INCLUDED
#define MASSIVE_CLOUDS_PIPELINE_DEPENDENT_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

cbuffer UnityPerCameraRare
{
    float4 unity_CameraWorldClipPlanes[6];

    #if defined(USING_STEREO_MATRICES)
        #define glstate_matrix_projection unity_StereoMatrixP[unity_StereoEyeIndex]
        #define unity_MatrixV unity_StereoMatrixV[unity_StereoEyeIndex]
        #define unity_MatrixInvV unity_StereoMatrixInvV[unity_StereoEyeIndex]
        #define unity_MatrixVP unity_StereoMatrixVP[unity_StereoEyeIndex]

        #define unity_CameraProjection unity_StereoCameraProjection[unity_StereoEyeIndex]
        #define unity_CameraInvProjection unity_StereoCameraInvProjection[unity_StereoEyeIndex]
        #define unity_WorldToCamera unity_StereoWorldToCamera[unity_StereoEyeIndex]
        #define unity_CameraToWorld unity_StereoCameraToWorld[unity_StereoEyeIndex]
        #define _WorldSpaceCameraPos unity_StereoWorldSpaceCameraPos[unity_StereoEyeIndex]
    #else
        // Projection matrices of the camera. Note that this might be different from projection matrix
        // that is set right now, e.g. while rendering shadows the matrices below are still the projection
        // of original camera.
        float4x4 unity_CameraProjection;
        float4x4 unity_CameraInvProjection;
        float4x4 unity_WorldToCamera;
        float4x4 unity_CameraToWorld;
    #endif
}

#endif
