#shader vertex
#version 330 core

layout(location = 0) in vec4 position;
layout(location = 1) in vec2 texCoord;

out vec2 v_TexCoord;

uniform mat4 u_MVP;

void main()
{
    gl_Position = u_MVP * position;
    v_TexCoord = texCoord;
}

#shader fragment
#version 330 core

layout(location = 0) out vec4 color;

in vec2 v_TexCoord;

uniform vec4 u_Color;
uniform sampler2D u_Texture;
uniform vec3 u_LightPos;

struct Camera 
{
    vec3 position;
    vec3 direction;
    float canvasPosition; 
} camera;


struct Light
{
	vec3 direction;    
} light;

struct Material 
{
    float diffuse;
    float specular;
    float shininess;
    float ambience;
} material;

struct Sphere
{
    vec3 color;
    vec3 position;
    float radius;   
    Material material;
} sphere;

void setupScene()
{
    camera.position = vec3(0., 0., 3.5);
    camera.direction = vec3(0., 0., -1.);
    camera.canvasPosition = 2.7;
    
    
    
    light.direction = normalize(vec3(0., -1., -0.78));
    
    material.ambience = 0.2;
    material.diffuse = 0.7;
    material.specular = 0.9;
    material.shininess = 10.0;    
    
    sphere.position = vec3(0., 0., 2.2);
    sphere.radius = 0.3;
    sphere.color = vec3(0.9, 0.2, 0.3);
    sphere.material = material;
}

bool solveQuadratic(float a, float b, float c, out float t0, out float t1)
{
    float disc = b * b - 4. * a * c;
    
    if (disc < 0.)
    {
        return false;
    } 
    
    if (disc == 0.)
    {
        t0 = t1 = -b / (2. * a);
        return true;
    }
    
    t0 = (-b + sqrt(disc)) / (2. * a);
    t1 = (-b - sqrt(disc)) / (2. * a);
    return true;    
}

bool intersect(vec3 origin, vec3 direction, out vec3 surfaceNormal, out vec3 Phit)
{
    vec3 L = origin - sphere.position;
    
    float a = dot(direction, direction);
    float b = 2. * dot(direction, L);
    float c = dot(L, L) - pow(sphere.radius, 2.);
    
    float t0;
    float t1;
    
    if (solveQuadratic(a, b, c, t0, t1))
    {
        float t = t0;
        if (t1 < t0)
        {
            t = t1;
        }
        
        Phit = origin + t * direction;
        surfaceNormal = normalize(Phit - sphere.position);
        
        return true;
    }  
     
    return false;
}

int mode = 3;

vec3 getPhongColor(vec3 direction, vec3 lightDirection, vec3 surfaceNormal, vec3 objectColor)
{
    float coeff = -dot(light.direction, surfaceNormal);
    //Phong
    vec3 ambient = sphere.material.ambience * objectColor;
    vec3 diffuse = sphere.material.diffuse * max(coeff, 0.) * objectColor;

    float shininess = pow(max(-dot(direction, reflect(light.direction, surfaceNormal)), 0.), sphere.material.shininess);
    vec3 specular = sphere.material.specular * shininess * objectColor;

    return ambient + diffuse + specular;
}

vec3 getReflectedColor(vec3 direction, vec3 surfaceNormal)
{
    vec3 reflectedRay = reflect(direction, surfaceNormal);
    vec3 reflectedColor = texture(iChannel0, reflectedRay).rgb;
    return mix(sphere.color, reflectedColor, sphere.material.specular);
}

vec3 getRefractedRay(vec3 N, vec3 I)
{
    float eta1 = 1.;
    float eta2 = 1.3;
    float eta = eta1 / eta2;
    
    float c1 = dot(N, I);
    if(c1 < 0.)
    {
        c1 = -c1;
    }
    else
    {
        N = -N;
        eta = 1. / eta;
    }
    float theta = acos(c1);
    float c2 = sqrt(1. - eta * eta * sin(theta) * sin(theta));
    
    vec3 T = eta * I + (eta * c1 - c2) * N;
    return T;
}

vec3 rayTrace(vec3 direction)
{
    vec3 surfaceNormal;
    vec3 Phit;
    
    if (intersect(camera.position, direction, surfaceNormal, Phit))
    {
    
        switch(mode)
        {
            case 0: //Phong
            {
                return getPhongColor(direction, light.direction, surfaceNormal, sphere.color);
            }
            case 1: //Reflections
            {
                return getReflectedColor(direction, surfaceNormal);
            }
            case 2: //Reflections + Phong
            {
                vec3 reflectedColor = getReflectedColor(direction, surfaceNormal);
                return getPhongColor(direction, light.direction, surfaceNormal, reflectedColor);
            }
            case 3: //Refraction
            {
                vec3 refractedRay = getRefractedRay(surfaceNormal, direction);
                
                if(intersect(Phit, normalize(refractedRay), surfaceNormal, Phit))
                {
                    refractedRay = getRefractedRay(surfaceNormal, normalize(refractedRay));
                }
                
                return texture(iChannel0, normalize(refractedRay)).rgb;
            }
            
        }
            
    }
    
    return texture(iChannel0, direction).rgb;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{        
    setupScene();
    
    // Normalized pixel coordinates (from -0.5 to 0.5)
    vec2 uv = fragCoord; 
    
    vec3 direction = normalize(vec3(uv, camera.canvasPosition) - camera.position);
    
    sphere.position.y = sin(iTime * 6.) / 3.;
    
    
    light.direction.x = -(iMouse.x / iResolution.x - 0.5);
    light.direction.y = -(iMouse.y / iResolution.y - 0.5);
    light.direction = normalize(light.direction);
    
    
    //vec3 col = texture(iChannel0, direction).rgb;
    vec3 col = rayTrace(direction);

    // Output to screen
    fragColor = vec4(col, 1.0);
}
void main()
{
    vec4 textColor;
    mainImage(textColor, v_TexCoord);
    color = textColor;
}