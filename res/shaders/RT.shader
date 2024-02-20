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
    float focalDistance;
};

struct Material 
{
    float diffuse;
    float specular;
    float shininess;
    float ambience;
    float reflection;
};

const Material material1 = Material(0.514, 0.49, 76.8, 0.7, 1.);
const Material material2 = Material(0.4, 0.25, 124.3, 0.2, 0.1);

# define SPHERES_COUNT 2

struct Sphere
{
    
    vec3 position;
    vec3 color;
    float radius;   
    Material material;
} spheres[SPHERES_COUNT];

struct PointLight
{
    vec3 position;
    vec3 color; //Not used for now
    float intensity;
}lights[1];

const Sphere sphere1 = Sphere(
    vec3(0.1, 0., 0.),
    vec3(0.1, 0.1, 0.3),
    0.08,
    material1);

const Sphere sphere2 = Sphere(
    vec3(-0.1, -0.05, 0.),
    vec3(0.3, 0.1, 0.1),
    0.08,
    material1);
    
const Sphere sphere3 = Sphere(
    vec3(0.1, 0., 0.),
    vec3(0.1, 0.1, 0.3),
    0.08,
    material1);


const Camera camera = Camera(
    vec3(0., 0., -0.3), 
    0.6);
    
PointLight light1 = PointLight(
    vec3(0., 0.19, -0.2),
    vec3(1., 1., 1.),
    55.);
    
# define PLANES_COUNT 6
struct Plane
{
    vec3 position;
    vec3 normal;
    vec3 color;
    Material material;
} planes[PLANES_COUNT];

Plane plane1 = Plane(
    vec3(0., -0.2, 0.),
    vec3(0., 1., 0.),
    vec3(0.5, 0.5, 0.5),
    material2);
    
Plane plane2 = Plane(
    vec3(-0.3, 0., 0.),
    vec3(1., 0., 0.),
    vec3(0.2, 0.5, 0.6),
    material2);
    
Plane plane3 = Plane(
    vec3(0.3, 0., 0.),
    vec3(-1., 0., 0.),
    vec3(0.2, 0.5, 0.6),
    material2);
    
Plane plane4 = Plane(
    vec3(0., 0.3, 0.),
    vec3(0., -1., 0.),
    vec3(0.2, 0.5, 0.6),
    material2);
    
Plane plane5 = Plane(
    vec3(0., 0., 0.12),
    vec3(0., 0., -1.),
    vec3(0.2, 0.5, 0.6),
    material2);
    
Plane plane6 = Plane(
    vec3(0., 0., -1.),
    vec3(0., 0., 1.),
    vec3(0.2, 0.5, 0.6),
    material2);
    
# define SPHERE 0
# define PLANE 1

    
void setupScene()
{
    spheres[0] = sphere1;
    spheres[1] = sphere2;
    
    planes[0] = plane6;
    planes[1] = plane5;
    planes[2] = plane4;
    planes[3] = plane3;
    planes[4] = plane2;
    planes[5] = plane1;
    
    lights[0] = light1;
}

////////////////////////////////////////////////////////////
//                       UTILS                            //
////////////////////////////////////////////////////////////

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

Material getMaterial(int type, int index)
{
    if (type == SPHERE)
    {
        return spheres[index].material;
    }
    
    if (type == PLANE)
    {
        return planes[index].material;
    }
}


bool intersectSphere(
    vec3 origin, 
    vec3 direction, 
    Sphere sphere,
    out float dist,
    out vec3 surfaceNormal, 
    out vec3 pHit)
{
    vec3 L = origin - sphere.position;
    
    float a = dot(direction, direction);
    float b = 2. * dot(direction, L);
    float c = dot(L, L) - pow(sphere.radius, 2.);
    
    float t0;
    float t1;
    
    if (solveQuadratic(a, b, c, t0, t1))
    {
        if (t1 < t0)
        {
            float temp = t0;
            t0 = t1;
            t1 = temp;
        }
        
        if (t0 < 0.)
        {
            t0 = t1;
            if (t0 < 0.) return false;
        }
        
        dist = t0;
        
        pHit = origin + dist * direction;
        surfaceNormal = normalize(pHit - sphere.position);
        
        return true;
    }  
     
    return false;
}

bool intersectPlane(in Plane plane, in vec3 origin, in vec3 rayDirection, out float t, out vec3 pHit)
{

    //pHit = vec3(0.);

    //Assuming vectors are all normalized
    float denom = dot(plane.normal, rayDirection);
    if(denom < -(1e-6))
    {
        vec3 p0l0 = plane.position - origin;
        t = dot(p0l0, plane.normal) / denom;
        
        if (t >= 0.)
        {
            pHit = origin + rayDirection * t;
            return true;
        }

    }
    
    return false;
}

////////////////////////////////////////////////////////////
//                       LIGHTING                         //
////////////////////////////////////////////////////////////

vec3 getLitColor(in vec3 viewDir, in vec3 surfacePointPosition, in vec3 objectColor, in PointLight pointLight, in vec3 surfaceNormal, in Material material)
{
    vec3 lightVector = surfacePointPosition - pointLight.position;
    vec3 lightDir = normalize(lightVector);
    
    float lightIntensity = (pow(0.1, 2.) / dot(lightVector, lightVector)) * pointLight.intensity;
    
    float coeff = -dot(lightDir, surfaceNormal);
    
    vec3 ambient = material.ambience * objectColor;
    
    vec3 diffuse = material.diffuse * max(coeff, 0.) * objectColor * lightIntensity;
    
    vec3 halfwayDir = normalize(lightDir + viewDir);
    vec3 specular = pow(max(-dot(surfaceNormal, halfwayDir), 0.0), material.shininess) * material.specular * objectColor * lightIntensity;
    
    vec3 color = ambient + diffuse + specular;
    
    return color;
}


