using System;

namespace UnityEngine.Rendering.HighDefinition
{
	public partial class CloudsConfig
	{
		[Serializable]
		public class LightingConfig
		{
			private static int IntensityPropertyID { get; } = Shader.PropertyToID("_Lighting");
			private static int QualityPropertyID { get; } = Shader.PropertyToID("_LightingQuality");
			private static int ScatteringPropertyID { get; } = Shader.PropertyToID("_LightScattering");
			private static int ShadingPropertyID { get; } = Shader.PropertyToID("_Shading");
			private static int ColoringPropertyID { get; } = Shader.PropertyToID("_Coloring");
			private static int ShadingDistancePropertyID { get; } = Shader.PropertyToID("_ShadingDistance");
			private static int MiePropertyID { get; } = Shader.PropertyToID("_Mie");

			[field: SerializeField]
			[field: Range(0f, 10f)]
			public float Intensity { get; private set; }
			
			[field: SerializeField]
			[field: Range(0f, 5f)]
			public float Quality { get; private set; }
			
			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float Scattering { get; private set; }
			
			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float Shading { get; private set; }
			
			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float Coloring { get; private set; }
			
			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float ShadingDistance { get; private set; }
			
			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float Mie { get; private set; }

			public static LightingConfig Lerp(LightingConfig start, LightingConfig end, float t)
			{
				return new LightingConfig
				{
					Intensity = Mathf.Lerp(start.Intensity, end.Intensity, t),
					Quality = Mathf.Lerp(start.Quality, end.Quality, t),
					Scattering = Mathf.Lerp(start.Scattering, end.Scattering, t),
					Shading = Mathf.Lerp(start.Shading, end.Shading, t),
					Coloring = Mathf.Lerp(start.Coloring, end.Coloring, t),
					ShadingDistance = Mathf.Lerp(start.ShadingDistance, end.ShadingDistance, t),
					Mie = Mathf.Lerp(start.Mie, end.Mie, t)
				};
			}

			public void ApplyTo(Material target)
			{
				target.SetFloat(IntensityPropertyID, Intensity);
				target.SetFloat(QualityPropertyID, Quality);
				target.SetFloat(ScatteringPropertyID, Scattering);
				target.SetFloat(ShadingPropertyID, Shading);
				target.SetFloat(ColoringPropertyID, Coloring);
				target.SetFloat(ShadingDistancePropertyID, ShadingDistance);
				target.SetFloat(MiePropertyID, Mie);
			}
		}
	}
}