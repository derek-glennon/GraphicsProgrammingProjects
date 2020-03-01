using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayTracingMaster : MonoBehaviour
{
    [SerializeField]
    private ComputeShader RayTracingShader;
    [SerializeField]
    private Texture SkyboxTexture;
    [SerializeField]
    private Light DirectionalLight;

    [Header("Spheres")]
    [Space(5)]
    [SerializeField]
    private Vector2 sphereRadius = new Vector2(3.0f, 8.0f);
    [SerializeField]
    private uint spheresMax = 100;
    [SerializeField]
    private float spherePlacementRadius = 100.0f;

    private RenderTexture target;
    private Camera mainCamera;
    private uint currentSample = 0;
    private Material addMaterial;

    //Sphere Buffer
    private ComputeBuffer sphereBuffer;


    private struct Sphere
    {
        public Vector3 position;
        public float radius;
        public Vector3 albedo;
        public Vector3 specular;
    };

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

        if (DirectionalLight.transform.hasChanged)
        {
            currentSample = 0;
            DirectionalLight.transform.hasChanged = false;
        }
    }

    private void OnEnable()
    {
        currentSample = 0;
        SetUpScene();
    }

    private void OnDisable()
    {
        if (sphereBuffer != null)
        {
            sphereBuffer.Release();
        }
    }

    private void SetUpScene()
    {
        List<Sphere> spheres = new List<Sphere>();

        //Add a number of random spheres
        for (int i = 0; i < spheresMax; i++)
        {
            Sphere sphere = new Sphere();

            //Position and Radius
            sphere.radius = sphereRadius.x + Random.value * (sphereRadius.y - sphereRadius.x);
            Vector2 randomPos = Random.insideUnitCircle * spherePlacementRadius;
            sphere.position = new Vector3(randomPos.x, sphere.radius, randomPos.y);

            //Reject spheres that are intersecting others
            foreach (Sphere other in spheres)
            {
                float minDist = sphere.radius + other.radius;

                if (Vector3.SqrMagnitude(sphere.position - other.position) < minDist * minDist)
                {
                    goto SkipSphere;
                }

            }

            //Albedo and Specular Color
            Color color = Random.ColorHSV();
            bool metal = Random.value < 0.5f;
            sphere.albedo = metal ? Vector3.zero : new Vector3(color.r, color.g, color.b);
            sphere.specular = metal ? new Vector3(color.g, color.g, color.b) : Vector3.one * 0.04f;

            //Add the sphere to the list
            spheres.Add(sphere);


            SkipSphere:
                continue;
            
        }

        //Assign to the Compute Buffer
        sphereBuffer = new ComputeBuffer(spheres.Count, 40);
        sphereBuffer.SetData(spheres);
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

        Vector3 lightDir = DirectionalLight.transform.forward;
        RayTracingShader.SetVector("_DirectionalLight", new Vector4(lightDir.x, lightDir.y, lightDir.z, DirectionalLight.intensity));

        RayTracingShader.SetBuffer(0, "_Spheres", sphereBuffer);
    }
}
