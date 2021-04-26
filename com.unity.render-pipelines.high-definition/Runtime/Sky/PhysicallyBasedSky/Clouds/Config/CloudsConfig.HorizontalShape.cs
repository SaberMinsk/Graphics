using System;

namespace UnityEngine.Rendering.HighDefinition
{
	public partial class CloudsConfig
	{
		[Serializable]
		public class HorizontalShapeConfig
		{
			private static int FromHeightPropertyID { get; } = Shader.PropertyToID("_FromHeight");
			private static int ThicknessPropertyID { get; } = Shader.PropertyToID("_Thickness");
			private static int HorizontalSoftnessTopPropertyID { get; } = Shader.PropertyToID("_HorizontalSoftnessTop");
			private static int HorizontalSoftnessBottomPropertyID { get; } = Shader.PropertyToID("_HorizontalSoftnessBottom");
			private static int HorizontalSoftnessFigurePropertyID { get; } = Shader.PropertyToID("_HorizontalSoftnessFigure");
			private static int MaxDistancePropertyID { get; } = Shader.PropertyToID("_MaxDistance");

			[field: SerializeField]
			[field: Range(0f, 5000f)]
			public float FromHeight { get; private set; }

			[field: SerializeField]
			[field: Range(0f, 10000f)]
			public float ToHeight { get; private set; }

			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float SoftnessTop { get; private set; }

			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float SoftnessBottom { get; private set; }

			[field: SerializeField]
			[field: Range(0f, 1f)]
			public float Figure { get; private set; }

			[field: SerializeField]
			[field: Range(0f, 200000f)]
			public float MaxDistance { get; private set; }

			public static HorizontalShapeConfig Lerp(
				HorizontalShapeConfig start,
				HorizontalShapeConfig end,
				float t)
			{
				return new HorizontalShapeConfig
				{
					FromHeight = Mathf.Lerp(start.FromHeight, end.FromHeight, t),
					ToHeight = Mathf.Lerp(start.ToHeight, end.ToHeight, t),
					SoftnessTop = Mathf.Lerp(start.SoftnessTop, end.SoftnessTop, t),
					SoftnessBottom = Mathf.Lerp(start.SoftnessBottom, end.SoftnessBottom, t),
					Figure = Mathf.Lerp(start.Figure, end.Figure, t),
					MaxDistance = Mathf.Lerp(start.MaxDistance, end.MaxDistance, t)
				};
			}

			public void ApplyTo(Material target)
			{
				target.SetFloat(FromHeightPropertyID, FromHeight);
				target.SetFloat(ThicknessPropertyID, ToHeight - FromHeight);
				target.SetFloat(HorizontalSoftnessTopPropertyID, SoftnessTop);
				target.SetFloat(HorizontalSoftnessBottomPropertyID, SoftnessBottom);
				target.SetFloat(HorizontalSoftnessFigurePropertyID, Figure);
				target.SetFloat(MaxDistancePropertyID, MaxDistance);
			}
		}
	}
}