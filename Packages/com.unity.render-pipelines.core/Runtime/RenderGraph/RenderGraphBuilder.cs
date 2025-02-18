using System;
using System.Collections.Generic;
using UnityEngine.Rendering;

namespace UnityEngine.Experimental.Rendering.RenderGraphModule
{
    /// <summary>
    /// Use this struct to set up a new Render Pass.
    /// </summary>
    public struct RenderGraphBuilder : IDisposable
    {
        RenderGraphPass m_RenderPass;
        RenderGraphResourceRegistry m_Resources;
        RenderGraph m_RenderGraph;
        bool m_Disposed;

        #region Public Interface
        /// <summary>
        /// Specify that the pass will use a Texture resource as a color render target.
        /// This has the same effect as WriteTexture and also automatically sets the Texture to use as a render target.
        /// </summary>
        /// <param name="input">The Texture resource to use as a color render target.</param>
        /// <param name="index">Index for multiple render target usage.</param>
        /// <returns>An updated resource handle to the input resource.</returns>
        public TextureHandle UseColorBuffer(in TextureHandle input, int index)
        {
            CheckResource(input.handle, true);
            m_Resources.IncrementWriteCount(input.handle);
            m_RenderPass.SetColorBuffer(input, index);
            return input;
        }

        /// <summary>
        /// Specify that the pass will use a Texture resource as a depth buffer.
        /// </summary>
        /// <param name="input">The Texture resource to use as a depth buffer during the pass.</param>
        /// <param name="flags">Specify the access level for the depth buffer. This allows you to say whether you will read from or write to the depth buffer, or do both.</param>
        /// <returns>An updated resource handle to the input resource.</returns>
        public TextureHandle UseDepthBuffer(in TextureHandle input, DepthAccess flags)
        {
            CheckResource(input.handle, true);
            m_Resources.IncrementWriteCount(input.handle);
            m_RenderPass.SetDepthBuffer(input, flags);
            return input;
        }

        /// <summary>
        /// Specify a Texture resource to read from during the pass.
        /// </summary>
        /// <param name="input">The Texture resource to read from during the pass.</param>
        /// <returns>An updated resource handle to the input resource.</returns>
        public TextureHandle ReadTexture(in TextureHandle input)
        {
            CheckResource(input.handle);

            if (!m_Resources.IsRenderGraphResourceImported(input.handle) && m_Resources.TextureNeedsFallback(input))
            {
                // If texture is read from but never written to, return a fallback black texture to have valid reads
                // Return one from the preallocated default textures if possible
                var desc = m_Resources.GetTextureResourceDesc(input.handle);
                if (!desc.bindTextureMS)
                {
                    if (desc.dimension == TextureXR.dimension)
                        return m_RenderGraph.defaultResources.blackTextureXR;
                    else if (desc.dimension == TextureDimension.Tex3D)
                        return m_RenderGraph.defaultResources.blackTexture3DXR;
                    else
                        return m_RenderGraph.defaultResources.blackTexture;
                }
                // If not, force a write to the texture so that it gets allocated, and ensure it gets initialized with a clear color
                if (!desc.clearBuffer)
                    m_Resources.ForceTextureClear(input.handle, Color.black);
                WriteTexture(input);
            }

            m_RenderPass.AddResourceRead(input.handle);
            return input;
        }

        /// <summary>
        /// Specify a Texture resource to write to during the pass.
        /// </summary>
        /// <param name="input">The Texture resource to write to during the pass.</param>
        /// <returns>An updated resource handle to the input resource.</returns>
        public TextureHandle WriteTexture(in TextureHandle input)
        {
            CheckResource(input.handle);
            m_Resources.IncrementWriteCount(input.handle);
            m_RenderPass.AddResourceWrite(input.handle);
            return input;
        }

        /// <summary>
        /// Specify a Texture resource to read and write to during the pass.
        /// </summary>
        /// <param name="input">The Texture resource to read and write to during the pass.</param>
        /// <returns>An updated resource handle to the input resource.</returns>
        public TextureHandle ReadWriteTexture(in TextureHandle input)
        {
            CheckResource(input.handle);
            m_Resources.IncrementWriteCount(input.handle);
            m_RenderPass.AddResourceWrite(input.handle);
            m_RenderPass.AddResourceRead(input.handle);
            return input;
        }

