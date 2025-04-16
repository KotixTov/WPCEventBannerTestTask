using TMPro;
using UnityEngine;

public class DeviceInput : MonoBehaviour
{
    //Better use ServiceLocator or IoC instead
    public static DeviceInput Instance { get; private set; }

    public TMP_Text _TMPText;
    
    public Vector3 GyroscopeRotation => _gyroscopeRotation;

    private bool _hasGyroscope;
    private Gyroscope _gyroscope;
    
    private Vector3 _gyroscopeRotation;
    
    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }

        SetupGyroscope();
    }

    private void Update()
    {
        if (_hasGyroscope)
        {
            _gyroscopeRotation = _gyroscope.rotationRateUnbiased;

            _TMPText.text = _gyroscopeRotation.ToString();
        }
    }

    private void SetupGyroscope()
    {
        _hasGyroscope = SystemInfo.supportsGyroscope;
        if (_hasGyroscope)
        {
            _gyroscope = Input.gyro;
            _gyroscope.enabled = true;
        }
    }
}
