using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToonLightingShowController : MonoBehaviour
{
    [SerializeField]
    private float showDuration;
    [SerializeField]
    private Transform arrow;
    [SerializeField]
    private Transform pointerBW;
    [SerializeField]
    private Transform pointerStylized;
    [SerializeField]
    private Transform pointerRamp;
    [SerializeField]
    private Transform endPointBW;
    [SerializeField]
    private Transform endPointStlyized;
    [SerializeField]
    private Transform endPointRamp;

    private Vector3 startingPositionBW;
    private Vector3 startingPositionStylized;
    private Vector3 startingPositionRamp;

    private float t = 0.0f;

    float Remap(float x, float a, float b, float c, float d)
    {
        return (c + (x - a) * ((d - c) / (b - a)));
    }

    void Awake()
    {
        t = 0.0f;

        startingPositionBW = pointerBW.position;
        startingPositionStylized = pointerStylized.position;
        startingPositionRamp = pointerRamp.position;
    }

    void Update()
    {
        t = t > showDuration ? 0.0f : t + Time.deltaTime;

        float tRemap = Remap(t, 0.0f, showDuration, 0.0f, 1.0f);

        //Rotate Arrow
        Vector3 newRotation = Vector3.Lerp(new Vector3(0.0f, 180f, 0.0f), new Vector3(0.0f, (180f - 360f), 0.0f), tRemap);
        Vector3 spinAmount = newRotation - arrow.rotation.eulerAngles;
        arrow.rotation = Quaternion.Euler(arrow.rotation.eulerAngles + spinAmount);

        //Move Pointers
        pointerBW.position = Vector3.Lerp(startingPositionBW, endPointBW.position, tRemap);
        pointerStylized.position = Vector3.Lerp(startingPositionStylized, endPointStlyized.position, tRemap);
        pointerRamp.position = Vector3.Lerp(startingPositionRamp, endPointRamp.position, tRemap);

    }
}
