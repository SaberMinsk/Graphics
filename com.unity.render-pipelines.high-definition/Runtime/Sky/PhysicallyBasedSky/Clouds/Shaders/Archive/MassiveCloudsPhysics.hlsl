#ifndef MASSIVE_CLOUDS_PHYSICS_INCLUDED
#define MASSIVE_CLOUDS_PHYSICS_INCLUDED

struct AtmosphereFactor
{
    float scattering;
    float shadow;
    float depth;
    float shaft;
};

AtmosphereFactor UnpackAtmosphere(float4 col)
{
    AtmosphereFactor atmosphereFactor;
    atmosphereFactor.scattering = col.r;
    atmosphereFactor.shadow     = col.g;
    atmosphereFactor.depth      = col.b;
    atmosphereFactor.shaft      = col.a;
    return atmosphereFactor;
}

float4 PackAtmosphere(AtmosphereFactor atmosphereFactor)
{
    return float4(
        atmosphereFactor.scattering,
        atmosphereFactor.shadow,
        atmosphereFactor.depth,
        atmosphereFactor.shaft);
}

#endif