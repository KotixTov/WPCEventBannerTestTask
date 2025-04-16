using UnityEngine;

public class UIParallax : MonoBehaviour
{
    [SerializeField] private float _multiplier = 100;
    
    private Vector3 _startPosition;

    private void Awake()
    {
        _startPosition = transform.position;
    }
    
    private void Update()
    {
        var gyroscopeRotation = DeviceInput.Instance.GyroscopeRotation;

        var offset = gyroscopeRotation * _multiplier;
        
        offset = new Vector3(offset.y, -offset.x, 0);
        
        transform.position += offset;
    }
}
