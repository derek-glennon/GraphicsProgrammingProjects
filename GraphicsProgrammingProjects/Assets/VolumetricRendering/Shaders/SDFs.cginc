//Most functions based off of the work by Alan Zucconi : 
//Or Inigo Quilez: https://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float SDF_Sphere(float3 pos, float3 center, float radius)
{
	return distance(pos, center) - radius;
}

float SDF_Box(float3 pos, float3 center, float3 size)
{
	float x = max
	(
		pos.x - center.x - float3(size.x / 2.0, 0, 0),
		center.x - pos.x - float3(size.x / 2.0, 0, 0)
	);

	float y = max
	(
		pos.y - center.y - float3(size.y / 2.0, 0, 0),
		center.y - pos.y - float3(size.y / 2.0, 0, 0)
	);

	float z = max
	(
		pos.z - center.z - float3(size.z / 2.0, 0, 0),
		center.z - pos.z - float3(size.z / 2.0, 0, 0)
	);

	float d = x;
	d = max(d, y);
	d = max(d, z);
	return d;
}

float vmax(float3 v)
{
	return max(max(v.x, v.y), v.z);
}

float SDF_BoxCheap(float3 pos, float3 center, float3 size)
{
	return vmax(abs(pos - center) - size);
}

float SDF_RoundBox(float3 pos, float3 center, float3 size, float radius)
{
	float3 q = abs(pos - center) - size;
	return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - radius;
}

float SDF_Plane(float3 pos, float4 normal)
{
	//TODO: Fix this
	//Needs normal to create but normal estimation needs SDF??

	//normal must be normalized
	return dot(pos, normal.xyz) + normal.w;
}

float SDF_HexPrism(float3 pos, float2 h)
{
	float3 k = float3(-0.8660254, 0.5, 0.57735);
	pos = abs(pos);
	pos.xy -= 2.0 * min(dot(k.xy, pos.xy), 0.0) * k.xy;
	float2 d = float2(
		length(pos.xy - float2(clamp(pos.x, -k.z * h.x, k.z * h.x), h.x)) * sign(pos.y - h.x),
		pos.z - h.y);
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}