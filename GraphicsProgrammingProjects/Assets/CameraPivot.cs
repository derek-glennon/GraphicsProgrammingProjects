using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraPivot : MonoBehaviour
{
    [SerializeField]
    private float minAngle;
    [SerializeField]
    private float maxAngle;

    [SerializeField]
    private float speed;

    private float startingAngle;

    //Remaps x from a-b to c-d
    float Remap(float x, float a, float b, float c, float d)
    {
        return (c + (x - a) * ((d - c) / (b - a)));
    }

    // Start is called before the first frame update
    void Awake()
    {
        startingAngle = transform.rotation.eulerAngles.y;
    }

    // Update is called once per frame
    void Update()
    {
        float t = Remap(Mathf.Sin(Time.time * speed), -1f, 1f, 0f, 1f);
        float angle = Mathf.Lerp(minAngle, maxAngle, t);
        Vector3 eulerAngles = transform.rotation.eulerAngles;
        transform.rotation = Quaternion.Euler(eulerAngles.x, startingAngle + angle, eulerAngles.z);
    }
}
