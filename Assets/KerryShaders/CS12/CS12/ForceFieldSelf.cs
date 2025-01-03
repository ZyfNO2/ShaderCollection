using UnityEngine;



[ExecuteInEditMode()]
public class ForceFieldSelf : MonoBehaviour
{
    public ParticleSystem ps;
    public string triggerTag = "ForceField";
    public float clicksPerSecond = 0.1f;
    public int AffectorAmount = 20;

    private float clickTimer = 0.0f;
    private ParticleSystem.Particle[] particles;
    private Vector4[] positions;
    private float[] sizes;
    
    void DoRayCast()
    {
        RaycastHit hitInfo;
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if (Physics.Raycast(ray,out hitInfo, 1000))
        {
            if (hitInfo.transform.CompareTag(triggerTag))
            {
                ps.transform.position = hitInfo.point;
                ps.Emit(1);
            }
        } 
    }
    void Update()
    {
        clickTimer += Time.deltaTime;
        if (Input.GetMouseButton(0))
        {
            if (clickTimer > clicksPerSecond)
            {
                clickTimer = 0.0f;
                DoRayCast();
            }
        }
        
        // Shader.SetGlobalVector("HitPosition",transform.position);
        // Shader.SetGlobalFloat("HitSize",transform.lossyScale.x);
        var psmain = ps.main;
        psmain.maxParticles = AffectorAmount;
        particles = new ParticleSystem.Particle[AffectorAmount];
        positions = new Vector4[AffectorAmount];
        sizes = new float[AffectorAmount];
        ps.GetParticles(particles);
        for (int i = 0; i < AffectorAmount; i++)
        {
        positions[i] = particles[i].position;
        sizes[i] = particles[i].GetCurrentSize(ps);
        }
        Shader.SetGlobalVectorArray("HitPosition", positions);
        Shader.SetGlobalFloatArray("HitSize", sizes);
        Shader.SetGlobalFloat("AffectorAmount", AffectorAmount);
        
    }
}
