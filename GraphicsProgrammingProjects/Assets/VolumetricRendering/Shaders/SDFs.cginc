//Most functions based off of the work by Inigo Quilez: https://iquilezles.org/www/articles/distfunctions/distfunctions.htm
//or Alan Zucconi : 

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

float SDF_TriPrism(float3 pos, float2 h)
{
	const float k = sqrt(3.0);
	h.x *= 0.5*k;
	pos.xy /= h.x;
	pos.x = abs(pos.x) - 1.0;
	pos.y = pos.y + 1.0 / k;
	if (pos.x + k * pos.y>0.0) pos.xy = float2(pos.x - k * pos.y, -k * pos.x - pos.y) / 2.0;
	pos.x -= clamp(pos.x, -2.0, 0.0);
	float d1 = length(pos.xy)*sign(-pos.y)*h.x;
	float d2 = abs(pos.z) - h.y;
	return length(max(float2(d1, d2), 0.0)) + min(max(d1, d2), 0.);
}

float SDF_Capsule(float3 pos, float3 a, float3 b, float radius)
{
	float3 pa = pos - a, ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h) - radius;
}

float SDF_VerticalCapsule(float3 pos, float h, float radius)
{
	pos.y -= clamp(pos.y, 0.0, h);
	return length(pos) - radius;
}

float SDF_InfCylinder(float3 pos, float3 c)
{
	return length(pos.xz - c.xy) - c.z;
}

