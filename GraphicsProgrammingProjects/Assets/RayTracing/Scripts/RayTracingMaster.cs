using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayTracingMaster : MonoBehaviour
{
    public ComputeShader RayTracingShader;

    public Texture SkyboxTexture;

    private RenderTexture target;

    private Camera mainCamera;

    private uint currentSample = 0;
    private Material addMaterial;

    private void Awake()
    {
        mainCamera = GetComponent<Camera>();
    }

    private void Update()
    {
        if (transform.hasChanged)
        {
            currentSample = 0;
            transform.hasChanged = false;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        SetShaderParameters();

        Render(destination);
    }

    private void Render(RenderTexture destination)
    {
        //Make sure we have a current render target
        InitRenderTexture();

        //Set the target and dispatch the compute shader
        RayTracingShader.SetTexture(0, "Result", target);
        int threadGroupsX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupsY = Mathf.CeilToInt(Screen.height / 8.0f);
        RayTracingShader.Dispatch(0, threadGroupsX, threadGroupsY, 1);

        //Blit the result texture to the screen
        if (addMaterial == null)
        {
            addMaterial = new Material(Shader.Find("Hidden/AddShader"));
        }

        addMaterial.SetFloat("_Sample", currentSample);

        Graphics.Blit(target, destination, addMaterial);

        currentSample++;
    }

    private void InitRenderTexture()
    {
        if (target == null || target.width != Screen.width || target.height != Screen.height)
        {
            //Release render texture if we already have one
            if (target != null)
            {
                target.Release();
            }

            //Reset AA samples
            currentSample = 0;

            //Get a render texture for Ray Tracing
            target = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            target.enableRandomWrite = true;
            target.Create();
        }
    }

    private void SetShaderParameters()
    {
        RayTracingShader.SetMatrix("_CameraToWorld", mainCamera.cameraToWorldMatrix);
        RayTracingShader.SetMatrix("_CameraInverseProjection", mainCamera.projectionMatrix.inverse);

        RayTracingShader.SetTexture(0, "_SkyboxTexture", SkyboxTexture);

        RayTracingShader.SetVector("_PixelOffset", new Vector2(Random.value, Random.value));
    }
}
