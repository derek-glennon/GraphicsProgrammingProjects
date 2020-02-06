//Most functions based off of the work by Inigo Quilez: https://iquilezles.org/www/articles/distfunctions/distfunctions.htm
//or Alan Zucconi 

float SDF_SMin(float a, float b, float k = 32)
{
	float res = exp(-k * a) + exp(-k * b);
	return -log(max(0.0001, res)) / k;
}

float3 SDF_Elongate(float3 pos, float3 h)
{
	float3 newPos = pos - clamp(pos, -h, h);
	return newPos;
}

float SDF_Round(float sdf_value, float rad)
{
	return sdf_value - rad;
}

float SDF_Onion(float sdf_value, float thickness)
{
	return abs(sdf_value) - thickness;
}

//sdf_2d is a SDF used on a 2D function
//TODO: Add 2D SDFs
float SDF_Extrusion(float3 pos, float sdf_2d, float h)
{
	float2 w = float2(sdf_2d, abs(pos.z) - h);
	return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}

//Must use an SDF on this retuned value
float SDF_Revolution(float3 pos, float o)
{
	float2 q = float2(length(pos.xz) - o, pos.y);
	return q;
}

//TODO: Could add change of metric functions

float SDF_Min(float d1, float d2)
{
	return min(d1, d2);
}

float SDF_Subtraction(float d1, float d2)
{
	return max(-d1, d2);
}

float SDF_Intersection(float d1, float d2)
{
	return max(d1, d2);
}

float SDF_SmoothUnion(float d1, float d2, float k)
{
	float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
	return lerp(d2, d1, h) - k * h * (1.0 - h);
}

float SDF_SmoothSubtraction(float d1, float d2, float k)
{
	float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
	return lerp(d2, -d1, h) + k * h * (1.0 - h);
}

float SDF_SmoothIntersection(float d1, float d2, float k)
{
	float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
	return lerp(d2, d1, h) + k * h * (1.0 - h);
}