float SDF_CappedCylinder(float3 pos, float h, float radius)
{
	float2 d = abs(float2(length(pos.xz), pos.y)) - float2(h, radius);
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float SDF_RoundedCylinder(float3 pos, float ra, float rb, float h)
{
	float2 d = float2(length(pos.xz) - 2.0*ra + rb, abs(pos.y) - h);
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - rb;
}

float SDF_Cone(float3 pos, float2 c)
{
	//TODO: Can't figure out how c works. Fix that

	// c is the sin/cos of the angle
	float q = length(pos.xy);
	return dot(c, float2(q, pos.z));
}

float SDF_CappedCone(float3 pos, float h, float r1, float r2)
{
	float2 q = float2(length(pos.xz), pos.y);
	float2 k1 = float2(r2, h);
	float2 k2 = float2(r2 - r1, 2.0*h);
	float2 ca = float2(q.x - min(q.x, (q.y<0.0) ? r1 : r2), abs(q.y) - h);
	float2 cb = q - k1 + k2 * clamp(dot(k1 - q, k2) / dot(k2, k2), 0.0, 1.0);
	float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
	return s * sqrt(min(dot(ca, ca), dot(cb, cb)));
}

float SDF_SolidAngle(float3 pos, float2 c, float ra)
{
	//TODO: fix weird c issues again

	// c is the sin/cos of the angle
	float2 q = float2(length(pos.xz), pos.y);
	float l = length(q) - ra;
	float m = length(q - c * clamp(dot(q, c), 0.0, ra));
	return max(l, m*sign(c.y*q.x - c.x*q.y));
}

float SDF_RoundCone(float3 pos, float r1, float r2, float h)
{
	float2 q = float2(length(pos.xz), pos.y);

	float b = (r1 - r2) / h;
	float a = sqrt(1.0 - b * b);
	float k = dot(q, float2(-b, a));

	if (k < 0.0) return length(q) - r1;
	if (k > a*h) return length(q - float2(0.0, h)) - r2;

	return dot(q, float2(a, b)) - r1;
}

float SDF_Ellipsoid(float3 pos, float3 r)
{
	float k0 = length(pos / r);
	float k1 = length(pos / (r*r));
	return k0 * (k0 - 1.0) / k1;
}

float SDF_Torus(float3 pos, float2 t)
{
	float2 q = float2(length(pos.xz) - t.x, pos.y);
	return length(q) - t.y;
}

float SDF_CappedTorus(float3 pos, float2 sc, float ra, float rb)
{
	//TODO: Fix. Can't get to look right

	pos.x = abs(pos.x);
	float k = (sc.y*pos.x>sc.x*pos.y) ? dot(pos.xy, sc) : length(pos.xy);
	return sqrt(dot(pos, pos) + ra * ra - 2.0*ra*k) - rb;
}

float SDF_Link(float3 pos, float le, float r1, float r2)
{
	float3 q = float3(pos.x, max(abs(pos.y) - le, 0.0), pos.z);
	return length(float2(length(q.xy) - r1, q.z)) - r2;
}

float SDF_Octahedron(float3 pos, float s)
{
	pos = abs(pos);
	float m = pos.x + pos.y + pos.z - s;
	float3 q;
	if (3.0*pos.x < m) q = pos.xyz;
	else if (3.0*pos.y < m) q = pos.yzx;
	else if (3.0*pos.z < m) q = pos.zxy;
	else return m * 0.57735027;

	float k = clamp(0.5*(q.z - q.y + s), 0.0, s);
	return length(float3(q.x, q.y - s + k, q.z - k));
}

float SDF_Pyramid(float3 pos, float h)
{
	float m2 = h * h + 0.25;

	pos.xz = abs(pos.xz);
	pos.xz = (pos.z>pos.x) ? pos.zx : pos.xz;
	pos.xz -= 0.5;

	float3 q = float3(pos.z, h*pos.y - 0.5*pos.x, h*pos.x + 0.5*pos.y);

	float s = max(-q.x, 0.0);
	float t = clamp((q.y - 0.5*pos.z) / (m2 + 0.25), 0.0, 1.0);

	float a = m2 * (q.x + s)*(q.x + s) + q.y*q.y;
	float b = m2 * (q.x + 0.5*t)*(q.x + 0.5*t) + (q.y - m2 * t)*(q.y - m2 * t);

	float d2 = min(q.y, -q.x*m2 - q.y*0.5) > 0.0 ? 0.0 : min(a, b);

	return sqrt((d2 + q.z*q.z) / m2) * sign(max(q.z, -pos.y));
}

float dot2(float3 v) { return dot(v, v); }
float SDF_Triangle(float3 pos, float3 a, float3 b, float3 c)
{
	float3 ba = b - a; float3 pa = pos - a;
	float3 cb = c - b; float3 pb = pos - b;
	float3 ac = a - c; float3 pc = pos - c;
	float3 nor = cross(ba, ac);

	return sqrt(
		(sign(dot(cross(ba, nor), pa)) +
			sign(dot(cross(cb, nor), pb)) +
			sign(dot(cross(ac, nor), pc))<2.0)
		?
		min(min(
			dot2(ba*clamp(dot(ba, pa) / dot2(ba), 0.0, 1.0) - pa),
			dot2(cb*clamp(dot(cb, pb) / dot2(cb), 0.0, 1.0) - pb)),
			dot2(ac*clamp(dot(ac, pc) / dot2(ac), 0.0, 1.0) - pc))
		:
		dot(nor, pa)*dot(nor, pa) / dot2(nor));
}

float SDF_Quad(float3 pos, float3 a, float3 b, float3 c, float3 d)
{
	float3 ba = b - a; float3 pa = pos - a;
	float3 cb = c - b; float3 pb = pos - b;
	float3 dc = d - c; float3 pc = pos - c;
	float3 ad = a - d; float3 pd = pos - d;
	float3 nor = cross(ba, ad);

	return sqrt(
		(sign(dot(cross(ba, nor), pa)) +
			sign(dot(cross(cb, nor), pb)) +
			sign(dot(cross(dc, nor), pc)) +
			sign(dot(cross(ad, nor), pd))<3.0)
		?
		min(min(min(
			dot2(ba*clamp(dot(ba, pa) / dot2(ba), 0.0, 1.0) - pa),
			dot2(cb*clamp(dot(cb, pb) / dot2(cb), 0.0, 1.0) - pb)),
			dot2(dc*clamp(dot(dc, pc) / dot2(dc), 0.0, 1.0) - pc)),
			dot2(ad*clamp(dot(ad, pd) / dot2(ad), 0.0, 1.0) - pd))
		:
		dot(nor, pa)*dot(nor, pa) / dot2(nor));
}