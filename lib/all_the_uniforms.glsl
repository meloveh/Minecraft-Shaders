#ifndef VOXY_TERRAIN
    uniform float viewWidth;
    uniform float viewHeight;
    uniform float aspectRatio;
    uniform int isEyeInWater;
    uniform float frameTimeCounter;
    uniform float frameTime;
    uniform int frameCounter;
    uniform vec3 fogColor;
    uniform vec3 skyColor;
    uniform vec3 cameraPosition;
    uniform vec4 entityColor;
    uniform int worldTime;
    uniform float rainStrength;
    uniform float temperature;
    uniform vec3 sunPosition;
    uniform int worldDay;
    uniform int heldBlockLightValue;
    uniform float darknessFactor;
    uniform float darknessLightFactor;
    uniform float blindness;
    uniform ivec2 eyeBrightnessSmooth;
    uniform vec3 previousCameraPosition;
    uniform int entityId;
    uniform float nightVision;
    uniform float sunAngleAtHome;
    uniform float screenBrightness;
    uniform int renderStage;
    uniform float thunderStrength;
    uniform vec4 lightningBoltPosition;
    uniform bool hideGUI;
    uniform float endFlashIntensity;
    uniform vec3 endFlashPosition;
    uniform float alphaTestRef;
    uniform int blockEntityId;
    uniform float centerDepthSmooth;
    uniform ivec2 atlasSize;
    uniform float wetness;
    uniform float sunAngle;

    uniform sampler2D colortex0;
    uniform sampler2D colortex1;
    uniform sampler2D colortex2;
    uniform sampler2D colortex3;
    uniform sampler2D colortex5;
    uniform sampler3D colortex6;
    #ifdef VOXY
    uniform sampler2D colortex16;
    #endif
    uniform sampler2D gaux1;
    uniform sampler2D depthtex0;
    uniform sampler2D depthtex1;
    uniform sampler2D noisetex;
    uniform sampler2DShadow shadowtex0;
    uniform sampler2D shadowcolor0;
    uniform sampler2D normals;
    uniform sampler2D specular;
    uniform sampler2D gtexture;

    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferProjection;
    uniform mat4 gbufferModelView;
    uniform mat4 gbufferModelViewInverse;
    uniform mat4 gbufferPreviousModelView;
    uniform mat4 gbufferPreviousProjection;
    uniform mat4 shadowModelView;
    uniform mat4 shadowModelViewInverse;
    uniform mat4 shadowProjection;
    uniform mat4 shadowProjectionInverse;

    uniform float near;
    uniform float far;

    uniform float timeAngle;
    uniform float nightStrength;
    uniform float dayStrength;
    uniform float sunsetStrength;
    uniform float sunriseStrength;
    uniform vec2 resolution;
    uniform vec2 resolutionInv;
    uniform vec3 sunOrMoonPosN;
    uniform vec3 sunPosN;
    uniform vec2 taaJitter;
    uniform float isOutdoorsSmooth;
    uniform float precipitationSmooth;
    uniform float fogAmount;
    uniform float rainbowStrength;

    uniform sampler2D vxDepthTexTrans;
    uniform sampler2D vxDepthTexOpaque;
    uniform mat4 vxProjInv;
    uniform mat4 vxProj;
    uniform mat4 vxProjPrev;
    uniform mat4 vxModelView;
    uniform mat4 vxModelViewInv;
    uniform mat4 vxModelViewPrev;
    uniform int vxRenderDistance;
#endif

#ifdef VOXY
    #define DISTANT_HORIZONS

    #define dhDepthTex0 vxDepthTexTrans
    #define dhDepthTex1 vxDepthTexOpaque

    #define dhProjectionInverse vxProjInv
    #define dhProjection vxProj
    #define dhPreviousProjection vxProjPrev
    
    #define dhRenderDistance (vxRenderDistance * 16)
#else
    uniform sampler2D dhDepthTex0;
    uniform sampler2D dhDepthTex1;

    uniform mat4 dhProjectionInverse;
    uniform mat4 dhProjection;
    uniform mat4 dhPreviousProjection;

    uniform int dhRenderDistance;
#endif

#if (defined DIMENSION_OVERWORLD) || (!defined CUSTOM_SKYBOXES)
const bool colortex0Clear = false;
#endif
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool gaux1Clear = false;
const bool colortex5Clear = false;
const bool shadowcolor0Clear = false;

const int noiseTextureResolution = 256;

const vec4 colortex0ClearColor = vec4(0, 0, 0, 1);
const vec4 colortex1ClearColor = vec4(0,0,0,1);

const float PI = 3.1415926535897;
const float TAU = 2 * PI;
const float gr = 1.6180339887498;

const float shadowDistanceRenderMul = 1.0;
const bool shadowHardwareFiltering = true;

/*
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = R11F_G11F_B10F;
const int colortex2Format = RGBA8;
const int gaux1Format = R11F_G11F_B10F;
const int shadowcolor0Format = R8;
const int colortex5Format = RG16; 
*/