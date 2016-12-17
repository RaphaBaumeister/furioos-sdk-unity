Shader "Observ3d/Light Independent/Textured/Transparent/LI-Texture-Alpha-Bump-Reflect-Cutout-DS" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		
		_MainTex ("Diffuse (RGB)", 2D) = "white" {}
		
		_Cutoff ("Cutout Offset", Range (0, 1)) = 0.95
		
		_BumpMap ("Bump Map", 2D) = "bump" {}
		_BumpQuantity ("Bump Quantity", Range (0, 2)) = 1
		
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
		Tags { "Queue"="Transparent" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }
		
		Pass {
			ZWrite On
			Lighting Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct VertInput {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};
			
			struct FragInput {
				float4 vertex : POSITION;
				float2 uv_MainTex : TEXCOORD0;
				float4 worldPosition:TEXCOORD4;
				float3 worldNormal:TEXCOORD3;
				float2 uv_BumpMap : TEXCOORD1;
				float3 worldBinormal:TEXCOORD5;
				float3 worldTangent:TEXCOORD6;
			};
			
			fixed4 _Color;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _Cutoff;
		
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			fixed _BumpQuantity;
			
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
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPosition = mul(_Object2World,v.vertex);
				o.worldNormal = normalize( mul((float3x3)_Object2World,v.normal));
				o.uv_BumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
				float3 binormal = cross( v.normal, v.tangent.xyz ) * v.tangent.w;
				o.worldBinormal = normalize( mul((float3x3)_Object2World,binormal));
				o.worldTangent = normalize( mul((float3x3)_Object2World,v.tangent.xyz));
				return o;
			}
			
			half4 frag (FragInput IN) : COLOR{
				half4 albedo = tex2D(_MainTex, IN.uv_MainTex) * half4(_Color.rgb,1);
				clip(albedo.a-_Cutoff);
				half3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPosition.xyz);
				fixed3 bumpNormal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
				half3 worldNormal = normalize(IN.worldNormal * bumpNormal.z +
					IN.worldTangent * bumpNormal.x * _BumpQuantity +
					IN.worldBinormal * bumpNormal.y * _BumpQuantity );
				half bump = dot(IN.worldNormal,worldNormal);
				half viewDotProduct = dot(worldViewDir,worldNormal);
				half3 reflecDir =  - worldViewDir + 2.0 * ( worldNormal * viewDotProduct );
				viewDotProduct = abs(viewDotProduct);
				half reflectQty = (_Tangent_Reflect_Alpha - _Normal_Reflect_Alpha) * pow(( 1-viewDotProduct),_Fresnel_Curve) + _Normal_Reflect_Alpha;
				half3 reflectCol = (_ReflectOffset + texCUBE(_ReflectMap, reflecDir ).rgb * _ReflectColor) * _ReflectContrast;
				half reflectLum = (reflectCol.r + reflectCol.g + reflectCol.b)/12;
				half alpha = (_Color.a + reflectQty + reflectLum) * albedo.a;
				return half4((albedo.rgb * bump * (1.0-reflectQty)  + (albedo.rgb * (1-_ReflectColor) + reflectCol + 0.5) * reflectQty ) ,alpha);
			}
			
			ENDCG
		}
		Pass {
			ZWrite Off
			Lighting Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct VertInput {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};
			
			struct FragInput {
				float4 vertex : POSITION;
				float2 uv_MainTex : TEXCOORD0;
				float4 worldPosition:TEXCOORD4;
				float3 worldNormal:TEXCOORD3;
				float2 uv_BumpMap : TEXCOORD1;
				float3 worldBinormal:TEXCOORD5;
				float3 worldTangent:TEXCOORD6;
			};
			
			fixed4 _Color;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _Cutoff;
		
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			fixed _BumpQuantity;
			
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
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPosition = mul(_Object2World,v.vertex);
				o.worldNormal = normalize( mul((float3x3)_Object2World,v.normal));
				o.uv_BumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
				float3 binormal = cross( v.normal, v.tangent.xyz ) * v.tangent.w;
				o.worldBinormal = normalize( mul((float3x3)_Object2World,binormal));
				o.worldTangent = normalize( mul((float3x3)_Object2World,v.tangent.xyz));
				return o;
			}
			
			half4 frag (FragInput IN) : COLOR{
				half4 albedo = tex2D(_MainTex, IN.uv_MainTex) * half4(_Color.rgb,1);
				clip(_Cutoff-albedo.a);
				clip(albedo.a-0.004);
				half3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPosition.xyz);
				fixed3 bumpNormal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
				half3 worldNormal = normalize(IN.worldNormal * bumpNormal.z +
					IN.worldTangent * bumpNormal.x * _BumpQuantity +
					IN.worldBinormal * bumpNormal.y * _BumpQuantity );
				half bump = dot(IN.worldNormal,worldNormal);
				half viewDotProduct = dot(worldViewDir,worldNormal);
				half3 reflecDir =  - worldViewDir + 2.0 * ( worldNormal * viewDotProduct );
				viewDotProduct = abs(viewDotProduct);
				half reflectQty = (_Tangent_Reflect_Alpha - _Normal_Reflect_Alpha) * pow(( 1-viewDotProduct),_Fresnel_Curve) + _Normal_Reflect_Alpha;
				half3 reflectCol = (_ReflectOffset + texCUBE(_ReflectMap, reflecDir ).rgb * _ReflectColor) * _ReflectContrast;
				half reflectLum = (reflectCol.r + reflectCol.g + reflectCol.b)/12;
				half alpha = (_Color.a + reflectQty + reflectLum) * albedo.a;
				return half4((albedo.rgb * bump * (1.0-reflectQty)  + (albedo.rgb * (1-_ReflectColor) + reflectCol + 0.5) * reflectQty ) ,alpha);
			}
			
			ENDCG
		}
	}
		Fallback "Transparent/Cutout/VertexLit"
		CustomEditor "OBSMaterialInspector"
}
