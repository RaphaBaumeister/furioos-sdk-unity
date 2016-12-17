Shader "Observ3d/Light Independent/Color/Opaque/LI-Color-Lightmap-Reflect-DS" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		
		_LightMap ("Lightmap (RGB)", 2D) = "gray" { }
		_LightMapContrast ("LightMap Contrast", Range (0, 3)) = 1
		_LightMapOffset ("LightMap 0ffset", Range (-1, 1)) = 0
		
		_ReflectMap ("Reflect Map", Cube) = "gray" { TexGen CubeReflect }
		_ReflectColor ("Reflect Color", Color) = (1,1,1,1)
		_ReflectContrast ("Reflect Contrast", Range (0, 3)) = 1
		_ReflectOffset ("Reflect Offset", Range (-1, 0)) = -0.5
		_Normal_Reflect_Alpha ("Normal Reflect Alpha", Range (0, 1)) = 0.05
		_Fresnel_Curve ("Fresnel Curve", Range (1, 10)) = 4
		_Tangent_Reflect_Alpha ("Tangent Reflect Alpha", Range (0.01, 1)) = 0.5
		
		_AntiFlick ("AntiFlick", Range (0, 0.0001)) = 0
	}
	SubShader {
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }
		
		Pass {
			ZWrite On
			Lighting Off
			Cull Off
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct VertInput {
				float4 vertex : POSITION;
				float2 texcoord1 : TEXCOORD1;
				float3 normal : NORMAL;
			};
			
			struct FragInput {
				float4 vertex : POSITION;
				float2 uv2_LightMap : TEXCOORD2;
				float4 worldPosition:TEXCOORD4;
				float3 worldNormal:TEXCOORD3;
			};
			
			fixed3 _Color;
			
			sampler2D _LightMap;
			float4 _LightMap_ST;
			fixed _LightMapContrast;
			fixed _LightMapOffset;
			
			samplerCUBE _ReflectMap;
			fixed _Normal_Reflect_Alpha;
			fixed _Fresnel_Curve;
			fixed _Tangent_Reflect_Alpha;
			fixed _ReflectContrast;
			fixed _ReflectOffset;
			fixed3 _ReflectColor;
			
			half _AntiFlick;
			
			FragInput vert (VertInput v) {
				FragInput o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.vertex.z -= _AntiFlick*o.vertex.w;
				o.uv2_LightMap = TRANSFORM_TEX(v.texcoord1, _LightMap);
				o.worldPosition = mul(_Object2World,v.vertex);
				o.worldNormal = normalize( mul((float3x3)_Object2World,v.normal));
				return o;
			}
			
			half4 frag (FragInput IN) : COLOR{
				half3 albedo = _Color.rgb;
				half3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPosition.xyz);
				half3 worldNormal = IN.worldNormal;
				half viewDotProduct = dot(worldViewDir,worldNormal);
				half3 reflecDir =  - worldViewDir + 2.0 * ( worldNormal * viewDotProduct );
				viewDotProduct = abs(viewDotProduct);
				half reflectQty = (_Tangent_Reflect_Alpha - _Normal_Reflect_Alpha) * pow(( 1-viewDotProduct),_Fresnel_Curve) + _Normal_Reflect_Alpha;
				half3 reflectCol = (_ReflectOffset + texCUBE(_ReflectMap, reflecDir ).rgb * _ReflectColor) * _ReflectContrast;
				half4 lmc = tex2D (_LightMap, IN.uv2_LightMap);
				half3 lm = (_LightMapOffset + (lmc.rgb * (8 * lmc.a)) - 1) * _LightMapContrast + 1.0;
				return half4((albedo.rgb * (1.0-reflectQty)  + (albedo.rgb * (1-_ReflectColor) + reflectCol + 0.5) * reflectQty ) * lm,1.0);
			}
			
			ENDCG
		}
	}
		Fallback "VertexLit"
		CustomEditor "OBSMaterialInspector"
}
