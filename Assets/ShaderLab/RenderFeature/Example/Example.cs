using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class Example : ScriptableRendererFeature
{
    private static string rt_name = "_ExampleRT";
    static int rt_ID = Shader.PropertyToID(rt_name);
    private static string blitShader_Name = "";
    
    class CustomRenderPass : ScriptableRenderPass
    {
       
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            RenderTextureDescriptor descriptor = new RenderTextureDescriptor(
                renderingData.cameraData.cameraTargetDescriptor.width, 
                renderingData.cameraData.cameraTargetDescriptor.height, 
                RenderTextureFormat.Default, 0);
            cmd.GetTemporaryRT(rt_ID,descriptor);
            
            ConfigureTarget(rt_ID);
            
            ConfigureClear(ClearFlag.Color, Color.black);
            
        }
        

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("tmpCmd");
            cmd.Blit(renderingData.cameraData.renderer.cameraColorTarget, rt_ID);
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            cmd.Release();
            //CommandBufferPool.Release(cmd);
            
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(rt_ID);
        }
    }

    CustomRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();

        // Configures where the render pass should be injected.
        //m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


