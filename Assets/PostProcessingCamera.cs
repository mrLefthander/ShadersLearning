using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessingCamera : MonoBehaviour
{
  public Material PostProcessingMaterial;

  private void OnRenderImage(RenderTexture source, RenderTexture destination)
  {
    Graphics.Blit(source, destination, PostProcessingMaterial);
  }
}
