namespace Theme.Client
{
    using UnityEngine;

    public class SetCameraDepthTextureMode : MonoBehaviour
    {
        void Awake()
        {
            GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
        }
    }
}