        /// <summary>
        /// Create a new Render Graph Texture resource.
        /// This texture will only be available for the current pass and will be assumed to be both written and read so users don't need to add explicit read/write declarations.
        /// </summary>
        /// <param name="desc">Texture descriptor.</param>
        /// <returns>A new transient TextureHandle.</returns>
        public TextureHandle CreateTransientTexture(in TextureDesc desc)
        {
            var result = m_Resources.CreateTexture(desc, m_RenderPass.index);
            m_RenderPass.AddTransientResource(result.handle);
            return result;
        }

        /// <summary>
        /// Create a new Render Graph Texture resource using the descriptor from another texture.
        /// This texture will only be available for the current pass and will be assumed to be both written and read so users don't need to add explicit read/write declarations.
        /// </summary>
        /// <param name="texture">Texture from which the descriptor should be used.</param>
        /// <returns>A new transient TextureHandle.</returns>
        public TextureHandle CreateTransientTexture(in TextureHandle texture)
        {
            var desc = m_Resources.GetTextureResourceDesc(texture.handle);
            var result = m_Resources.CreateTexture(desc, m_RenderPass.index);
            m_RenderPass.AddTransientResource(result.handle);
            return result;
        }

        /// <summary>
        /// Specify a Renderer List resource to use during the pass.
        /// </summary>
        /// <param name="input">The Renderer List resource to use during the pass.</param>
        /// <returns>An updated resource handle to the input resource.</returns>
        public RendererListHandle UseRendererList(in RendererListHandle input)
        {
            m_RenderPass.UseRendererList(input);
            return input;
        }

        /// <summary>
        /// Specify a Graphics Buffer resource to read from during the pass.
        /// </summary>
        /// <param name="input">The Graphics Buffer resource to read from during the pass.</param>
        /// <returns>An updated resource handle to the input resource.</returns>
        public BufferHandle ReadBuffer(in BufferHandle input)
        {
            CheckResource(input.handle);
            m_RenderPass.AddResourceRead(input.handle);
            return input;
        }

        /// <summary>
        /// Specify a Graphics Buffer resource to write to during the pass.
        /// </summary>
        /// <param name="input">The Graphics Buffer resource to write to during the pass.</param>
        /// <returns>An updated resource handle to the input resource.</returns>
        public BufferHandle WriteBuffer(in BufferHandle input)
        {
            CheckResource(input.handle);
            m_RenderPass.AddResourceWrite(input.handle);
            m_Resources.IncrementWriteCount(input.handle);
            return input;
        }

        /// <summary>
        /// Create a new Render Graph Graphics Buffer resource.
        /// This Graphics Buffer will only be available for the current pass and will be assumed to be both written and read so users don't need to add explicit read/write declarations.
        /// </summary>
        /// <param name="desc">Graphics Buffer descriptor.</param>
        /// <returns>A new transient GraphicsBufferHandle.</returns>
        public BufferHandle CreateTransientBuffer(in BufferDesc desc)
        {
            var result = m_Resources.CreateBuffer(desc, m_RenderPass.index);
            m_RenderPass.AddTransientResource(result.handle);
            return result;
        }

        /// <summary>
        /// Create a new Render Graph Graphics Buffer resource using the descriptor from another Graphics Buffer.
        /// This Graphics Buffer will only be available for the current pass and will be assumed to be both written and read so users don't need to add explicit read/write declarations.
        /// </summary>
        /// <param name="graphicsbuffer">Graphics Buffer from which the descriptor should be used.</param>
        /// <returns>A new transient GraphicsBufferHandle.</returns>
        public BufferHandle CreateTransientBuffer(in BufferHandle graphicsbuffer)
        {
            var desc = m_Resources.GetBufferResourceDesc(graphicsbuffer.handle);
            var result = m_Resources.CreateBuffer(desc, m_RenderPass.index);
            m_RenderPass.AddTransientResource(result.handle);
            return result;
        }

