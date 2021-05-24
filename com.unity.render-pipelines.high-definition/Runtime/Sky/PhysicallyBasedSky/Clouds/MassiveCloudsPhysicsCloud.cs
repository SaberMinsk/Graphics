using System;

namespace UnityEngine.Rendering.HighDefinition
{
    public class MassiveCloudsPhysicsCloud: ScriptableObject
    {
        private static int CloudsTextureMainPropertyID { get; } = Shader.PropertyToID("_CloudsTexture");
        private static int CloudsTextureAdditionalPropertyID { get; } = Shader.PropertyToID("_CloudsTextureAdditional");

        public const RenderTextureFormat BufferTextureFormat = RenderTextureFormat.ARGBFloat;

        [field: SerializeField]
        public MassiveCloudsPhysicsCloudPass PhysicsCloudPass { get; private set; }

        [field: SerializeField]
        public MassiveCloudsPhysicsCloudPass LayeredCloudPass { get; private set; }

        public void Setup()
        {
            PhysicsCloudPass.Setup();
            LayeredCloudPass.Setup();
        }

        public void BuildCommandBuffer(CommandBuffer commandBuffer, Camera targetCamera, Action action)
        {
            PhysicsCloudPass.Update(this);
            LayeredCloudPass.Update(this);

            if (PhysicsCloudPass.Profile != null)
            {
                PhysicsCloudPass.BuildCommandBuffer(commandBuffer, targetCamera);
                Shader.SetGlobalTexture(
                    CloudsTextureMainPropertyID,
                    PhysicsCloudPass.RenderTexture.GetRenderTexture(targetCamera));
            }

            if (LayeredCloudPass.Profile != null)
            {
                LayeredCloudPass.BuildCommandBuffer(commandBuffer, targetCamera);
                Shader.SetGlobalTexture(
                    CloudsTextureAdditionalPropertyID,
                    LayeredCloudPass.RenderTexture.GetRenderTexture(targetCamera));
            }
        }

        public void Dispose()
        {
            PhysicsCloudPass.Dispose();
            LayeredCloudPass.Dispose();
        }
    }
}
