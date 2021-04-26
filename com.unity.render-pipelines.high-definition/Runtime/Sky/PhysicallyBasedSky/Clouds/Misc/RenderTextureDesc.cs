namespace UnityEngine.Rendering.HighDefinition
{
    public struct RenderTextureDesc
    {
        public readonly int Width;
        public readonly int Height;

        public RenderTextureDesc(int width, int height) : this()
        {
            Width = width;
            Height = height;
        }
    }
}