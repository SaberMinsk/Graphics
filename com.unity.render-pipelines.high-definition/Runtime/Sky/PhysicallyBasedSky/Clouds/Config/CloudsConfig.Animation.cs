using System;

namespace UnityEngine.Rendering.HighDefinition
{
    public partial class CloudsConfig
    {
        [Serializable]
        public class AnimationConfig
        {
            private static int PhasePropertyID { get; } = Shader.PropertyToID("_Phase");
            
            [field: SerializeField]
            [field: Range(-1f, 1f)] 
            public float Phase { get; private set; }

            public static AnimationConfig Lerp(AnimationConfig start, AnimationConfig end, float t)
            {
                return new AnimationConfig
                {
                    Phase = Mathf.Lerp(start.Phase, end.Phase, t)
                };
            }
        
            public void ApplyTo(Material mat)
            {
                mat.SetFloat(PhasePropertyID, Phase);
            }
        }
    }
}