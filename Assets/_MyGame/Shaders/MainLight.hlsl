#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"

struct ShadeData{
   float3 wp;
   float3 normal;
   float3 viewDir;
   float3 albedo;
   float specularPow;
};

void MainLight_half(float3 WorldPos, out half3 Direction, out half3 Color, out half DistanceAtten, out half ShadowAtten)
{
#if SHADERGRAPH_PREVIEW
   Direction = half3(0.5, 0.5, 0);
   Color = 1;
   DistanceAtten = 1;
   ShadowAtten = 1;
#else
   
#if SHADOWS_SCREEN
   half4 clipPos = TransformWorldToHClip(WorldPos);
   half4 shadowCoord = ComputeScreenPos(clipPos);
#else
   half4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
#endif
   
   Light mainLight = GetMainLight(shadowCoord);
   Direction = mainLight.direction;
   Color = mainLight.color;
   DistanceAtten = mainLight.distanceAttenuation;
   ShadowAtten = mainLight.shadowAttenuation;
#endif
}

float GetSpecularPow(float smoothness){
   return exp2(10 * smoothness + 1);
}
/*
float3 ApplySimpleLighting(ShadeData sd, Light light){
   float3 r = light.color * (light.distanceAttenuation * light.shadowAttenuation);

   float diffuse = saturate(dot(sd.normal, light.direction));
   float specularDot = saturate(dot(sd.normal, normalize(light.direction + sd.viewDir)));
   float specular = pow(specularDot, sd.specularPow) * diffuse;
   return sd.albedo * r * (diffuse + specular);
}
*/
void AddLights_float(float3 albedo, half smoothness, float3 wp, float3 normal, float3 viewDir, out float3 color)
{
#if SHADERGRAPH_PREVIEW
   color = float3(0,0,0);
   return;
#endif
   
   color = float3(0,0,0);

   #ifdef _ADDITIONAL_LIGHTS
   ShadeData sd;
   sd.wp = wp;
   sd.normal = normal;
   sd.viewDir = viewDir;
   sd.specularPow = GetSpecularPow(smoothness);
   sd.albedo = albedo;
   
   uint numLights = GetAdditionalLightsCount();
   for(uint i = 0; i < numLights; i++){
      Light light = GetAdditionalLight(i, wp, 1.0);

      float3 r = light.color * (light.distanceAttenuation * light.shadowAttenuation);

      float diffuse = saturate(dot(sd.normal, light.direction));
      float specularDot = saturate(dot(sd.normal, normalize(light.direction + sd.viewDir)));
      float specular = pow(specularDot, sd.specularPow) * diffuse;
      color += float3(sd.albedo * r * (specular + diffuse));
   }
   #endif
}

#endif