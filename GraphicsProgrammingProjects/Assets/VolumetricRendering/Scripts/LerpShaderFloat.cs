using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LerpShaderFloat : MonoBehaviour
{
    [SerializeField]
    private Material material;
    [SerializeField]
    private string shaderVariableName;

    [SerializeField]
    private float lowerValue;
    [SerializeField]
    private float upperValue;

    [SerializeField]
    private float speed;

    //Remaps x from a-b to c-d
    float Remap(float x, float a, float b, float c, float d)
    {
        return (c + (x - a) * ((d - c) / (b - a)));
    }

    // Start is called before the first frame update
    void Awake()
    {

    }

    // Update is called once per frame
    void Update()
    {
        float t = Remap(Mathf.Sin(Time.time * speed), -1f, 1f, 0f, 1f);
        float shaderFloat = Mathf.Lerp(lowerValue, upperValue, t);
        material.SetFloat(shaderVariableName, shaderFloat);
    }
}
