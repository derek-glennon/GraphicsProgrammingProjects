using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Pixelplacement;

public class SplineFollower : MonoBehaviour
{
    [SerializeField]
    private Spline spline;
    [SerializeField][Range(0,1)]    
    private float splinePercentage;

    // Update is called once per frame
    void Update()
    {
        transform.position = spline.GetPosition(splinePercentage);
    }
}
