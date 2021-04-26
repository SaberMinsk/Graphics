using System;

namespace UnityEngine.Rendering.HighDefinition
{
	public partial class CloudsConfig
	{
		[Serializable]
		public class SamplerConfig
		{
			private static int VolumeTexturePropertyID { get; } = Shader.PropertyToID("_VolumeTex");
			private static int OctavePropertyID { get; } = Shader.PropertyToID("_Octave");
			private static int SculpturesPropertyID { get; } = Shader.PropertyToID("_Sculptures");
			private static int WarpPropertyID { get; } = Shader.PropertyToID("_Warp");
			private static int SoftnessPropertyID { get; } = Shader.PropertyToID("_Softness");
			private static int DensityPropertyID { get; } = Shader.PropertyToID("_Density");
			private static int ScalePropertyID { get; } = Shader.PropertyToID("_Scale");
			private static int ResolutionPropertyID { get; } = Shader.PropertyToID("_Resolution");

			[field: SerializeField]
			public Texture3D VolumeTexture { get; private set; }

			[field: SerializeField]
			public Vector2 Tiling { get; private set; }

			[field: SerializeField]
			[field: Range(0f, 0.001f)]
			public float Octave { get; private set; } = 4f;

			[field: SerializeField]
			public Vector4 Sculptures { get; private set; }

			[field: SerializeField]
			[field: Range(-1000f, 1000f)]
			public float Warp { get; private set; }

			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float Softness { get; private set; } = 0.5f;

			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float Density { get; private set; } = 0.5f;

			[field: SerializeField]
			[field: Range(0.1f, 10f)]
			public float Scale { get; private set; } = 5f;

			[field: SerializeField]
			[field: Range(0.1f, 1f)]
			public float Resolution { get; private set; } = 1f;

			public static SamplerConfig Lerp(SamplerConfig start, SamplerConfig end, float t)
			{
				return new SamplerConfig
				{
					VolumeTexture = start.VolumeTexture,
					Tiling = Vector2.Lerp(start.Tiling, end.Tiling, t),
					Octave = Mathf.Lerp(start.Octave, end.Octave, t),
					Sculptures = Vector4.Lerp(start.Sculptures, end.Sculptures, t),
					Warp = Mathf.Lerp(start.Warp, end.Warp, t),
					Softness = Mathf.Lerp(start.Softness, end.Softness, t),
					Density = Mathf.Lerp(start.Density, end.Density, t),
					Scale = Mathf.Lerp(start.Scale, end.Scale, t)
				};
			}

			public void ApplyTo(Material target)
			{
				target.SetTexture(VolumeTexturePropertyID, VolumeTexture);
				target.SetTextureScale(VolumeTexturePropertyID, Tiling);
				target.SetFloat(OctavePropertyID, Octave);
				target.SetVector(SculpturesPropertyID, Sculptures);
				target.SetFloat(WarpPropertyID, Warp);
				target.SetFloat(SoftnessPropertyID, Softness);
				target.SetFloat(DensityPropertyID, Density);
				target.SetFloat(ScalePropertyID, Scale);
				target.SetFloat(ResolutionPropertyID, Resolution);
			}
		}
	}
}