vec3 calculateShadow(vec3 pHit, in vec3 finalColor, in float ambient, int type, int index)
{
    // Intersect spheres
    vec3 shadowSurfaceNormal;
    vec3 shadowRay = lights[0].position - pHit;
    vec3 shadowRayDirection = normalize(shadowRay);
    float distanceToLight = sqrt(dot(shadowRay, shadowRay));
    vec3 shadowPhit;
    vec3 returnColor = finalColor;
    
    float dist;
     
    for(int i = 0; i < SPHERES_COUNT; ++i)
    {
        if (type == SPHERE && index == i)
        {
            continue;
        }
        
        if (intersectSphere(pHit, shadowRay, spheres[i], dist, shadowSurfaceNormal, shadowPhit))
        {
            if (dist > 0. && distanceToLight > dist)
            {
                //finalColor *= 2. * ambient; // Educated guess
                returnColor *= 2. * ambient;//
            }
        }
    }
    
    // Intersect planes
    for(int i = 0; i < PLANES_COUNT; ++i)
    {
        if (type == PLANE && index == i)
        {
            continue;
        }
        
        if (intersectPlane(planes[i], pHit, shadowRay, dist, shadowPhit))
        {
            if (dist < distanceToLight)
            {
                //finalColor *= 2. * ambient;
                returnColor *= 2. * ambient;//
            }
        }
    }
    return returnColor;
}

////////////////////////////////////////////////////////////
//                       MAIN CODE                        //
////////////////////////////////////////////////////////////

vec3 rayTrace(in vec3 rayDirection, in vec3 rayOrigin)
{
    vec3 finalColor = vec3(0.);

    int BOUNCES = 2;
    
    int prevType = -1;
    int prevIndex = -1;
    
    
    vec3 pHit = rayOrigin;
    vec3 passPHit = rayOrigin;
    int bounce = 0;
    for(; bounce < BOUNCES; bounce++)
    {
        
        float dist = 1. / (1e-9);
        float objectHitDistance = dist;
        
        int type = -1;
        int index = -1;
    
        
        vec3 surfaceNormal;
        
        vec3 passColor = vec3(0.);
        
        pHit = passPHit;
        
        
        for(int i = 0; i < 2; ++i)
        {
            if (prevType == SPHERE && prevIndex == i)
            {
                continue;
            }
            
            if (intersectSphere(rayOrigin, rayDirection, spheres[i], objectHitDistance, surfaceNormal, pHit))
            {
                
                
                if (objectHitDistance <= dist)
                {
                    dist = objectHitDistance;
                    passColor = getLitColor(rayDirection, pHit, spheres[i].color, lights[0], surfaceNormal, spheres[i].material);
                    passColor = calculateShadow(pHit, passColor, spheres[i].material.ambience, SPHERE, i);
                    
                    
                    type = SPHERE;
                    index = i;
                    passPHit = pHit;
                    break;
                    
                }
            }
        }

        for(int i = 0; i < PLANES_COUNT; ++i)
        {
            
            if (prevType == PLANE && prevIndex == i)
            {
                continue;
            }
            if (intersectPlane(planes[i], rayOrigin, rayDirection, objectHitDistance, pHit))
            {
                
                if (objectHitDistance <= dist)
                {
                    dist = objectHitDistance;
                    passColor = getLitColor(rayDirection, pHit, planes[i].color, lights[0], planes[i].normal, planes[i].material);
                    
                    surfaceNormal = planes[i].normal;
                    
                    passColor = calculateShadow(pHit, passColor, planes[i].material.ambience, PLANE, i);
                    
                    type = PLANE;
                    index = i;
                    passPHit = pHit;
                    //break;
                    
                }
            }
        }
        
        
        
        if(type < 0) break;////
        
        if (bounce == 0)
        {
            finalColor += passColor;
        }
        else
        {
            //if(length(getMaterial(type, index).specular * passColor) <= 0.1){ finalColor = vec3(0., 0., 0.); break;}
            finalColor += getMaterial(type, index).specular * passColor;
        }
        
        rayOrigin = passPHit;
      
        rayDirection = reflect(rayDirection, surfaceNormal);
        
        
        
        prevType = type;
        prevIndex = index;
        
        
    
    }
    if(bounce < BOUNCES) return vec3(0., 0., 0.);
    return finalColor / float(BOUNCES);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    setupScene();
    
    // lights[0].position.x = 0.;
    // lights[0].position.z = 0.;
    lights[0].position += u_LightPos;
    lights[0].position.z = 0.;
    spheres[0].position.z = 0.;
    
    // Normalized pixel coordinates (from -0.5 to 0.5)
    vec2 uv = fragCoord;
    // uv.x *= (iResolution.x / iResolution.y); 
    
    vec3 clipPlanePosition = vec3(uv.x, uv.y, camera.position.z + camera.focalDistance);
    vec3 rayDirection = normalize(clipPlanePosition - camera.position);
    
    vec3 finalColor = rayTrace(rayDirection, camera.position);



    // Output to screen
    fragColor = vec4(finalColor,1.0);
}

void main()
{
    vec4 textColor;
    mainImage(textColor, v_TexCoord);
    color = textColor;
}