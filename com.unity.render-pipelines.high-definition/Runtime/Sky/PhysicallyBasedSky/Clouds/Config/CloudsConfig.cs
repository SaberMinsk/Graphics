namespace UnityEngine.Rendering.HighDefinition
{
    [CreateAssetMenu(fileName = nameof(CloudsConfig), menuName = "Configs/Clouds")]
    public partial class CloudsConfig: ScriptableObject
    {
        [field: SerializeField] 
        public SamplerConfig Sampler { get; private set; }
        
        [field: SerializeField]
        public HorizontalShapeConfig HorizontalShape { get; private set; }
        
        [field: SerializeField]
        public LightingConfig Lighting { get; private set; }

        [field: SerializeField]
        public AnimationConfig Animation { get; private set; }
        
        public static CloudsConfig Lerp(CloudsConfig start, CloudsConfig end, float t)
        {
            var result = CreateInstance<CloudsConfig>();

            result.Sampler = SamplerConfig.Lerp(start.Sampler, end.Sampler, t);
            result.HorizontalShape = HorizontalShapeConfig.Lerp(start.HorizontalShape, end.HorizontalShape, t);
            result.Lighting = LightingConfig.Lerp(start.Lighting, end.Lighting, t);
            result.Animation = AnimationConfig.Lerp(start.Animation, end.Animation, t);
                
            return result;
        }
        
        public void ApplyTo(Material target)
        {
            Sampler.ApplyTo(target);
            HorizontalShape.ApplyTo(target);
            Lighting.ApplyTo(target);
            Animation.ApplyTo(target);
        }
    }
}