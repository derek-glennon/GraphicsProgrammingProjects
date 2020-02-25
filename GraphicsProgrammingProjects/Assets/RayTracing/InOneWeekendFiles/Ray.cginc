class Ray
{
	float3 origin;
	float3 direction;
	float3 point_at_parameter(float t)
	{
		return origin + t * direction;
	}
};