        /// <summary>
        /// Specify the render function to use for this pass.
        /// A call to this is mandatory for the pass to be valid.
        /// </summary>
        /// <typeparam name="PassData">The Type of the class that provides data to the Render Pass.</typeparam>
        /// <param name="renderFunc">Render function for the pass.</param>
        public void SetRenderFunc<PassData>(RenderFunc<PassData> renderFunc) where PassData : class, new()
        {
            ((RenderGraphPass<PassData>)m_RenderPass).renderFunc = renderFunc;
        }

        /// <summary>
        /// Enable asynchronous compute for this pass.
        /// </summary>
        /// <param name="value">Set to true to enable asynchronous compute.</param>
        public void EnableAsyncCompute(bool value)
        {
            m_RenderPass.EnableAsyncCompute(value);
        }

        /// <summary>
        /// Allow or not pass culling
        /// By default all passes can be culled out if the render graph detects it's not actually used.
        /// In some cases, a pass may not write or read any texture but rather do something with side effects (like setting a global texture parameter for example).
        /// This function can be used to tell the system that it should not cull this pass.
        /// </summary>
        /// <param name="value">True to allow pass culling.</param>
        public void AllowPassCulling(bool value)
        {
            m_RenderPass.AllowPassCulling(value);
        }

        /// <summary>
        /// Dispose the RenderGraphBuilder instance.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
        }

        /// <summary>
        /// Allow or not pass culling based on renderer list results
        /// By default all passes can be culled out if the render graph detects they are using a renderer list that is empty (does not draw any geometry)
        /// In some cases, a pass may not write or read any texture but rather do something with side effects (like setting a global texture parameter for example).
        /// This function can be used to tell the system that it should not cull this pass.
        /// </summary>
        /// <param name="value">True to allow pass culling.</param>
        public void AllowRendererListCulling(bool value)
        {
            m_RenderPass.AllowRendererListCulling(value);
        }

        /// <summary>
        /// Used to indicate that a pass depends on an external renderer list (that is not directly used in this pass).
        /// </summary>
        /// <param name="input">The renderer list handle this pass depends on.</param>
        /// <returns>A <see cref="RendererListHandle"/></returns>
        public RendererListHandle DependsOn(in RendererListHandle input)
        {
            m_RenderPass.UseRendererList(input);
            return input;
        }

        #endregion

        #region Internal Interface
        internal RenderGraphBuilder(RenderGraphPass renderPass, RenderGraphResourceRegistry resources, RenderGraph renderGraph)
        {
            m_RenderPass = renderPass;
            m_Resources = resources;
            m_RenderGraph = renderGraph;
            m_Disposed = false;
        }

        void Dispose(bool disposing)
        {
            if (m_Disposed)
                return;

            m_RenderGraph.OnPassAdded(m_RenderPass);
            m_Disposed = true;
        }

        void CheckResource(in ResourceHandle res, bool dontCheckTransientReadWrite = false)
        {
#if DEVELOPMENT_BUILD || UNITY_EDITOR
            if (res.IsValid())
            {
                int transientIndex = m_Resources.GetRenderGraphResourceTransientIndex(res);
                // We have dontCheckTransientReadWrite here because users may want to use UseColorBuffer/UseDepthBuffer API to benefit from render target auto binding. In this case we don't want to raise the error.
                if (transientIndex == m_RenderPass.index && !dontCheckTransientReadWrite)
                {
                    Debug.LogError($"Trying to read or write a transient resource at pass {m_RenderPass.name}.Transient resource are always assumed to be both read and written.");
                }

                if (transientIndex != -1 && transientIndex != m_RenderPass.index)
                {
                    throw new ArgumentException($"Trying to use a transient texture (pass index {transientIndex}) in a different pass (pass index {m_RenderPass.index}).");
                }
            }
            else
            {
                throw new ArgumentException($"Trying to use an invalid resource (pass {m_RenderPass.name}).");
            }
#endif
        }

        internal void GenerateDebugData(bool value)
        {
            m_RenderPass.GenerateDebugData(value);
        }

        #endregion
    }
}
