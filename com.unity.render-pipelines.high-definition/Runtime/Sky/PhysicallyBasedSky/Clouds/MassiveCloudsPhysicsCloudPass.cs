using System;

namespace UnityEngine.Rendering.HighDefinition
{
    [Serializable]
    public class MassiveCloudsPhysicsCloudPass
    {
        [field: SerializeField]
        public CloudsConfig Profile { get; set; }
        
        public DynamicRenderTexture ScaledRenderTexture { get; private set; }
        public DynamicRenderTexture RenderTexture { get; private set; }
        private Material PhysicsCloudMaterial { get; set; }

        public bool IsActive { get { return Profile != null; } }

        public void ApplyTo(Material mat)
        {
            if (Profile == null)
            {
                return;
            }

            Profile.ApplyTo(mat);
        }

        public void Setup()
        {
            RenderTexture = new DynamicRenderTexture(MassiveCloudsPhysicsCloud.BufferTextureFormat);
            ScaledRenderTexture = new DynamicRenderTexture(MassiveCloudsPhysicsCloud.BufferTextureFormat);

            PhysicsCloudMaterial = new Material(Shader.Find("Clouds"));
        }
        
        public void Update(MassiveCloudsPhysicsCloud context)
        {
            ApplyTo(PhysicsCloudMaterial);
        }

        public void BuildCommandBuffer(CommandBuffer commandBuffer, Camera targetCamera)
        {
            RenderTexture.Update(targetCamera, 1f);
            ScaledRenderTexture.Update(targetCamera, Profile.Sampler.Resolution);

            commandBuffer.Blit(
                RenderTexture.GetRenderTexture(targetCamera),
                ScaledRenderTexture.GetRenderTexture(targetCamera),
                PhysicsCloudMaterial);

            commandBuffer.Blit(
                ScaledRenderTexture.GetRenderTexture(targetCamera),
                RenderTexture.GetRenderTexture(targetCamera));
        }

        public void Dispose()
        {
            RenderTexture?.Dispose();
            ScaledRenderTexture?.Dispose();
        }
    }
}