using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
 //[PostProcess(typeof(StylizedTonemapFinalRenderer), PostProcessEvent.AfterStack, "Get Started With Shaders/Stylized Tonemap Final")]
 [PostProcess(typeof(StylizedTonemapFinalRenderer), PostProcessEvent.AfterStack, "GSST")]
public sealed class StylizedTonemapFinal : PostProcessEffectSettings
{
    [Range(-2f, 2f)]
    public FloatParameter exposure = new FloatParameter { value = 0.0f };
    [Range(0f, 2f)]
    public FloatParameter saturation = new FloatParameter { value = 1.0f };
    [Range(0f, 2f)]
    public FloatParameter contrast = new FloatParameter { value = 1.0f };
}

public sealed class StylizedTonemapFinalRenderer : PostProcessEffectRenderer<StylizedTonemapFinal>
{
    public override void Render(PostProcessRenderContext context)
    {
        //Hidden 不会出现在面板上
        //var sheet = context.propertySheets.Get(Shader.Find("Hidden/Get Started With Shaders/4. Stylized Tonemap Final"));
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/GSST/PostProcessing"));
        sheet.properties.SetFloat("_Exposure", settings.exposure);
        sheet.properties.SetFloat("_Saturation", settings.saturation);
        sheet.properties.SetFloat("_Contrast", settings.contrast);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
