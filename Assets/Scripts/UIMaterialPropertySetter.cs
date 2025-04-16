using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class Property
{
    public string name;
}

[Serializable]
public class FloatProperty : Property
{
    public float value;
}

[Serializable]
public class VectorProperty : Property
{
    public Vector4 value;
}

[Serializable]
public class ColorProperty : Property
{
    public Color value;
}

[Serializable]
public class TextureProperty : Property
{
    public Texture value;
}

[RequireComponent(typeof(Graphic), typeof(CanvasRenderer))]
public class UIMaterialPropertySetter : UIBehaviour, IMaterialModifier
{
    [SerializeField] private FloatProperty[] floatProperties;
    [SerializeField] private VectorProperty[] vectorProperties;
    [SerializeField] private ColorProperty[] colorProperties;
    [SerializeField] private TextureProperty[] textureProperties;
    
    private Graphic _graphic;
    
    private Graphic graphic => _graphic ? _graphic : _graphic = GetComponent<Graphic>();

    public Material GetModifiedMaterial(Material baseMaterial)
    {
        var newMaterial = new Material(baseMaterial);
        
        foreach (var property in floatProperties)
        {
            newMaterial.SetFloat(property.name, property.value);
        }

        foreach (var property in vectorProperties)
        {
            newMaterial.SetVector(property.name, property.value);
        }

        foreach (var property in colorProperties)
        {
            newMaterial.SetColor(property.name, property.value);
        }

        foreach (var property in textureProperties)
        {
            newMaterial.SetTexture(property.name, property.value);
        }

        return newMaterial;
    }

    private void OnValidate()
    {
        //TODO: make custom inspector
        graphic.SetMaterialDirty();
    }
}
