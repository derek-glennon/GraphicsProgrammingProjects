//Remaps x from a-b to c-d
inline float Remap(float x, float a, float b, float c, float d)
{
	return (c + (x - a) * ((d - c) / (b - a)));
}

//Basic Sine Function
inline half SinWave(half x, half Amplitude, half wavelength, half speed, half time, half offset)
{
	return Amplitude * sin(wavelength * x + speed * time + offset);
}

//Basic Cosine Function
inline half CosWave(half x, half Amplitude, half wavelength, half speed, half time, half offset)
{
	return Amplitude * cos(wavelength * x + speed * time + offset);
}

//Rotates given coordinates in 3D given a rotation
half3 RotateCoordinates(half3 coords, half3 rotation)
{
	//Rotate Around X
	float theta = rotation.x;
	float c = cos(theta * (2.0 * UNITY_PI));
	float s = sin(theta * (2.0 * UNITY_PI));

	float3x3 rotationMatrix = float3x3 (float3(1, 0, 0), float3(0, c, -s), float3(0, s, c));
	coords = mul(coords, rotationMatrix);

	//Rotate Around Y
	theta = rotation.y;
	c = cos(theta * (2.0 * UNITY_PI));
	s = sin(theta * (2.0 * UNITY_PI));

	rotationMatrix = float3x3 (float3(c, 0, s), float3(0, 1, 0), float3(-s, 0, c));
	coords = mul(coords, rotationMatrix);

	//Rotate Around Z
	theta = rotation.z;
	c = cos(theta * (2.0 * UNITY_PI));
	s = sin(theta * (2.0 * UNITY_PI));

	rotationMatrix = float3x3 (float3(c, -s, 0), float3(s, c, 0), float3(0, 0, 1));
	coords = mul(coords, rotationMatrix);

	return coords;
}

#endif
