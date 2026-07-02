#include "pch-cpp.hpp"





template <typename R, typename T1, typename T2>
struct VirtualFuncInvoker2Invoker;
template <typename R, typename T1, typename T2>
struct VirtualFuncInvoker2Invoker<R, T1*, T2*>
{
	static inline R Invoke (Il2CppMethodSlot slot, RuntimeObject* obj, T1* p1, T2* p2)
	{
		const VirtualInvokeData& invokeData = il2cpp_codegen_get_virtual_invoke_data(slot, obj);
		R ret;
		void* params[2] = { p1, p2 };
		invokeData.method->invoker_method(il2cpp_codegen_get_method_pointer(invokeData.method), invokeData.method, obj, params, &ret);
		return ret;
	}
};
template <typename R, typename T1>
struct ConstrainedFuncInvoker1;
template <typename R, typename T1>
struct ConstrainedFuncInvoker1<R, T1*>
{
	static inline R Invoke (RuntimeClass* type, const RuntimeMethod* constrainedMethod, void* boxBuffer, void* obj, T1* p1)
	{
		R ret;
		void* params[1] = { p1 };
		il2cpp_codegen_runtime_constrained_call(type, constrainedMethod, boxBuffer, obj, params, &ret);
		return ret;
	}
};

struct Comparer_1_t535E02B3998AA8B49230077EF0DFCB16BA44C985;
struct Comparer_1_tF59A960F33DD69C2CF0330F3FF6AD7828FF0F3FB;
struct EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9;
struct EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC;
struct ITypeConstructor_1_t38B0D0EFBEAA57884DFAE0A863E841E681DE2224;
struct ByteU5BU5D_tA6237BF417AE52AD70CFB4EF24A7A82613DF9031;
struct CharU5BU5D_t799905CF001DD5F13F7DBB310181FC4D8B7D0AAB;
struct TypeU5BU5D_t97234E1129B564EB38B8D85CAC2AD8B5B9522FFB;
struct UInt32U5BU5D_t02FBD658AD156A17574ECE6106CF1FBFCC9807FA;
struct Binder_t91BFCE95A7057FADF4D8A1A342AFE52872246235;
struct Byte_t94D9231AC217BE4D2E004C4CD32DF6D099EA41A3;
struct MemberFilter_tF644F1AE82F611B677CE1964D5A3277DDA21D553;
struct String_t;
struct Type_t;
struct UnsafeStreamBlock_t0DE96C782B2CBF67BE34978C364781E170B3A86C;
struct Void_t4861ACF8F4594C3437BB48B6E56783494B843915;
struct ITypeConstructor_tAEA6BC4B87F0F3739E4457F21908EF55F666EB08;
struct TypeConstructorVisitor_tFC61250F68BF43FE889F5B1002CBFF90648E9C7F;

IL2CPP_EXTERN_C Il2CppSequencePoint g_sequencePointsUnityEngine_CoreModule[];
IL2CPP_EXTERN_C Il2CppSequencePoint g_sequencePointsUnityEngine_PropertiesModule[];
IL2CPP_EXTERN_C Il2CppSequencePoint g_sequencePointsUnity_Burst[];
IL2CPP_EXTERN_C Il2CppSequencePoint g_sequencePointsUnity_Collections[];
IL2CPP_EXTERN_C RuntimeClass* Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* TypeUtility_t62F146E51B66BB18FA0E1EFA84A564FF2B8AAD03_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C const RuntimeMethod* Reader_ReadNext_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m008862EE68B89223188A3A1C95A528DC5CD56774_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeType* ByteU2A_t7A03686A8034AF92EF1EA2D09B280EF590D1174D_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* StrBoolArray_tCA66E1F688A4BC6FA749195F867F59E523508DD6_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* TypeCode_tBEF9BE86C8BCF5A6B82F3381219738D27804EF79_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* TypeConstructorVisitor_tFC61250F68BF43FE889F5B1002CBFF90648E9C7F_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* VoidU2A_t104EAEFBD2D237A8C29618913DA9B4D99355E965_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F_0_0_0_var;
IL2CPP_EXTERN_C const RuntimeType* v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61_0_0_0_var;


IL2CPP_EXTERN_C_BEGIN
IL2CPP_EXTERN_C_END

#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
struct Comparer_1_t535E02B3998AA8B49230077EF0DFCB16BA44C985  : public RuntimeObject
{
};
struct EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9  : public RuntimeObject
{
};
struct EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC  : public RuntimeObject
{
};
struct MemberInfo_t  : public RuntimeObject
{
};
struct String_t  : public RuntimeObject
{
	int32_t ____stringLength;
	Il2CppChar ____firstChar;
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F  : public RuntimeObject
{
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F_marshaled_pinvoke
{
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F_marshaled_com
{
};
struct PrimitivesConverters_t4AC0AF040C8B4B0C9C0C9A0A6F806521CFD84F27  : public RuntimeObject
{
};
struct TypeConstructorVisitor_tFC61250F68BF43FE889F5B1002CBFF90648E9C7F  : public RuntimeObject
{
	RuntimeObject* ___TypeConstructor;
};
struct Avx2_tEF5390382630DE33677921890832DA46CE372FBC  : public RuntimeObject
{
};
struct Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C  : public RuntimeObject
{
};
struct Boolean_t09A6377A54BE2F9E6985A8149F19234FD7DDFE22 
{
	bool ___m_value;
};
struct Byte_t94D9231AC217BE4D2E004C4CD32DF6D099EA41A3 
{
	uint8_t ___m_value;
};
struct Char_t521A6F19B456D956AF452D926C32709DC03D6B17 
{
	Il2CppChar ___m_value;
};
struct Double_tE150EF3D1D43DEE85D533810AB4C742307EEDE5F 
{
	double ___m_value;
};
struct Enum_t2A1A94B24E3B776EEF4E5E485E290BB9D4D072E2  : public ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F
{
};
struct Enum_t2A1A94B24E3B776EEF4E5E485E290BB9D4D072E2_marshaled_pinvoke
{
};
struct Enum_t2A1A94B24E3B776EEF4E5E485E290BB9D4D072E2_marshaled_com
{
};
struct Int16_tB8EF286A9C33492FA6E6D6E67320BE93E794A175 
{
	int16_t ___m_value;
};
struct Int32_t680FF22E76F6EFAD4375103CBBFFA0421349384C 
{
	int32_t ___m_value;
};
struct Int64_t092CFB123BE63C28ACDAF65C68F21A526050DBA3 
{
	int64_t ___m_value;
};
struct IntPtr_t 
{
	void* ___m_value;
};
struct SByte_tFEFFEF5D2FEBF5207950AE6FAC150FC53B668DB5 
{
	int8_t ___m_value;
};
struct Single_t4530F2FF86FCB0DC29F35385CA1BD21BE294761C 
{
	float ___m_value;
};
struct UInt16_tF4C148C876015C212FD72652D0B6ED8CC247A455 
{
	uint16_t ___m_value;
};
struct UInt32_t1833D51FFA667B18A5AA4B8D34DE284F8495D29B 
{
	uint32_t ___m_value;
};
struct UInt64_t8F12534CC8FC4B5860F2A2CD1EE79D322E7A41AF 
{
	uint64_t ___m_value;
};
struct UIntPtr_t 
{
	void* ____pointer;
};
struct Void_t4861ACF8F4594C3437BB48B6E56783494B843915 
{
	union
	{
		struct
		{
		};
		uint8_t Void_t4861ACF8F4594C3437BB48B6E56783494B843915__padding[1];
	};
};
struct v64_t9C4037532D386FF1E9B95E5FBD01FEF472AC1F96 
{
	union
	{
		#pragma pack(push, tp, 1)
		struct
		{
			uint8_t ___Byte0;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint8_t ___Byte0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte1_OffsetPadding[1];
			uint8_t ___Byte1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte1_OffsetPadding_forAlignmentOnly[1];
			uint8_t ___Byte1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte2_OffsetPadding[2];
			uint8_t ___Byte2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte2_OffsetPadding_forAlignmentOnly[2];
			uint8_t ___Byte2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte3_OffsetPadding[3];
			uint8_t ___Byte3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte3_OffsetPadding_forAlignmentOnly[3];
			uint8_t ___Byte3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte4_OffsetPadding[4];
			uint8_t ___Byte4;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte4_OffsetPadding_forAlignmentOnly[4];
			uint8_t ___Byte4_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte5_OffsetPadding[5];
			uint8_t ___Byte5;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte5_OffsetPadding_forAlignmentOnly[5];
			uint8_t ___Byte5_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte6_OffsetPadding[6];
			uint8_t ___Byte6;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte6_OffsetPadding_forAlignmentOnly[6];
			uint8_t ___Byte6_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte7_OffsetPadding[7];
			uint8_t ___Byte7;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte7_OffsetPadding_forAlignmentOnly[7];
			uint8_t ___Byte7_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			int8_t ___SByte0;
		};
		#pragma pack(pop, tp)
		struct
		{
			int8_t ___SByte0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte1_OffsetPadding[1];
			int8_t ___SByte1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte1_OffsetPadding_forAlignmentOnly[1];
			int8_t ___SByte1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte2_OffsetPadding[2];
			int8_t ___SByte2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte2_OffsetPadding_forAlignmentOnly[2];
			int8_t ___SByte2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte3_OffsetPadding[3];
			int8_t ___SByte3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte3_OffsetPadding_forAlignmentOnly[3];
			int8_t ___SByte3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte4_OffsetPadding[4];
			int8_t ___SByte4;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte4_OffsetPadding_forAlignmentOnly[4];
			int8_t ___SByte4_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte5_OffsetPadding[5];
			int8_t ___SByte5;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte5_OffsetPadding_forAlignmentOnly[5];
			int8_t ___SByte5_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte6_OffsetPadding[6];
			int8_t ___SByte6;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte6_OffsetPadding_forAlignmentOnly[6];
			int8_t ___SByte6_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte7_OffsetPadding[7];
			int8_t ___SByte7;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte7_OffsetPadding_forAlignmentOnly[7];
			int8_t ___SByte7_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			uint16_t ___UShort0;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint16_t ___UShort0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort1_OffsetPadding[2];
			uint16_t ___UShort1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort1_OffsetPadding_forAlignmentOnly[2];
			uint16_t ___UShort1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort2_OffsetPadding[4];
			uint16_t ___UShort2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort2_OffsetPadding_forAlignmentOnly[4];
			uint16_t ___UShort2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort3_OffsetPadding[6];
			uint16_t ___UShort3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort3_OffsetPadding_forAlignmentOnly[6];
			uint16_t ___UShort3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			int16_t ___SShort0;
		};
		#pragma pack(pop, tp)
		struct
		{
			int16_t ___SShort0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort1_OffsetPadding[2];
			int16_t ___SShort1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort1_OffsetPadding_forAlignmentOnly[2];
			int16_t ___SShort1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort2_OffsetPadding[4];
			int16_t ___SShort2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort2_OffsetPadding_forAlignmentOnly[4];
			int16_t ___SShort2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort3_OffsetPadding[6];
			int16_t ___SShort3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort3_OffsetPadding_forAlignmentOnly[6];
			int16_t ___SShort3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			uint32_t ___UInt0;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint32_t ___UInt0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UInt1_OffsetPadding[4];
			uint32_t ___UInt1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UInt1_OffsetPadding_forAlignmentOnly[4];
			uint32_t ___UInt1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			int32_t ___SInt0;
		};
		#pragma pack(pop, tp)
		struct
		{
			int32_t ___SInt0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SInt1_OffsetPadding[4];
			int32_t ___SInt1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SInt1_OffsetPadding_forAlignmentOnly[4];
			int32_t ___SInt1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			uint64_t ___ULong0;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint64_t ___ULong0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			int64_t ___SLong0;
		};
		#pragma pack(pop, tp)
		struct
		{
			int64_t ___SLong0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			float ___Float0;
		};
		#pragma pack(pop, tp)
		struct
		{
			float ___Float0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Float1_OffsetPadding[4];
			float ___Float1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Float1_OffsetPadding_forAlignmentOnly[4];
			float ___Float1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			double ___Double0;
		};
		#pragma pack(pop, tp)
		struct
		{
			double ___Double0_forAlignmentOnly;
		};
	};
};
struct AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 
{
	uint16_t ___Index;
	uint16_t ___Version;
};
struct Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6 
{
	uint8_t* ___Ptr;
	int32_t ___Size;
	int32_t ___Offset;
};
struct U3CDataU3Ee__FixedBuffer_t60155FEDF2B8430C4B466CB3CDD85327C03F1116 
{
	union
	{
		struct
		{
			uint8_t ___FixedElementField;
		};
		uint8_t U3CDataU3Ee__FixedBuffer_t60155FEDF2B8430C4B466CB3CDD85327C03F1116__padding[1];
	};
};
struct Array_t3B8F006A80A48C83471DE3516556F1AFE6873381 
{
	union
	{
		struct
		{
		};
		uint8_t Array_t3B8F006A80A48C83471DE3516556F1AFE6873381__padding[1];
	};
};
struct StreamingStateData_tB4ECCAB2ECCD0555A32604F161D9B80D9FA42B3A 
{
	union
	{
		#pragma pack(push, tp, 1)
		struct
		{
			uint64_t ___Acc;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint64_t ___Acc_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Buffer_OffsetPadding[64];
			uint8_t ___Buffer;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Buffer_OffsetPadding_forAlignmentOnly[64];
			uint8_t ___Buffer_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___IsHash64_OffsetPadding[320];
			int32_t ___IsHash64;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___IsHash64_OffsetPadding_forAlignmentOnly[320];
			int32_t ___IsHash64_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___BufferedSize_OffsetPadding[324];
			int32_t ___BufferedSize;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___BufferedSize_OffsetPadding_forAlignmentOnly[324];
			int32_t ___BufferedSize_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___NbStripesSoFar_OffsetPadding[328];
			int32_t ___NbStripesSoFar;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___NbStripesSoFar_OffsetPadding_forAlignmentOnly[328];
			int32_t ___NbStripesSoFar_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___TotalLength_OffsetPadding[336];
			int64_t ___TotalLength;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___TotalLength_OffsetPadding_forAlignmentOnly[336];
			int64_t ___TotalLength_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Seed_OffsetPadding[344];
			uint64_t ___Seed;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Seed_OffsetPadding_forAlignmentOnly[344];
			uint64_t ___Seed_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SecretKey_OffsetPadding[352];
			uint8_t ___SecretKey;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SecretKey_OffsetPadding_forAlignmentOnly[352];
			uint8_t ___SecretKey_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ____PadEnd_OffsetPadding[540];
			uint8_t ____PadEnd;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ____PadEnd_OffsetPadding_forAlignmentOnly[540];
			uint8_t ____PadEnd_forAlignmentOnly;
		};
	};
};
struct U3CBitsU3Ee__FixedBuffer_tFED81968B5AEB075B5560B55A16A31C5F01A83BD 
{
	union
	{
		struct
		{
			uint16_t ___FixedElementField;
		};
		uint8_t U3CBitsU3Ee__FixedBuffer_tFED81968B5AEB075B5560B55A16A31C5F01A83BD__padding[32];
	};
};
struct Allocator_t996642592271AAD9EE688F142741D512C07B5824 
{
	int32_t ___value__;
};
struct NativeArrayOptions_t3E979EEF4B4840228A7692A97DA07553C6465F1D 
{
	int32_t ___value__;
};
struct RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B 
{
	intptr_t ___value;
};
struct TypeCode_tBEF9BE86C8BCF5A6B82F3381219738D27804EF79 
{
	int32_t ___value__;
};
struct UnsafeStreamBlock_t0DE96C782B2CBF67BE34978C364781E170B3A86C 
{
	UnsafeStreamBlock_t0DE96C782B2CBF67BE34978C364781E170B3A86C* ___Next;
	U3CDataU3Ee__FixedBuffer_t60155FEDF2B8430C4B466CB3CDD85327C03F1116 ___Data;
};
struct v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 
{
	union
	{
		#pragma pack(push, tp, 1)
		struct
		{
			uint8_t ___Byte0;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint8_t ___Byte0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte1_OffsetPadding[1];
			uint8_t ___Byte1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte1_OffsetPadding_forAlignmentOnly[1];
			uint8_t ___Byte1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte2_OffsetPadding[2];
			uint8_t ___Byte2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte2_OffsetPadding_forAlignmentOnly[2];
			uint8_t ___Byte2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte3_OffsetPadding[3];
			uint8_t ___Byte3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte3_OffsetPadding_forAlignmentOnly[3];
			uint8_t ___Byte3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte4_OffsetPadding[4];
			uint8_t ___Byte4;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte4_OffsetPadding_forAlignmentOnly[4];
			uint8_t ___Byte4_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte5_OffsetPadding[5];
			uint8_t ___Byte5;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte5_OffsetPadding_forAlignmentOnly[5];
			uint8_t ___Byte5_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte6_OffsetPadding[6];
			uint8_t ___Byte6;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte6_OffsetPadding_forAlignmentOnly[6];
			uint8_t ___Byte6_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte7_OffsetPadding[7];
			uint8_t ___Byte7;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte7_OffsetPadding_forAlignmentOnly[7];
			uint8_t ___Byte7_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte8_OffsetPadding[8];
			uint8_t ___Byte8;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte8_OffsetPadding_forAlignmentOnly[8];
			uint8_t ___Byte8_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte9_OffsetPadding[9];
			uint8_t ___Byte9;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte9_OffsetPadding_forAlignmentOnly[9];
			uint8_t ___Byte9_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte10_OffsetPadding[10];
			uint8_t ___Byte10;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte10_OffsetPadding_forAlignmentOnly[10];
			uint8_t ___Byte10_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte11_OffsetPadding[11];
			uint8_t ___Byte11;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte11_OffsetPadding_forAlignmentOnly[11];
			uint8_t ___Byte11_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte12_OffsetPadding[12];
			uint8_t ___Byte12;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte12_OffsetPadding_forAlignmentOnly[12];
			uint8_t ___Byte12_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte13_OffsetPadding[13];
			uint8_t ___Byte13;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte13_OffsetPadding_forAlignmentOnly[13];
			uint8_t ___Byte13_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte14_OffsetPadding[14];
			uint8_t ___Byte14;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte14_OffsetPadding_forAlignmentOnly[14];
			uint8_t ___Byte14_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Byte15_OffsetPadding[15];
			uint8_t ___Byte15;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Byte15_OffsetPadding_forAlignmentOnly[15];
			uint8_t ___Byte15_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			int8_t ___SByte0;
		};
		#pragma pack(pop, tp)
		struct
		{
			int8_t ___SByte0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte1_OffsetPadding[1];
			int8_t ___SByte1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte1_OffsetPadding_forAlignmentOnly[1];
			int8_t ___SByte1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte2_OffsetPadding[2];
			int8_t ___SByte2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte2_OffsetPadding_forAlignmentOnly[2];
			int8_t ___SByte2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte3_OffsetPadding[3];
			int8_t ___SByte3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte3_OffsetPadding_forAlignmentOnly[3];
			int8_t ___SByte3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte4_OffsetPadding[4];
			int8_t ___SByte4;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte4_OffsetPadding_forAlignmentOnly[4];
			int8_t ___SByte4_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte5_OffsetPadding[5];
			int8_t ___SByte5;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte5_OffsetPadding_forAlignmentOnly[5];
			int8_t ___SByte5_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte6_OffsetPadding[6];
			int8_t ___SByte6;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte6_OffsetPadding_forAlignmentOnly[6];
			int8_t ___SByte6_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte7_OffsetPadding[7];
			int8_t ___SByte7;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte7_OffsetPadding_forAlignmentOnly[7];
			int8_t ___SByte7_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte8_OffsetPadding[8];
			int8_t ___SByte8;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte8_OffsetPadding_forAlignmentOnly[8];
			int8_t ___SByte8_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte9_OffsetPadding[9];
			int8_t ___SByte9;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte9_OffsetPadding_forAlignmentOnly[9];
			int8_t ___SByte9_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte10_OffsetPadding[10];
			int8_t ___SByte10;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte10_OffsetPadding_forAlignmentOnly[10];
			int8_t ___SByte10_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte11_OffsetPadding[11];
			int8_t ___SByte11;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte11_OffsetPadding_forAlignmentOnly[11];
			int8_t ___SByte11_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte12_OffsetPadding[12];
			int8_t ___SByte12;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte12_OffsetPadding_forAlignmentOnly[12];
			int8_t ___SByte12_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte13_OffsetPadding[13];
			int8_t ___SByte13;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte13_OffsetPadding_forAlignmentOnly[13];
			int8_t ___SByte13_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte14_OffsetPadding[14];
			int8_t ___SByte14;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte14_OffsetPadding_forAlignmentOnly[14];
			int8_t ___SByte14_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SByte15_OffsetPadding[15];
			int8_t ___SByte15;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SByte15_OffsetPadding_forAlignmentOnly[15];
			int8_t ___SByte15_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			uint16_t ___UShort0;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint16_t ___UShort0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort1_OffsetPadding[2];
			uint16_t ___UShort1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort1_OffsetPadding_forAlignmentOnly[2];
			uint16_t ___UShort1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort2_OffsetPadding[4];
			uint16_t ___UShort2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort2_OffsetPadding_forAlignmentOnly[4];
			uint16_t ___UShort2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort3_OffsetPadding[6];
			uint16_t ___UShort3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort3_OffsetPadding_forAlignmentOnly[6];
			uint16_t ___UShort3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort4_OffsetPadding[8];
			uint16_t ___UShort4;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort4_OffsetPadding_forAlignmentOnly[8];
			uint16_t ___UShort4_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort5_OffsetPadding[10];
			uint16_t ___UShort5;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort5_OffsetPadding_forAlignmentOnly[10];
			uint16_t ___UShort5_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort6_OffsetPadding[12];
			uint16_t ___UShort6;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort6_OffsetPadding_forAlignmentOnly[12];
			uint16_t ___UShort6_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UShort7_OffsetPadding[14];
			uint16_t ___UShort7;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UShort7_OffsetPadding_forAlignmentOnly[14];
			uint16_t ___UShort7_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			int16_t ___SShort0;
		};
		#pragma pack(pop, tp)
		struct
		{
			int16_t ___SShort0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort1_OffsetPadding[2];
			int16_t ___SShort1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort1_OffsetPadding_forAlignmentOnly[2];
			int16_t ___SShort1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort2_OffsetPadding[4];
			int16_t ___SShort2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort2_OffsetPadding_forAlignmentOnly[4];
			int16_t ___SShort2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort3_OffsetPadding[6];
			int16_t ___SShort3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort3_OffsetPadding_forAlignmentOnly[6];
			int16_t ___SShort3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort4_OffsetPadding[8];
			int16_t ___SShort4;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort4_OffsetPadding_forAlignmentOnly[8];
			int16_t ___SShort4_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort5_OffsetPadding[10];
			int16_t ___SShort5;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort5_OffsetPadding_forAlignmentOnly[10];
			int16_t ___SShort5_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort6_OffsetPadding[12];
			int16_t ___SShort6;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort6_OffsetPadding_forAlignmentOnly[12];
			int16_t ___SShort6_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SShort7_OffsetPadding[14];
			int16_t ___SShort7;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SShort7_OffsetPadding_forAlignmentOnly[14];
			int16_t ___SShort7_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			uint32_t ___UInt0;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint32_t ___UInt0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UInt1_OffsetPadding[4];
			uint32_t ___UInt1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UInt1_OffsetPadding_forAlignmentOnly[4];
			uint32_t ___UInt1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UInt2_OffsetPadding[8];
			uint32_t ___UInt2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UInt2_OffsetPadding_forAlignmentOnly[8];
			uint32_t ___UInt2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___UInt3_OffsetPadding[12];
			uint32_t ___UInt3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___UInt3_OffsetPadding_forAlignmentOnly[12];
			uint32_t ___UInt3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			int32_t ___SInt0;
		};
		#pragma pack(pop, tp)
		struct
		{
			int32_t ___SInt0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SInt1_OffsetPadding[4];
			int32_t ___SInt1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SInt1_OffsetPadding_forAlignmentOnly[4];
			int32_t ___SInt1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SInt2_OffsetPadding[8];
			int32_t ___SInt2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SInt2_OffsetPadding_forAlignmentOnly[8];
			int32_t ___SInt2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SInt3_OffsetPadding[12];
			int32_t ___SInt3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SInt3_OffsetPadding_forAlignmentOnly[12];
			int32_t ___SInt3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			uint64_t ___ULong0;
		};
		#pragma pack(pop, tp)
		struct
		{
			uint64_t ___ULong0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___ULong1_OffsetPadding[8];
			uint64_t ___ULong1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___ULong1_OffsetPadding_forAlignmentOnly[8];
			uint64_t ___ULong1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			int64_t ___SLong0;
		};
		#pragma pack(pop, tp)
		struct
		{
			int64_t ___SLong0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___SLong1_OffsetPadding[8];
			int64_t ___SLong1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___SLong1_OffsetPadding_forAlignmentOnly[8];
			int64_t ___SLong1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			float ___Float0;
		};
		#pragma pack(pop, tp)
		struct
		{
			float ___Float0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Float1_OffsetPadding[4];
			float ___Float1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Float1_OffsetPadding_forAlignmentOnly[4];
			float ___Float1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Float2_OffsetPadding[8];
			float ___Float2;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Float2_OffsetPadding_forAlignmentOnly[8];
			float ___Float2_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Float3_OffsetPadding[12];
			float ___Float3;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Float3_OffsetPadding_forAlignmentOnly[12];
			float ___Float3_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			double ___Double0;
		};
		#pragma pack(pop, tp)
		struct
		{
			double ___Double0_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Double1_OffsetPadding[8];
			double ___Double1;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Double1_OffsetPadding_forAlignmentOnly[8];
			double ___Double1_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			v64_t9C4037532D386FF1E9B95E5FBD01FEF472AC1F96 ___Lo64;
		};
		#pragma pack(pop, tp)
		struct
		{
			v64_t9C4037532D386FF1E9B95E5FBD01FEF472AC1F96 ___Lo64_forAlignmentOnly;
		};
		#pragma pack(push, tp, 1)
		struct
		{
			char ___Hi64_OffsetPadding[8];
			v64_t9C4037532D386FF1E9B95E5FBD01FEF472AC1F96 ___Hi64;
		};
		#pragma pack(pop, tp)
		struct
		{
			char ___Hi64_OffsetPadding_forAlignmentOnly[8];
			v64_t9C4037532D386FF1E9B95E5FBD01FEF472AC1F96 ___Hi64_forAlignmentOnly;
		};
	};
};
struct Range_tB5BAD1274CA0989FC97B0093B4149EF3CD5F21AC 
{
	intptr_t ___Pointer;
	int32_t ___Items;
	AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___Allocator;
};
struct StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020 
{
	StreamingStateData_tB4ECCAB2ECCD0555A32604F161D9B80D9FA42B3A ___State;
};
struct StrBoolArray_tCA66E1F688A4BC6FA749195F867F59E523508DD6 
{
	U3CBitsU3Ee__FixedBuffer_tFED81968B5AEB075B5560B55A16A31C5F01A83BD ___Bits;
};
struct NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 
{
	void* ___m_Buffer;
	int32_t ___m_Length;
	int32_t ___m_AllocatorLabel;
};
struct Type_t  : public MemberInfo_t
{
	RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B ____impl;
};
struct Block_tCCF620817FE305B5BF7B0FB7705B4571F976C4E3 
{
	Range_tB5BAD1274CA0989FC97B0093B4149EF3CD5F21AC ___Range;
	int32_t ___BytesPerItem;
	int32_t ___AllocatedItems;
	uint8_t ___Log2Alignment;
	uint8_t ___Padding0;
	uint16_t ___Padding1;
	uint32_t ___Padding2;
};
struct Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458 
{
	Block_tCCF620817FE305B5BF7B0FB7705B4571F976C4E3 ___m_BlockData;
	UnsafeStreamBlock_t0DE96C782B2CBF67BE34978C364781E170B3A86C* ___m_CurrentBlock;
	uint8_t* ___m_CurrentPtr;
	uint8_t* ___m_CurrentBlockEnd;
	int32_t ___m_RemainingItemCount;
	int32_t ___m_LastBlockSize;
};
struct Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F 
{
	Block_tCCF620817FE305B5BF7B0FB7705B4571F976C4E3 ___m_BlockData;
	UnsafeStreamBlock_t0DE96C782B2CBF67BE34978C364781E170B3A86C* ___m_CurrentBlock;
	uint8_t* ___m_CurrentPtr;
	uint8_t* ___m_CurrentBlockEnd;
	int32_t ___m_ForeachIndex;
	int32_t ___m_ElementCount;
	UnsafeStreamBlock_t0DE96C782B2CBF67BE34978C364781E170B3A86C* ___m_FirstBlock;
	int32_t ___m_FirstOffset;
	int32_t ___m_NumberOfBlocks;
	int32_t ___m_ThreadIndex;
};
struct Comparer_1_t535E02B3998AA8B49230077EF0DFCB16BA44C985_StaticFields
{
	Comparer_1_t535E02B3998AA8B49230077EF0DFCB16BA44C985* ___defaultComparer;
};
struct EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9_StaticFields
{
	EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9* ___defaultComparer;
};
struct EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC_StaticFields
{
	EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* ___defaultComparer;
};
struct String_t_StaticFields
{
	String_t* ___Empty;
};
struct Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_StaticFields
{
	UInt32U5BU5D_t02FBD658AD156A17574ECE6106CF1FBFCC9807FA* ___crctab;
};
struct Boolean_t09A6377A54BE2F9E6985A8149F19234FD7DDFE22_StaticFields
{
	String_t* ___TrueString;
	String_t* ___FalseString;
};
struct Char_t521A6F19B456D956AF452D926C32709DC03D6B17_StaticFields
{
	ByteU5BU5D_tA6237BF417AE52AD70CFB4EF24A7A82613DF9031* ___s_categoryForLatin1;
};
struct UIntPtr_t_StaticFields
{
	uintptr_t ___Zero;
};
struct StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020_StaticFields
{
	int32_t ___SECRET_LIMIT;
	int32_t ___NB_STRIPES_PER_BLOCK;
	int32_t ___INTERNAL_BUFFER_SIZE;
	int32_t ___INTERNAL_BUFFER_STRIPES;
};
struct Type_t_StaticFields
{
	Binder_t91BFCE95A7057FADF4D8A1A342AFE52872246235* ___s_defaultBinder;
	Il2CppChar ___Delimiter;
	TypeU5BU5D_t97234E1129B564EB38B8D85CAC2AD8B5B9522FFB* ___EmptyTypes;
	RuntimeObject* ___Missing;
	MemberFilter_tF644F1AE82F611B677CE1964D5A3277DDA21D553* ___FilterAttribute;
	MemberFilter_tF644F1AE82F611B677CE1964D5A3277DDA21D553* ___FilterName;
	MemberFilter_tF644F1AE82F611B677CE1964D5A3277DDA21D553* ___FilterNameIgnoreCase;
};
#ifdef __clang__
#pragma clang diagnostic pop
#endif


IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR Il2CppFullySharedGenericAny* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m856D276A33760D3F9B6FDC631F337372BC41037E_gshared (bool* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mFD12A694611E03895F4458912B9FE341B07D690C_gshared (uint8_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m691506CA4682A3878264EEB52FA188912614F238_gshared (Il2CppChar* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mCC237A07CD7A39540520FE43C66A49204AD02060_gshared (double* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m262B2BBB933FB2B1DBDA65D418FD3A0EA166B4AF_gshared (int16_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m0E14C5AEDCB7F8A75EEE6D4D476E00E0DD7A5531_gshared (int32_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m3BFB7BDCFA2447B375F048512E95569635B8D4E4_gshared (int64_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m1967E1AEC5A0D9648CA206B187F6DA76F7865322_gshared (int8_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m6F7761D5CA3434775F5725B70793B2676B5BB50A_gshared (float* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mB352A8132547464344E6835AF40F1C7DA0FC6179_gshared (String_t** ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m6A1DA3430E328697B3C1E053374FAEACF0C77F95_gshared (uint16_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m62DAACE3E3F12517F13F380BE744A38D69E12156_gshared (uint32_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m855CA8553E43D1238E78F509DF06C0671DB8A242_gshared (uint64_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* TypeUtility_CreateTypeConstructor_TisIl2CppFullySharedGenericAny_mA5F70CB8E7370027F0A598FE0123F8A050704304_gshared (const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR int32_t UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_gshared_inline (const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t UnsafeUtility_AlignOf_TisIl2CppFullySharedGenericStruct_m11D1023B182BE19CF0F1A57DBE826004A1B81A41_gshared (const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void UnsafeUtility_ReadArrayElement_TisIl2CppFullySharedGenericAny_m295186AA082411C57485F8BDB824E4D8AC1C6D93_gshared_inline (void* ___0_source, int32_t ___1_index, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m4BEED82D6907F7A1B30916AD15A551B4477AB2C2_gshared (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void UnsafeUtility_CopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mBE6568C7ECF69CD1E86FDFF4E25D6CB529F76BF3_gshared_inline (void* ___0_ptr, Il2CppFullySharedGenericStruct* ___1_output, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_mD61521649968D72362C4D143C6798CF697284C59_gshared (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, Il2CppFullySharedGenericStruct* ___0_value, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 CollectionHelper_CreateNativeArray_TisIl2CppFullySharedGenericStruct_m4005EA9C29BA1075D9F591B6CBD82B5D22255763_gshared (int32_t ___0_length, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___1_allocator, int32_t ___2_options, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void* NativeArrayUnsafeUtility_GetUnsafePtr_TisIl2CppFullySharedGenericStruct_m4AB802D5B1B296D0F976C1E7631699B0C4A4D00F_gshared_inline (NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 ___0_nativeArray, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m08EA2C685C92045455508A2CEA28AF34C49BF372_gshared (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18* ___0_value, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___1_allocator, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void* Reader_ReadNextArray_TisIl2CppFullySharedGenericStruct_mE1C3BA7C6F410106344DD729D6EBF3FB62CB67CC_gshared (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, int32_t* ___0_length, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* UnsafeUtility_AsRef_TisIl2CppFullySharedGenericStruct_m78B0690121A96EFFDA7D6D3ADAF97940CF8136BE_gshared_inline (void* ___0_ptr, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Reader_Peek_TisIl2CppFullySharedGenericStruct_m9282B5560EB03FCC4C6F0F8AC634AE5A13B555D6_gshared (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Reader_Read_TisIl2CppFullySharedGenericStruct_mBBF673BF9BED0383144F187B6541B532F2B6A633_gshared (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Writer_Allocate_TisIl2CppFullySharedGenericStruct_m4503233E7BE788F93FD1C91B7BE65AC121483DB7_gshared (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Writer_Write_TisIl2CppFullySharedGenericStruct_m3255C6DE3AD541593524A784715AE50082831917_gshared (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* __this, Il2CppFullySharedGenericStruct ___0_value, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* EqualityComparer_1_get_Default_mA09C502B9197D9DD4E25A431E2C4BC5468631270_gshared_inline (const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Comparer_1_tF59A960F33DD69C2CF0330F3FF6AD7828FF0F3FB* Comparer_1_get_Default_m923F24BE1E2E8B01D8F2F9D26B8C0ED4B7CBA290_gshared (const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Sse4_2_ComputeStrCmpIntRes2_TisIl2CppFullySharedGenericStruct_m5BBC7FD25430C93A4DCF34A210DE56367BA1E204_gshared (Il2CppFullySharedGenericStruct* ___0_a, int32_t ___1_alen, Il2CppFullySharedGenericStruct* ___2_b, int32_t ___3_blen, int32_t ___4_len, int32_t ___5_imm8, int32_t ___6_allOnes, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 Sse4_2_ComputeStrmOutput_TisIl2CppFullySharedGenericStruct_m64ADE71FB4B90FEC60799387186E249935DE041C_gshared (int32_t ___0_len, int32_t ___1_imm8, Il2CppFullySharedGenericStruct ___2_allOnesT, int32_t ___3_intRes2, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Sse4_2_ComputeStringLength_TisIl2CppFullySharedGenericStruct_m764CDB4D47CB1C77EAA40D60D44F53C4E97CD8D6_gshared (Il2CppFullySharedGenericStruct* ___0_ptr, int32_t ___1_max, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void* UnsafeUtilityExtensions_AddressOf_TisIl2CppFullySharedGenericStruct_m9A8A98C3D874841DE9AB55CBCFD69D17C27A0E2A_gshared_inline (Il2CppFullySharedGenericStruct* ___0_value, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void StreamingState_Update_TisIl2CppFullySharedGenericStruct_m301FBB6A80BBA46BB5AC2B0DF206CAB72593DE1D_gshared (StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020* __this, Il2CppFullySharedGenericStruct* ___0_input, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Array_Resize_TisIl2CppFullySharedGenericStruct_m07039200651D43DBB7FBC0CB244761DA34C164FD_gshared (Il2CppFullySharedGenericStruct* ___0_oldPointer, int64_t ___1_oldCount, int64_t ___2_newCount, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___3_allocator, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnsafeUtility_InternalCopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mD132267FDFD79997EE2A47470E89CE83AC7CA91E_gshared (void* ___0_ptr, Il2CppFullySharedGenericStruct* ___1_output, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* EqualityComparer_1_CreateComparer_mF50863260964D9553ECFD6B8D81059A734FCB781_gshared (const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void* ILSupport_AddressOf_TisIl2CppFullySharedGenericStruct_m373C1FEADC4248F808294AA8958583E51840E129_gshared_inline (Il2CppFullySharedGenericStruct* ___0_thing, const RuntimeMethod* method) ;

IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Type_t* Type_GetTypeFromHandle_m6062B81682F79A4D6DF2640692EE6D9987858C57 (RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B ___0_handle, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool Type_get_IsPrimitive_m46ACAAB8F754D37713E3E45437705F4F58FAFA18 (Type_t* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool Type_op_Inequality_m83209C7BB3C05DFBEA3B6199B0BEFE8037301172 (Type_t* ___0_left, Type_t* ___1_right, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Type_GetTypeCode_m2CE476933AF4B381D7A52F4343B70E9878FDF466 (Type_t* ___0_type, const RuntimeMethod* method) ;
inline bool* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisBoolean_t09A6377A54BE2F9E6985A8149F19234FD7DDFE22_m442ECCC3108A0DA30933490DE73A749856262150_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  bool* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m856D276A33760D3F9B6FDC631F337372BC41037E (bool* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (bool*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m856D276A33760D3F9B6FDC631F337372BC41037E_gshared)(___0_source, il2cppRetVal, method);
}
inline uint8_t* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisByte_t94D9231AC217BE4D2E004C4CD32DF6D099EA41A3_mAAB228FFADB76FA6BB6686BBDB9479779E20A7C6_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  uint8_t* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mFD12A694611E03895F4458912B9FE341B07D690C (uint8_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (uint8_t*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mFD12A694611E03895F4458912B9FE341B07D690C_gshared)(___0_source, il2cppRetVal, method);
}
inline Il2CppChar* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisChar_t521A6F19B456D956AF452D926C32709DC03D6B17_mE5405089F0731E1FEDDBDC485048456549B8F81A_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  Il2CppChar* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m691506CA4682A3878264EEB52FA188912614F238 (Il2CppChar* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (Il2CppChar*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m691506CA4682A3878264EEB52FA188912614F238_gshared)(___0_source, il2cppRetVal, method);
}
inline double* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisDouble_tE150EF3D1D43DEE85D533810AB4C742307EEDE5F_mEBB444EE29C3C196347A1EE7E44C9F299B396D5E_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  double* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mCC237A07CD7A39540520FE43C66A49204AD02060 (double* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (double*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mCC237A07CD7A39540520FE43C66A49204AD02060_gshared)(___0_source, il2cppRetVal, method);
}
inline int16_t* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisInt16_tB8EF286A9C33492FA6E6D6E67320BE93E794A175_mF7F3D38918DD7AAB2206B1C5D2F95935F1A78141_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  int16_t* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m262B2BBB933FB2B1DBDA65D418FD3A0EA166B4AF (int16_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (int16_t*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m262B2BBB933FB2B1DBDA65D418FD3A0EA166B4AF_gshared)(___0_source, il2cppRetVal, method);
}
inline int32_t* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m5E4D05CB0C699ABEB044C09A5C38EA0E714D013B_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  int32_t* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m0E14C5AEDCB7F8A75EEE6D4D476E00E0DD7A5531 (int32_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (int32_t*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m0E14C5AEDCB7F8A75EEE6D4D476E00E0DD7A5531_gshared)(___0_source, il2cppRetVal, method);
}
inline int64_t* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisInt64_t092CFB123BE63C28ACDAF65C68F21A526050DBA3_mDE435009462C7C302356109B64DAD634148B4099_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  int64_t* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m3BFB7BDCFA2447B375F048512E95569635B8D4E4 (int64_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (int64_t*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m3BFB7BDCFA2447B375F048512E95569635B8D4E4_gshared)(___0_source, il2cppRetVal, method);
}
inline int8_t* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisSByte_tFEFFEF5D2FEBF5207950AE6FAC150FC53B668DB5_m4310668E52FB7067987D6E9321559DDF3A2FA60A_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  int8_t* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m1967E1AEC5A0D9648CA206B187F6DA76F7865322 (int8_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (int8_t*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m1967E1AEC5A0D9648CA206B187F6DA76F7865322_gshared)(___0_source, il2cppRetVal, method);
}
inline float* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisSingle_t4530F2FF86FCB0DC29F35385CA1BD21BE294761C_m9E826A3FF880E1787077B6E79CA0C8C363A54997_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  float* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m6F7761D5CA3434775F5725B70793B2676B5BB50A (float* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (float*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m6F7761D5CA3434775F5725B70793B2676B5BB50A_gshared)(___0_source, il2cppRetVal, method);
}
inline String_t** UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisString_t_m9BC71B961562D33981F3D2A518280ACCCC720714_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  String_t** (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mB352A8132547464344E6835AF40F1C7DA0FC6179 (String_t** ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (String_t**, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mB352A8132547464344E6835AF40F1C7DA0FC6179_gshared)(___0_source, il2cppRetVal, method);
}
inline uint16_t* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisUInt16_tF4C148C876015C212FD72652D0B6ED8CC247A455_m33A571A8A920313DC399CF856BA643AEFFEE4840_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  uint16_t* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m6A1DA3430E328697B3C1E053374FAEACF0C77F95 (uint16_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (uint16_t*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m6A1DA3430E328697B3C1E053374FAEACF0C77F95_gshared)(___0_source, il2cppRetVal, method);
}
inline uint32_t* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisUInt32_t1833D51FFA667B18A5AA4B8D34DE284F8495D29B_mB8FE2798F42657FD77E43F73BE64B9A2ECAD370A_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  uint32_t* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m62DAACE3E3F12517F13F380BE744A38D69E12156 (uint32_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (uint32_t*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m62DAACE3E3F12517F13F380BE744A38D69E12156_gshared)(___0_source, il2cppRetVal, method);
}
inline uint64_t* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisUInt64_t8F12534CC8FC4B5860F2A2CD1EE79D322E7A41AF_m0D05B6202B7FECB3D9612396E65FA72BCBD2671A_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method)
{
	return ((  uint64_t* (*) (Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline)(___0_from, method);
}
inline void PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m855CA8553E43D1238E78F509DF06C0671DB8A242 (uint64_t* ___0_source, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (uint64_t*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m855CA8553E43D1238E78F509DF06C0671DB8A242_gshared)(___0_source, il2cppRetVal, method);
}
inline RuntimeObject* TypeUtility_CreateTypeConstructor_TisIl2CppFullySharedGenericAny_mA5F70CB8E7370027F0A598FE0123F8A050704304 (const RuntimeMethod* method)
{
	return ((  RuntimeObject* (*) (const RuntimeMethod*))TypeUtility_CreateTypeConstructor_TisIl2CppFullySharedGenericAny_mA5F70CB8E7370027F0A598FE0123F8A050704304_gshared)(method);
}
inline int32_t UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline (const RuntimeMethod* method)
{
	return ((  int32_t (*) (const RuntimeMethod*))UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_gshared_inline)(method);
}
inline int32_t UnsafeUtility_AlignOf_TisIl2CppFullySharedGenericStruct_m11D1023B182BE19CF0F1A57DBE826004A1B81A41 (const RuntimeMethod* method)
{
	return ((  int32_t (*) (const RuntimeMethod*))UnsafeUtility_AlignOf_TisIl2CppFullySharedGenericStruct_m11D1023B182BE19CF0F1A57DBE826004A1B81A41_gshared)(method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool CollectionHelper_IsAligned_m4761669B9084B892256349C0FF27DBF494DA9AE9 (uint64_t ___0_offset, int32_t ___1_alignmentPowerOfTwo, const RuntimeMethod* method) ;
inline void UnsafeUtility_ReadArrayElement_TisIl2CppFullySharedGenericStruct_m45AD40013DEE9AEF8031E0DA6F4D23BFD5AA8F42_inline (void* ___0_source, int32_t ___1_index, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (void*, int32_t, Il2CppFullySharedGenericAny*, const RuntimeMethod*))UnsafeUtility_ReadArrayElement_TisIl2CppFullySharedGenericAny_m295186AA082411C57485F8BDB824E4D8AC1C6D93_gshared_inline)(___0_source, ___1_index, il2cppRetVal, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnsafeUtility_MemCpy_m5CEA91ACDADC522E584AE3A2AB2B0B74393A9177 (void* ___0_destination, void* ___1_source, int64_t ___2_size, const RuntimeMethod* method) ;
inline void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m4BEED82D6907F7A1B30916AD15A551B4477AB2C2 (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m4BEED82D6907F7A1B30916AD15A551B4477AB2C2_gshared)((Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*)__this, il2cppRetVal, method);
}
inline void UnsafeUtility_CopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mBE6568C7ECF69CD1E86FDFF4E25D6CB529F76BF3_inline (void* ___0_ptr, Il2CppFullySharedGenericStruct* ___1_output, const RuntimeMethod* method)
{
	((  void (*) (void*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))UnsafeUtility_CopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mBE6568C7ECF69CD1E86FDFF4E25D6CB529F76BF3_gshared_inline)(___0_ptr, ___1_output, method);
}
inline void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_mD61521649968D72362C4D143C6798CF697284C59 (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, Il2CppFullySharedGenericStruct* ___0_value, const RuntimeMethod* method)
{
	((  void (*) (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))Reader_ReadNext_TisIl2CppFullySharedGenericStruct_mD61521649968D72362C4D143C6798CF697284C59_gshared)(__this, ___0_value, method);
}
inline int32_t Reader_ReadNext_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m008862EE68B89223188A3A1C95A528DC5CD56774 (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, const RuntimeMethod* method)
{
	int32_t il2cppRetVal;
	((  void (*) (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m4BEED82D6907F7A1B30916AD15A551B4477AB2C2_gshared)((Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*)__this, (Il2CppFullySharedGenericStruct*)&il2cppRetVal, method);
	return il2cppRetVal;
}
inline NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 CollectionHelper_CreateNativeArray_TisIl2CppFullySharedGenericStruct_m4005EA9C29BA1075D9F591B6CBD82B5D22255763 (int32_t ___0_length, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___1_allocator, int32_t ___2_options, const RuntimeMethod* method)
{
	return ((  NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 (*) (int32_t, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148, int32_t, const RuntimeMethod*))CollectionHelper_CreateNativeArray_TisIl2CppFullySharedGenericStruct_m4005EA9C29BA1075D9F591B6CBD82B5D22255763_gshared)(___0_length, ___1_allocator, ___2_options, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void* Reader_ReadNext_m7C9150A60E622C8581A3E80C8DD1AD71D043BF6A (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, int32_t ___0_structSize, const RuntimeMethod* method) ;
inline void* NativeArrayUnsafeUtility_GetUnsafePtr_TisIl2CppFullySharedGenericStruct_m4AB802D5B1B296D0F976C1E7631699B0C4A4D00F_inline (NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 ___0_nativeArray, const RuntimeMethod* method)
{
	return ((  void* (*) (NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18, const RuntimeMethod*))NativeArrayUnsafeUtility_GetUnsafePtr_TisIl2CppFullySharedGenericStruct_m4AB802D5B1B296D0F976C1E7631699B0C4A4D00F_gshared_inline)(___0_nativeArray, method);
}
inline void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m08EA2C685C92045455508A2CEA28AF34C49BF372 (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18* ___0_value, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___1_allocator, const RuntimeMethod* method)
{
	((  void (*) (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*, NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18*, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148, const RuntimeMethod*))Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m08EA2C685C92045455508A2CEA28AF34C49BF372_gshared)(__this, ___0_value, ___1_allocator, method);
}
inline void* Reader_ReadNextArray_TisIl2CppFullySharedGenericStruct_mE1C3BA7C6F410106344DD729D6EBF3FB62CB67CC (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, int32_t* ___0_length, const RuntimeMethod* method)
{
	return ((  void* (*) (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*, int32_t*, const RuntimeMethod*))Reader_ReadNextArray_TisIl2CppFullySharedGenericStruct_mE1C3BA7C6F410106344DD729D6EBF3FB62CB67CC_gshared)(__this, ___0_length, method);
}
inline Il2CppFullySharedGenericStruct* UnsafeUtility_AsRef_TisIl2CppFullySharedGenericStruct_m78B0690121A96EFFDA7D6D3ADAF97940CF8136BE_inline (void* ___0_ptr, const RuntimeMethod* method)
{
	return ((  Il2CppFullySharedGenericStruct* (*) (void*, const RuntimeMethod*))UnsafeUtility_AsRef_TisIl2CppFullySharedGenericStruct_m78B0690121A96EFFDA7D6D3ADAF97940CF8136BE_gshared_inline)(___0_ptr, method);
}
inline Il2CppFullySharedGenericStruct* Reader_Peek_TisIl2CppFullySharedGenericStruct_m9282B5560EB03FCC4C6F0F8AC634AE5A13B555D6 (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* __this, const RuntimeMethod* method)
{
	return ((  Il2CppFullySharedGenericStruct* (*) (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458*, const RuntimeMethod*))Reader_Peek_TisIl2CppFullySharedGenericStruct_m9282B5560EB03FCC4C6F0F8AC634AE5A13B555D6_gshared)(__this, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR uint8_t* Reader_ReadUnsafePtr_m6CDEF727114990BC4C2DF321BE752F229104A888 (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* __this, int32_t ___0_size, const RuntimeMethod* method) ;
inline Il2CppFullySharedGenericStruct* Reader_Read_TisIl2CppFullySharedGenericStruct_mBBF673BF9BED0383144F187B6541B532F2B6A633 (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* __this, const RuntimeMethod* method)
{
	return ((  Il2CppFullySharedGenericStruct* (*) (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458*, const RuntimeMethod*))Reader_Read_TisIl2CppFullySharedGenericStruct_mBBF673BF9BED0383144F187B6541B532F2B6A633_gshared)(__this, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR uint8_t* Writer_Allocate_m85F9D4FF8746C0A59DC23A9003398A6D9D42526D (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* __this, int32_t ___0_size, const RuntimeMethod* method) ;
inline Il2CppFullySharedGenericStruct* Writer_Allocate_TisIl2CppFullySharedGenericStruct_m4503233E7BE788F93FD1C91B7BE65AC121483DB7 (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* __this, const RuntimeMethod* method)
{
	return ((  Il2CppFullySharedGenericStruct* (*) (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F*, const RuntimeMethod*))Writer_Allocate_TisIl2CppFullySharedGenericStruct_m4503233E7BE788F93FD1C91B7BE65AC121483DB7_gshared)(__this, method);
}
inline void Writer_Write_TisIl2CppFullySharedGenericStruct_m3255C6DE3AD541593524A784715AE50082831917 (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* __this, Il2CppFullySharedGenericStruct ___0_value, const RuntimeMethod* method)
{
	((  void (*) (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F*, Il2CppFullySharedGenericStruct, const RuntimeMethod*))Writer_Write_TisIl2CppFullySharedGenericStruct_m3255C6DE3AD541593524A784715AE50082831917_gshared)((Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F*)__this, ___0_value, method);
}
inline EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9* EqualityComparer_1_get_Default_m20747610B059ED2853BC1F878FC39851A47F5F2D_inline (const RuntimeMethod* method)
{
	return ((  EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9* (*) (const RuntimeMethod*))EqualityComparer_1_get_Default_mA09C502B9197D9DD4E25A431E2C4BC5468631270_gshared_inline)(method);
}
inline Comparer_1_t535E02B3998AA8B49230077EF0DFCB16BA44C985* Comparer_1_get_Default_m9BA7A3EA0D33B540EFC408B0C9C2B69F7A0C9E76 (const RuntimeMethod* method)
{
	return ((  Comparer_1_t535E02B3998AA8B49230077EF0DFCB16BA44C985* (*) (const RuntimeMethod*))Comparer_1_get_Default_m923F24BE1E2E8B01D8F2F9D26B8C0ED4B7CBA290_gshared)(method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void StrBoolArray_SetBit_m212C6D1A8A4C422AF979D6B3BC7CD5B9BD0F3F01 (StrBoolArray_tCA66E1F688A4BC6FA749195F867F59E523508DD6* __this, int32_t ___0_aindex, int32_t ___1_bindex, bool ___2_val, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool StrBoolArray_GetBit_mCA50A9F3A3FA5C552305C9B762264A6058F33E78 (StrBoolArray_tCA66E1F688A4BC6FA749195F867F59E523508DD6* __this, int32_t ___0_aindex, int32_t ___1_bindex, const RuntimeMethod* method) ;
inline int32_t Sse4_2_ComputeStrCmpIntRes2_TisIl2CppFullySharedGenericStruct_m5BBC7FD25430C93A4DCF34A210DE56367BA1E204 (Il2CppFullySharedGenericStruct* ___0_a, int32_t ___1_alen, Il2CppFullySharedGenericStruct* ___2_b, int32_t ___3_blen, int32_t ___4_len, int32_t ___5_imm8, int32_t ___6_allOnes, const RuntimeMethod* method)
{
	return ((  int32_t (*) (Il2CppFullySharedGenericStruct*, int32_t, Il2CppFullySharedGenericStruct*, int32_t, int32_t, int32_t, int32_t, const RuntimeMethod*))Sse4_2_ComputeStrCmpIntRes2_TisIl2CppFullySharedGenericStruct_m5BBC7FD25430C93A4DCF34A210DE56367BA1E204_gshared)(___0_a, ___1_alen, ___2_b, ___3_blen, ___4_len, ___5_imm8, ___6_allOnes, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Sse4_2_ComputeStriOutput_mC9EFEB2A2B9B95760CEE913DF4EF7F57BE662123 (int32_t ___0_len, int32_t ___1_imm8, int32_t ___2_intRes2, const RuntimeMethod* method) ;
inline v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 Sse4_2_ComputeStrmOutput_TisIl2CppFullySharedGenericStruct_m64ADE71FB4B90FEC60799387186E249935DE041C (int32_t ___0_len, int32_t ___1_imm8, Il2CppFullySharedGenericStruct ___2_allOnesT, int32_t ___3_intRes2, const RuntimeMethod* method)
{
	return ((  v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 (*) (int32_t, int32_t, Il2CppFullySharedGenericStruct, int32_t, const RuntimeMethod*))Sse4_2_ComputeStrmOutput_TisIl2CppFullySharedGenericStruct_m64ADE71FB4B90FEC60799387186E249935DE041C_gshared)(___0_len, ___1_imm8, ___2_allOnesT, ___3_intRes2, method);
}
inline int32_t Sse4_2_ComputeStringLength_TisIl2CppFullySharedGenericStruct_m764CDB4D47CB1C77EAA40D60D44F53C4E97CD8D6 (Il2CppFullySharedGenericStruct* ___0_ptr, int32_t ___1_max, const RuntimeMethod* method)
{
	return ((  int32_t (*) (Il2CppFullySharedGenericStruct*, int32_t, const RuntimeMethod*))Sse4_2_ComputeStringLength_TisIl2CppFullySharedGenericStruct_m764CDB4D47CB1C77EAA40D60D44F53C4E97CD8D6_gshared)(___0_ptr, ___1_max, method);
}
inline void* UnsafeUtilityExtensions_AddressOf_TisIl2CppFullySharedGenericStruct_m9A8A98C3D874841DE9AB55CBCFD69D17C27A0E2A_inline (Il2CppFullySharedGenericStruct* ___0_value, const RuntimeMethod* method)
{
	return ((  void* (*) (Il2CppFullySharedGenericStruct*, const RuntimeMethod*))UnsafeUtilityExtensions_AddressOf_TisIl2CppFullySharedGenericStruct_m9A8A98C3D874841DE9AB55CBCFD69D17C27A0E2A_gshared_inline)(___0_value, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void StreamingState_Update_mD0C172FBC9AB99BC72DF8CC3665ABB61658AB9E5 (StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020* __this, void* ___0_input, int32_t ___1_length, const RuntimeMethod* method) ;
inline void StreamingState_Update_TisIl2CppFullySharedGenericStruct_m301FBB6A80BBA46BB5AC2B0DF206CAB72593DE1D (StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020* __this, Il2CppFullySharedGenericStruct* ___0_input, const RuntimeMethod* method)
{
	((  void (*) (StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))StreamingState_Update_TisIl2CppFullySharedGenericStruct_m301FBB6A80BBA46BB5AC2B0DF206CAB72593DE1D_gshared)(__this, ___0_input, method);
}
inline Il2CppFullySharedGenericStruct* Array_Resize_TisIl2CppFullySharedGenericStruct_m07039200651D43DBB7FBC0CB244761DA34C164FD (Il2CppFullySharedGenericStruct* ___0_oldPointer, int64_t ___1_oldCount, int64_t ___2_newCount, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___3_allocator, const RuntimeMethod* method)
{
	return ((  Il2CppFullySharedGenericStruct* (*) (Il2CppFullySharedGenericStruct*, int64_t, int64_t, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148, const RuntimeMethod*))Array_Resize_TisIl2CppFullySharedGenericStruct_m07039200651D43DBB7FBC0CB244761DA34C164FD_gshared)(___0_oldPointer, ___1_oldCount, ___2_newCount, ___3_allocator, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void* Array_Resize_mC7BE2965DE3FCF4014D43B606D94951480A65380 (void* ___0_oldPointer, int64_t ___1_oldCount, int64_t ___2_newCount, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___3_allocator, int64_t ___4_size, int32_t ___5_align, const RuntimeMethod* method) ;
inline void UnsafeUtility_InternalCopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mD132267FDFD79997EE2A47470E89CE83AC7CA91E (void* ___0_ptr, Il2CppFullySharedGenericStruct* ___1_output, const RuntimeMethod* method)
{
	((  void (*) (void*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))UnsafeUtility_InternalCopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mD132267FDFD79997EE2A47470E89CE83AC7CA91E_gshared)(___0_ptr, ___1_output, method);
}
inline EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* EqualityComparer_1_CreateComparer_mF50863260964D9553ECFD6B8D81059A734FCB781 (const RuntimeMethod* method)
{
	return ((  EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* (*) (const RuntimeMethod*))EqualityComparer_1_CreateComparer_mF50863260964D9553ECFD6B8D81059A734FCB781_gshared)(method);
}
inline void* ILSupport_AddressOf_TisIl2CppFullySharedGenericStruct_m373C1FEADC4248F808294AA8958583E51840E129_inline (Il2CppFullySharedGenericStruct* ___0_thing, const RuntimeMethod* method)
{
	return ((  void* (*) (Il2CppFullySharedGenericStruct*, const RuntimeMethod*))ILSupport_AddressOf_TisIl2CppFullySharedGenericStruct_m373C1FEADC4248F808294AA8958583E51840E129_gshared_inline)(___0_thing, method);
}
// Method Definition Index: 97811
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool PrimitivesConverters_TryConvertPrimitiveOrString_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mAB1C0FA38D627EE2BBBA73E2152077F2231E1A9C_gshared (Il2CppFullySharedGenericAny* ___0_source, Il2CppFullySharedGenericAny* ___1_destination, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&TypeCode_tBEF9BE86C8BCF5A6B82F3381219738D27804EF79_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	const uint32_t SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 2));
	const Il2CppFullySharedGenericAny L_24 = alloca(SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
	const Il2CppFullySharedGenericAny L_28 = L_24;
	const Il2CppFullySharedGenericAny L_32 = L_24;
	const Il2CppFullySharedGenericAny L_36 = L_24;
	const Il2CppFullySharedGenericAny L_40 = L_24;
	const Il2CppFullySharedGenericAny L_44 = L_24;
	const Il2CppFullySharedGenericAny L_48 = L_24;
	const Il2CppFullySharedGenericAny L_52 = L_24;
	const Il2CppFullySharedGenericAny L_56 = L_24;
	const Il2CppFullySharedGenericAny L_60 = L_24;
	const Il2CppFullySharedGenericAny L_64 = L_24;
	const Il2CppFullySharedGenericAny L_68 = L_24;
	const Il2CppFullySharedGenericAny L_72 = L_24;
	Type_t* V_0 = NULL;
	Type_t* V_1 = NULL;
	Type_t* V_2 = NULL;
	int32_t V_3 = 0;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_source), (&___1_destination));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0), (&V_1), (&V_2), (&V_3));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2336));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2337));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2338));
		RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B L_0 = { reinterpret_cast<intptr_t> (&il2cpp_defaults.string_class->byval_arg) };
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2339));
		il2cpp_codegen_runtime_class_init_inline(il2cpp_defaults.systemtype_class);
		Type_t* L_1;
		L_1 = Type_GetTypeFromHandle_m6062B81682F79A4D6DF2640692EE6D9987858C57(L_0, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2339));
		V_0 = L_1;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2340));
		RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B L_2 = { reinterpret_cast<intptr_t> (il2cpp_rgctx_type(method->rgctx_data, 0)) };
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2341));
		Type_t* L_3;
		L_3 = Type_GetTypeFromHandle_m6062B81682F79A4D6DF2640692EE6D9987858C57(L_2, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2341));
		V_1 = L_3;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2342));
		Type_t* L_4 = V_1;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2343));
		NullCheck(L_4);
		bool L_5;
		L_5 = Type_get_IsPrimitive_m46ACAAB8F754D37713E3E45437705F4F58FAFA18(L_4, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2343));
		if (L_5)
		{
			goto IL_0030;
		}
	}
	{
		Type_t* L_6 = V_1;
		Type_t* L_7 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2344));
		il2cpp_codegen_runtime_class_init_inline(il2cpp_defaults.systemtype_class);
		bool L_8;
		L_8 = Type_op_Inequality_m83209C7BB3C05DFBEA3B6199B0BEFE8037301172(L_6, L_7, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2344));
		if (!L_8)
		{
			goto IL_0030;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2345));
		Il2CppFullySharedGenericAny* L_9 = ___1_destination;
		il2cpp_codegen_initobj(L_9, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2346));
		return (bool)0;
	}

IL_0030:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2347));
		RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B L_10 = { reinterpret_cast<intptr_t> (il2cpp_rgctx_type(method->rgctx_data, 3)) };
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2348));
		il2cpp_codegen_runtime_class_init_inline(il2cpp_defaults.systemtype_class);
		Type_t* L_11;
		L_11 = Type_GetTypeFromHandle_m6062B81682F79A4D6DF2640692EE6D9987858C57(L_10, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2348));
		V_2 = L_11;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2349));
		Type_t* L_12 = V_2;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2350));
		NullCheck(L_12);
		bool L_13;
		L_13 = Type_get_IsPrimitive_m46ACAAB8F754D37713E3E45437705F4F58FAFA18(L_12, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2350));
		if (L_13)
		{
			goto IL_0055;
		}
	}
	{
		Type_t* L_14 = V_2;
		Type_t* L_15 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2351));
		il2cpp_codegen_runtime_class_init_inline(il2cpp_defaults.systemtype_class);
		bool L_16;
		L_16 = Type_op_Inequality_m83209C7BB3C05DFBEA3B6199B0BEFE8037301172(L_14, L_15, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2351));
		if (!L_16)
		{
			goto IL_0055;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2352));
		Il2CppFullySharedGenericAny* L_17 = ___1_destination;
		il2cpp_codegen_initobj(L_17, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2353));
		return (bool)0;
	}

IL_0055:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2354));
		Type_t* L_18 = V_1;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2355));
		il2cpp_codegen_runtime_class_init_inline(il2cpp_defaults.systemtype_class);
		int32_t L_19;
		L_19 = Type_GetTypeCode_m2CE476933AF4B381D7A52F4343B70E9878FDF466(L_18, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2355));
		V_3 = L_19;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2356));
		int32_t L_20 = V_3;
		switch (((int32_t)il2cpp_codegen_subtract((int32_t)L_20, 3)))
		{
			case 0:
			{
				goto IL_00a9;
			}
			case 1:
			{
				goto IL_00cf;
			}
			case 2:
			{
				goto IL_012e;
			}
			case 3:
			{
				goto IL_00bc;
			}
			case 4:
			{
				goto IL_00f5;
			}
			case 5:
			{
				goto IL_0167;
			}
			case 6:
			{
				goto IL_0108;
			}
			case 7:
			{
				goto IL_017a;
			}
			case 8:
			{
				goto IL_011b;
			}
			case 9:
			{
				goto IL_018d;
			}
			case 10:
			{
				goto IL_0141;
			}
			case 11:
			{
				goto IL_00e2;
			}
			case 12:
			{
				goto IL_01a0;
			}
			case 13:
			{
				goto IL_01a0;
			}
			case 14:
			{
				goto IL_01a0;
			}
			case 15:
			{
				goto IL_0154;
			}
		}
	}
	{
		goto IL_01a0;
	}

IL_00a9:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2357));
		Il2CppFullySharedGenericAny* L_21 = ___1_destination;
		Il2CppFullySharedGenericAny* L_22 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2358));
		bool* L_23;
		L_23 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisBoolean_t09A6377A54BE2F9E6985A8149F19234FD7DDFE22_m442ECCC3108A0DA30933490DE73A749856262150_inline(L_22, il2cpp_rgctx_method(method->rgctx_data, 5));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2358));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2359));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m856D276A33760D3F9B6FDC631F337372BC41037E(L_23, (Il2CppFullySharedGenericAny*)L_24, il2cpp_rgctx_method(method->rgctx_data, 6));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2359));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_21, L_24, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_21, (void*)L_24);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2360));
		return (bool)1;
	}

IL_00bc:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2361));
		Il2CppFullySharedGenericAny* L_25 = ___1_destination;
		Il2CppFullySharedGenericAny* L_26 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2362));
		uint8_t* L_27;
		L_27 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisByte_t94D9231AC217BE4D2E004C4CD32DF6D099EA41A3_mAAB228FFADB76FA6BB6686BBDB9479779E20A7C6_inline(L_26, il2cpp_rgctx_method(method->rgctx_data, 7));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2362));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2363));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mFD12A694611E03895F4458912B9FE341B07D690C(L_27, (Il2CppFullySharedGenericAny*)L_28, il2cpp_rgctx_method(method->rgctx_data, 8));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2363));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_25, L_28, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_25, (void*)L_28);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2364));
		return (bool)1;
	}

IL_00cf:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2365));
		Il2CppFullySharedGenericAny* L_29 = ___1_destination;
		Il2CppFullySharedGenericAny* L_30 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2366));
		Il2CppChar* L_31;
		L_31 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisChar_t521A6F19B456D956AF452D926C32709DC03D6B17_mE5405089F0731E1FEDDBDC485048456549B8F81A_inline(L_30, il2cpp_rgctx_method(method->rgctx_data, 9));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2366));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2367));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m691506CA4682A3878264EEB52FA188912614F238(L_31, (Il2CppFullySharedGenericAny*)L_32, il2cpp_rgctx_method(method->rgctx_data, 10));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2367));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_29, L_32, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_29, (void*)L_32);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2368));
		return (bool)1;
	}

IL_00e2:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2369));
		Il2CppFullySharedGenericAny* L_33 = ___1_destination;
		Il2CppFullySharedGenericAny* L_34 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2370));
		double* L_35;
		L_35 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisDouble_tE150EF3D1D43DEE85D533810AB4C742307EEDE5F_mEBB444EE29C3C196347A1EE7E44C9F299B396D5E_inline(L_34, il2cpp_rgctx_method(method->rgctx_data, 11));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2370));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2371));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mCC237A07CD7A39540520FE43C66A49204AD02060(L_35, (Il2CppFullySharedGenericAny*)L_36, il2cpp_rgctx_method(method->rgctx_data, 12));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2371));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_33, L_36, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_33, (void*)L_36);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2372));
		return (bool)1;
	}

IL_00f5:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2373));
		Il2CppFullySharedGenericAny* L_37 = ___1_destination;
		Il2CppFullySharedGenericAny* L_38 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2374));
		int16_t* L_39;
		L_39 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisInt16_tB8EF286A9C33492FA6E6D6E67320BE93E794A175_mF7F3D38918DD7AAB2206B1C5D2F95935F1A78141_inline(L_38, il2cpp_rgctx_method(method->rgctx_data, 13));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2374));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2375));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m262B2BBB933FB2B1DBDA65D418FD3A0EA166B4AF(L_39, (Il2CppFullySharedGenericAny*)L_40, il2cpp_rgctx_method(method->rgctx_data, 14));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2375));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_37, L_40, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_37, (void*)L_40);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2376));
		return (bool)1;
	}

IL_0108:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2377));
		Il2CppFullySharedGenericAny* L_41 = ___1_destination;
		Il2CppFullySharedGenericAny* L_42 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2378));
		int32_t* L_43;
		L_43 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m5E4D05CB0C699ABEB044C09A5C38EA0E714D013B_inline(L_42, il2cpp_rgctx_method(method->rgctx_data, 15));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2378));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2379));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m0E14C5AEDCB7F8A75EEE6D4D476E00E0DD7A5531(L_43, (Il2CppFullySharedGenericAny*)L_44, il2cpp_rgctx_method(method->rgctx_data, 16));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2379));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_41, L_44, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_41, (void*)L_44);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2380));
		return (bool)1;
	}

IL_011b:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2381));
		Il2CppFullySharedGenericAny* L_45 = ___1_destination;
		Il2CppFullySharedGenericAny* L_46 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2382));
		int64_t* L_47;
		L_47 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisInt64_t092CFB123BE63C28ACDAF65C68F21A526050DBA3_mDE435009462C7C302356109B64DAD634148B4099_inline(L_46, il2cpp_rgctx_method(method->rgctx_data, 17));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2382));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2383));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m3BFB7BDCFA2447B375F048512E95569635B8D4E4(L_47, (Il2CppFullySharedGenericAny*)L_48, il2cpp_rgctx_method(method->rgctx_data, 18));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2383));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_45, L_48, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_45, (void*)L_48);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2384));
		return (bool)1;
	}

IL_012e:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2385));
		Il2CppFullySharedGenericAny* L_49 = ___1_destination;
		Il2CppFullySharedGenericAny* L_50 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2386));
		int8_t* L_51;
		L_51 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisSByte_tFEFFEF5D2FEBF5207950AE6FAC150FC53B668DB5_m4310668E52FB7067987D6E9321559DDF3A2FA60A_inline(L_50, il2cpp_rgctx_method(method->rgctx_data, 19));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2386));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2387));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m1967E1AEC5A0D9648CA206B187F6DA76F7865322(L_51, (Il2CppFullySharedGenericAny*)L_52, il2cpp_rgctx_method(method->rgctx_data, 20));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2387));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_49, L_52, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_49, (void*)L_52);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2388));
		return (bool)1;
	}

IL_0141:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2389));
		Il2CppFullySharedGenericAny* L_53 = ___1_destination;
		Il2CppFullySharedGenericAny* L_54 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2390));
		float* L_55;
		L_55 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisSingle_t4530F2FF86FCB0DC29F35385CA1BD21BE294761C_m9E826A3FF880E1787077B6E79CA0C8C363A54997_inline(L_54, il2cpp_rgctx_method(method->rgctx_data, 21));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2390));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2391));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m6F7761D5CA3434775F5725B70793B2676B5BB50A(L_55, (Il2CppFullySharedGenericAny*)L_56, il2cpp_rgctx_method(method->rgctx_data, 22));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2391));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_53, L_56, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_53, (void*)L_56);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2392));
		return (bool)1;
	}

IL_0154:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2393));
		Il2CppFullySharedGenericAny* L_57 = ___1_destination;
		Il2CppFullySharedGenericAny* L_58 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2394));
		String_t** L_59;
		L_59 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisString_t_m9BC71B961562D33981F3D2A518280ACCCC720714_inline(L_58, il2cpp_rgctx_method(method->rgctx_data, 23));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2394));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2395));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_mB352A8132547464344E6835AF40F1C7DA0FC6179(L_59, (Il2CppFullySharedGenericAny*)L_60, il2cpp_rgctx_method(method->rgctx_data, 24));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2395));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_57, L_60, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_57, (void*)L_60);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2396));
		return (bool)1;
	}

IL_0167:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2397));
		Il2CppFullySharedGenericAny* L_61 = ___1_destination;
		Il2CppFullySharedGenericAny* L_62 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2398));
		uint16_t* L_63;
		L_63 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisUInt16_tF4C148C876015C212FD72652D0B6ED8CC247A455_m33A571A8A920313DC399CF856BA643AEFFEE4840_inline(L_62, il2cpp_rgctx_method(method->rgctx_data, 25));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2398));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2399));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m6A1DA3430E328697B3C1E053374FAEACF0C77F95(L_63, (Il2CppFullySharedGenericAny*)L_64, il2cpp_rgctx_method(method->rgctx_data, 26));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2399));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_61, L_64, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_61, (void*)L_64);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2400));
		return (bool)1;
	}

IL_017a:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2401));
		Il2CppFullySharedGenericAny* L_65 = ___1_destination;
		Il2CppFullySharedGenericAny* L_66 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2402));
		uint32_t* L_67;
		L_67 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisUInt32_t1833D51FFA667B18A5AA4B8D34DE284F8495D29B_mB8FE2798F42657FD77E43F73BE64B9A2ECAD370A_inline(L_66, il2cpp_rgctx_method(method->rgctx_data, 27));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2402));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2403));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m62DAACE3E3F12517F13F380BE744A38D69E12156(L_67, (Il2CppFullySharedGenericAny*)L_68, il2cpp_rgctx_method(method->rgctx_data, 28));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2403));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_65, L_68, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_65, (void*)L_68);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2404));
		return (bool)1;
	}

IL_018d:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2405));
		Il2CppFullySharedGenericAny* L_69 = ___1_destination;
		Il2CppFullySharedGenericAny* L_70 = ___0_source;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2406));
		uint64_t* L_71;
		L_71 = UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisUInt64_t8F12534CC8FC4B5860F2A2CD1EE79D322E7A41AF_m0D05B6202B7FECB3D9612396E65FA72BCBD2671A_inline(L_70, il2cpp_rgctx_method(method->rgctx_data, 29));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2406));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2407));
		PrimitivesConverters_DoConvert_TisIl2CppFullySharedGenericAny_m855CA8553E43D1238E78F509DF06C0671DB8A242(L_71, (Il2CppFullySharedGenericAny*)L_72, il2cpp_rgctx_method(method->rgctx_data, 30));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2407));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_69, L_72, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericAny*)L_69, (void*)L_72);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2408));
		return (bool)1;
	}

IL_01a0:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2409));
		Il2CppFullySharedGenericAny* L_73 = ___1_destination;
		il2cpp_codegen_initobj(L_73, SizeOf_TDestination_tAC5BFD4B78BBF0013ECE1D6EDEC896A74B5E9325);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 2410));
		return (bool)0;
	}
}
// Method Definition Index: 97869
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void TypeConstructorVisitor_Visit_TisIl2CppFullySharedGenericAny_m8B414261A078E3FE7517FAF2F9E944969F6B73E2_gshared (TypeConstructorVisitor_tFC61250F68BF43FE889F5B1002CBFF90648E9C7F* __this, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&TypeConstructorVisitor_tFC61250F68BF43FE889F5B1002CBFF90648E9C7F_0_0_0_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&TypeUtility_t62F146E51B66BB18FA0E1EFA84A564FF2B8AAD03_il2cpp_TypeInfo_var);
		il2cpp_rgctx_method_init(method);
	}
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, NULL, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 4232));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 4233));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 4234));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 4235));
		il2cpp_codegen_runtime_class_init_inline(TypeUtility_t62F146E51B66BB18FA0E1EFA84A564FF2B8AAD03_il2cpp_TypeInfo_var);
		RuntimeObject* L_0;
		L_0 = TypeUtility_CreateTypeConstructor_TisIl2CppFullySharedGenericAny_mA5F70CB8E7370027F0A598FE0123F8A050704304(il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_PropertiesModule + 4235));
		__this->___TypeConstructor = (RuntimeObject*)L_0;
		Il2CppCodeGenWriteBarrier((void**)(&__this->___TypeConstructor), (void*)(RuntimeObject*)L_0);
		return;
	}
}
// Method Definition Index: 84461
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m4BEED82D6907F7A1B30916AD15A551B4477AB2C2_gshared (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6_0_0_0_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&VoidU2A_t104EAEFBD2D237A8C29618913DA9B4D99355E965_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	const uint32_t SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 3));
	const Il2CppFullySharedGenericStruct L_8 = alloca(SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
	const Il2CppFullySharedGenericStruct L_13 = L_8;
	const Il2CppFullySharedGenericStruct L_14 = L_8;
	int32_t V_0 = 0;
	Il2CppFullySharedGenericStruct V_1 = alloca(SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
	memset(V_1, 0, SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
	void* V_2 = NULL;
	bool V_3 = false;
	Il2CppFullySharedGenericStruct V_4 = alloca(SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
	memset(V_4, 0, SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0), V_1, (&V_2));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, NULL, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31312));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 31313));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31314));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:392>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31315));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31316));
		int32_t L_0;
		L_0 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31316));
		V_0 = L_0;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:396>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31317));
		uint8_t* L_1 = __this->___Ptr;
		int32_t L_2 = __this->___Offset;
		V_2 = (void*)((uint8_t*)il2cpp_codegen_add((intptr_t)L_1, L_2));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:397>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31318));
		void* L_3 = V_2;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31319));
		int32_t L_4;
		L_4 = UnsafeUtility_AlignOf_TisIl2CppFullySharedGenericStruct_m11D1023B182BE19CF0F1A57DBE826004A1B81A41(il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31319));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31320));
		bool L_5;
		L_5 = CollectionHelper_IsAligned_m4761669B9084B892256349C0FF27DBF494DA9AE9((uint64_t)((int64_t)(uint64_t)((uintptr_t)(intptr_t)L_3)), L_4, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31320));
		V_3 = L_5;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31321));
		bool L_6 = V_3;
		if (!L_6)
		{
			goto IL_002f;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:398>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31322));
		void* L_7 = V_2;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31323));
		UnsafeUtility_ReadArrayElement_TisIl2CppFullySharedGenericStruct_m45AD40013DEE9AEF8031E0DA6F4D23BFD5AA8F42_inline(L_7, 0, (Il2CppFullySharedGenericStruct*)L_8, il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31323));
		il2cpp_codegen_memcpy(V_1, L_8, SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31324));
		goto IL_003b;
	}

IL_002f:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:400>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31325));
		void* L_9 = V_2;
		int32_t L_10 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31326));
		UnsafeUtility_MemCpy_m5CEA91ACDADC522E584AE3A2AB2B0B74393A9177((void*)((uintptr_t)(Il2CppFullySharedGenericStruct*)V_1), L_9, ((int64_t)L_10), NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31326));
	}

IL_003b:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:402>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31327));
		int32_t L_11 = __this->___Offset;
		int32_t L_12 = V_0;
		__this->___Offset = ((int32_t)il2cpp_codegen_add(L_11, L_12));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:403>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31328));
		il2cpp_codegen_memcpy(L_13, V_1, SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
		il2cpp_codegen_memcpy(V_4, L_13, SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
		goto IL_004e;
	}

IL_004e:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:404>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31329));
		il2cpp_codegen_memcpy(L_14, V_4, SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
		il2cpp_codegen_memcpy(il2cppRetVal, L_14, SizeOf_T_t23EFE765355235E0552FEAA74620709E7D407C49);
		return;
	}
}
IL2CPP_EXTERN_C  void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m4BEED82D6907F7A1B30916AD15A551B4477AB2C2_AdjustorThunk (RuntimeObject* __this, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method)
{
	Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*>(__this + _offset);
	Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m4BEED82D6907F7A1B30916AD15A551B4477AB2C2(_thisAdjusted, il2cppRetVal, method);
	return;
}
// Method Definition Index: 84460
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_mD61521649968D72362C4D143C6798CF697284C59_gshared (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, Il2CppFullySharedGenericStruct* ___0_value, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6_0_0_0_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&VoidU2A_t104EAEFBD2D237A8C29618913DA9B4D99355E965_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	int32_t V_0 = 0;
	void* V_1 = NULL;
	bool V_2 = false;
	void* V_3 = NULL;
	Il2CppFullySharedGenericStruct* V_4 = NULL;
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_value));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0), (&V_1), (&V_3));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31293));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 31294));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31295));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:371>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31296));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31297));
		int32_t L_0;
		L_0 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31297));
		V_0 = L_0;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:374>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31298));
		uint8_t* L_1 = __this->___Ptr;
		int32_t L_2 = __this->___Offset;
		V_1 = (void*)((uint8_t*)il2cpp_codegen_add((intptr_t)L_1, L_2));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:375>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31299));
		void* L_3 = V_1;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31300));
		int32_t L_4;
		L_4 = UnsafeUtility_AlignOf_TisIl2CppFullySharedGenericStruct_m11D1023B182BE19CF0F1A57DBE826004A1B81A41(il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31300));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31301));
		bool L_5;
		L_5 = CollectionHelper_IsAligned_m4761669B9084B892256349C0FF27DBF494DA9AE9((uint64_t)((int64_t)(uint64_t)((uintptr_t)(intptr_t)L_3)), L_4, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31301));
		V_2 = L_5;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31302));
		bool L_6 = V_2;
		if (!L_6)
		{
			goto IL_002f;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:376>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31303));
		void* L_7 = V_1;
		Il2CppFullySharedGenericStruct* L_8 = ___0_value;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31304));
		UnsafeUtility_CopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mBE6568C7ECF69CD1E86FDFF4E25D6CB529F76BF3_inline(L_7, L_8, il2cpp_rgctx_method(method->rgctx_data, 3));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31304));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31305));
		goto IL_0044;
	}

IL_002f:
	{
		Il2CppFullySharedGenericStruct* L_9 = ___0_value;
		V_4 = L_9;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:378>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31306));
		Il2CppFullySharedGenericStruct* L_10 = V_4;
		V_3 = (void*)((uintptr_t)L_10);
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:378>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31307));
		void* L_11 = V_3;
		void* L_12 = V_1;
		int32_t L_13 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31308));
		UnsafeUtility_MemCpy_m5CEA91ACDADC522E584AE3A2AB2B0B74393A9177(L_11, L_12, ((int64_t)L_13), NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31308));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31309));
		V_4 = (Il2CppFullySharedGenericStruct*)((uintptr_t)0);
	}

IL_0044:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:380>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31310));
		int32_t L_14 = __this->___Offset;
		int32_t L_15 = V_0;
		__this->___Offset = ((int32_t)il2cpp_codegen_add(L_14, L_15));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:381>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31311));
		return;
	}
}
IL2CPP_EXTERN_C  void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_mD61521649968D72362C4D143C6798CF697284C59_AdjustorThunk (RuntimeObject* __this, Il2CppFullySharedGenericStruct* ___0_value, const RuntimeMethod* method)
{
	Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*>(__this + _offset);
	Reader_ReadNext_TisIl2CppFullySharedGenericStruct_mD61521649968D72362C4D143C6798CF697284C59(_thisAdjusted, ___0_value, method);
}
// Method Definition Index: 84463
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m08EA2C685C92045455508A2CEA28AF34C49BF372_gshared (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18* ___0_value, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___1_allocator, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Reader_ReadNext_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m008862EE68B89223188A3A1C95A528DC5CD56774_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6_0_0_0_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&VoidU2A_t104EAEFBD2D237A8C29618913DA9B4D99355E965_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	int32_t V_0 = 0;
	int32_t V_1 = 0;
	bool V_2 = false;
	void* V_3 = NULL;
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_value), (&___1_allocator));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0), (&V_1), (&V_3));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31340));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 31341));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31342));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:431>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31343));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31344));
		int32_t L_0;
		L_0 = Reader_ReadNext_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m008862EE68B89223188A3A1C95A528DC5CD56774(__this, Reader_ReadNext_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m008862EE68B89223188A3A1C95A528DC5CD56774_RuntimeMethod_var);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31344));
		V_0 = L_0;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:432>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31345));
		NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18* L_1 = ___0_value;
		int32_t L_2 = V_0;
		AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 L_3 = ___1_allocator;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31346));
		NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 L_4;
		L_4 = CollectionHelper_CreateNativeArray_TisIl2CppFullySharedGenericStruct_m4005EA9C29BA1075D9F591B6CBD82B5D22255763(L_2, L_3, (int32_t)0, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31346));
		*(NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18*)L_1 = L_4;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:433>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31347));
		int32_t L_5 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31348));
		int32_t L_6;
		L_6 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 3));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31348));
		V_1 = ((int32_t)il2cpp_codegen_multiply(L_5, L_6));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:434>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31349));
		int32_t L_7 = V_1;
		V_2 = (bool)((((int32_t)L_7) > ((int32_t)0))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31350));
		bool L_8 = V_2;
		if (!L_8)
		{
			goto IL_0044;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31351));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:436>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31352));
		int32_t L_9 = V_1;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31353));
		void* L_10;
		L_10 = Reader_ReadNext_m7C9150A60E622C8581A3E80C8DD1AD71D043BF6A(__this, L_9, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31353));
		V_3 = L_10;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:437>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31354));
		NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18* L_11 = ___0_value;
		NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 L_12 = (*(NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18*)L_11);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31355));
		void* L_13;
		L_13 = NativeArrayUnsafeUtility_GetUnsafePtr_TisIl2CppFullySharedGenericStruct_m4AB802D5B1B296D0F976C1E7631699B0C4A4D00F_inline(L_12, il2cpp_rgctx_method(method->rgctx_data, 4));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31355));
		void* L_14 = V_3;
		int32_t L_15 = V_1;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31356));
		UnsafeUtility_MemCpy_m5CEA91ACDADC522E584AE3A2AB2B0B74393A9177(L_13, L_14, ((int64_t)L_15), NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31356));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31357));
	}

IL_0044:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:439>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31358));
		return;
	}
}
IL2CPP_EXTERN_C  void Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m08EA2C685C92045455508A2CEA28AF34C49BF372_AdjustorThunk (RuntimeObject* __this, NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18* ___0_value, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___1_allocator, const RuntimeMethod* method)
{
	Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*>(__this + _offset);
	Reader_ReadNext_TisIl2CppFullySharedGenericStruct_m08EA2C685C92045455508A2CEA28AF34C49BF372(_thisAdjusted, ___0_value, ___1_allocator, method);
}
// Method Definition Index: 84464
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void* Reader_ReadNextArray_TisIl2CppFullySharedGenericStruct_mE1C3BA7C6F410106344DD729D6EBF3FB62CB67CC_gshared (Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* __this, int32_t* ___0_length, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Reader_ReadNext_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m008862EE68B89223188A3A1C95A528DC5CD56774_RuntimeMethod_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6_0_0_0_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&VoidU2A_t104EAEFBD2D237A8C29618913DA9B4D99355E965_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	void* V_0 = NULL;
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_length));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31359));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 31360));
	uintptr_t G_B3_0;
	memset((&G_B3_0), 0, sizeof(G_B3_0));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31361));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:454>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31362));
		int32_t* L_0 = ___0_length;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31363));
		int32_t L_1;
		L_1 = Reader_ReadNext_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m008862EE68B89223188A3A1C95A528DC5CD56774(__this, Reader_ReadNext_TisInt32_t680FF22E76F6EFAD4375103CBBFFA0421349384C_m008862EE68B89223188A3A1C95A528DC5CD56774_RuntimeMethod_var);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31363));
		*((int32_t*)L_0) = (int32_t)L_1;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:455>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31364));
		int32_t* L_2 = ___0_length;
		int32_t L_3 = *((int32_t*)L_2);
		if (!L_3)
		{
			goto IL_001d;
		}
	}
	{
		int32_t* L_4 = ___0_length;
		int32_t L_5 = *((int32_t*)L_4);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31365));
		int32_t L_6;
		L_6 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31365));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31366));
		void* L_7;
		L_7 = Reader_ReadNext_m7C9150A60E622C8581A3E80C8DD1AD71D043BF6A(__this, ((int32_t)il2cpp_codegen_multiply(L_5, L_6)), NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31366));
		G_B3_0 = ((uintptr_t)(intptr_t)(L_7));
		goto IL_001f;
	}

IL_001d:
	{
		G_B3_0 = ((uintptr_t)0);
	}

IL_001f:
	{
		V_0 = (void*)G_B3_0;
		goto IL_0022;
	}

IL_0022:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeAppendBuffer.cs:456>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 31367));
		void* L_8 = V_0;
		return L_8;
	}
}
IL2CPP_EXTERN_C  void* Reader_ReadNextArray_TisIl2CppFullySharedGenericStruct_mE1C3BA7C6F410106344DD729D6EBF3FB62CB67CC_AdjustorThunk (RuntimeObject* __this, int32_t* ___0_length, const RuntimeMethod* method)
{
	Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<Reader_t409B401DB3A9E3F5C637DF66E5FAB1F63C291CB6*>(__this + _offset);
	void* _returnValue;
	_returnValue = Reader_ReadNextArray_TisIl2CppFullySharedGenericStruct_mE1C3BA7C6F410106344DD729D6EBF3FB62CB67CC(_thisAdjusted, ___0_length, method);
	return _returnValue;
}
// Method Definition Index: 85161
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Reader_Peek_TisIl2CppFullySharedGenericStruct_m9282B5560EB03FCC4C6F0F8AC634AE5A13B555D6_gshared (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* __this, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&ByteU2A_t7A03686A8034AF92EF1EA2D09B280EF590D1174D_0_0_0_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	int32_t V_0 = 0;
	uint8_t* V_1 = NULL;
	bool V_2 = false;
	Il2CppFullySharedGenericStruct* V_3 = NULL;
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0), (&V_1));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, NULL, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39808));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 39809));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39810));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:723>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39811));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39812));
		int32_t L_0;
		L_0 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39812));
		V_0 = L_0;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:725>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39813));
		uint8_t* L_1 = __this->___m_CurrentPtr;
		V_1 = L_1;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:726>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39814));
		uint8_t* L_2 = V_1;
		int32_t L_3 = V_0;
		uint8_t* L_4 = __this->___m_CurrentBlockEnd;
		V_2 = (bool)((!(((uintptr_t)((uint8_t*)il2cpp_codegen_add((intptr_t)L_2, L_3))) <= ((uintptr_t)L_4)))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39815));
		bool L_5 = V_2;
		if (!L_5)
		{
			goto IL_0036;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39816));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:728>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39817));
		UnsafeStreamBlock_t0DE96C782B2CBF67BE34978C364781E170B3A86C* L_6 = __this->___m_CurrentBlock;
		NullCheck(L_6);
		UnsafeStreamBlock_t0DE96C782B2CBF67BE34978C364781E170B3A86C* L_7 = L_6->___Next;
		NullCheck(L_7);
		U3CDataU3Ee__FixedBuffer_t60155FEDF2B8430C4B466CB3CDD85327C03F1116* L_8 = (U3CDataU3Ee__FixedBuffer_t60155FEDF2B8430C4B466CB3CDD85327C03F1116*)(&L_7->___Data);
		uint8_t* L_9 = (uint8_t*)(&L_8->___FixedElementField);
		V_1 = (uint8_t*)((uintptr_t)L_9);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39818));
	}

IL_0036:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:731>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39819));
		uint8_t* L_10 = V_1;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39820));
		Il2CppFullySharedGenericStruct* L_11;
		L_11 = UnsafeUtility_AsRef_TisIl2CppFullySharedGenericStruct_m78B0690121A96EFFDA7D6D3ADAF97940CF8136BE_inline((void*)L_10, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39820));
		V_3 = L_11;
		goto IL_003f;
	}

IL_003f:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:732>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39821));
		Il2CppFullySharedGenericStruct* L_12 = V_3;
		return L_12;
	}
}
IL2CPP_EXTERN_C  Il2CppFullySharedGenericStruct* Reader_Peek_TisIl2CppFullySharedGenericStruct_m9282B5560EB03FCC4C6F0F8AC634AE5A13B555D6_AdjustorThunk (RuntimeObject* __this, const RuntimeMethod* method)
{
	Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458*>(__this + _offset);
	Il2CppFullySharedGenericStruct* _returnValue;
	_returnValue = Reader_Peek_TisIl2CppFullySharedGenericStruct_m9282B5560EB03FCC4C6F0F8AC634AE5A13B555D6(_thisAdjusted, method);
	return _returnValue;
}
// Method Definition Index: 85160
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Reader_Read_TisIl2CppFullySharedGenericStruct_mBBF673BF9BED0383144F187B6541B532F2B6A633_gshared (Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* __this, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	int32_t V_0 = 0;
	Il2CppFullySharedGenericStruct* V_1 = NULL;
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, NULL, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39799));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 39800));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39801));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:711>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39802));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39803));
		int32_t L_0;
		L_0 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39803));
		V_0 = L_0;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:712>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39804));
		int32_t L_1 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39805));
		uint8_t* L_2;
		L_2 = Reader_ReadUnsafePtr_m6CDEF727114990BC4C2DF321BE752F229104A888(__this, L_1, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39805));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39806));
		Il2CppFullySharedGenericStruct* L_3;
		L_3 = UnsafeUtility_AsRef_TisIl2CppFullySharedGenericStruct_m78B0690121A96EFFDA7D6D3ADAF97940CF8136BE_inline((void*)L_2, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39806));
		V_1 = L_3;
		goto IL_0016;
	}

IL_0016:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:713>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39807));
		Il2CppFullySharedGenericStruct* L_4 = V_1;
		return L_4;
	}
}
IL2CPP_EXTERN_C  Il2CppFullySharedGenericStruct* Reader_Read_TisIl2CppFullySharedGenericStruct_mBBF673BF9BED0383144F187B6541B532F2B6A633_AdjustorThunk (RuntimeObject* __this, const RuntimeMethod* method)
{
	Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<Reader_tE85B398678D2471A73C94A5DCAECD9AA2CAA4458*>(__this + _offset);
	Il2CppFullySharedGenericStruct* _returnValue;
	_returnValue = Reader_Read_TisIl2CppFullySharedGenericStruct_mBBF673BF9BED0383144F187B6541B532F2B6A633(_thisAdjusted, method);
	return _returnValue;
}
// Method Definition Index: 85150
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Writer_Allocate_TisIl2CppFullySharedGenericStruct_m4503233E7BE788F93FD1C91B7BE65AC121483DB7_gshared (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* __this, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	int32_t V_0 = 0;
	Il2CppFullySharedGenericStruct* V_1 = NULL;
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, NULL, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39695));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 39696));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39697));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:516>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39698));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39699));
		int32_t L_0;
		L_0 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39699));
		V_0 = L_0;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:517>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39700));
		int32_t L_1 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39701));
		uint8_t* L_2;
		L_2 = Writer_Allocate_m85F9D4FF8746C0A59DC23A9003398A6D9D42526D(__this, L_1, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39701));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39702));
		Il2CppFullySharedGenericStruct* L_3;
		L_3 = UnsafeUtility_AsRef_TisIl2CppFullySharedGenericStruct_m78B0690121A96EFFDA7D6D3ADAF97940CF8136BE_inline((void*)L_2, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39702));
		V_1 = L_3;
		goto IL_0016;
	}

IL_0016:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:518>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39703));
		Il2CppFullySharedGenericStruct* L_4 = V_1;
		return L_4;
	}
}
IL2CPP_EXTERN_C  Il2CppFullySharedGenericStruct* Writer_Allocate_TisIl2CppFullySharedGenericStruct_m4503233E7BE788F93FD1C91B7BE65AC121483DB7_AdjustorThunk (RuntimeObject* __this, const RuntimeMethod* method)
{
	Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F*>(__this + _offset);
	Il2CppFullySharedGenericStruct* _returnValue;
	_returnValue = Writer_Allocate_TisIl2CppFullySharedGenericStruct_m4503233E7BE788F93FD1C91B7BE65AC121483DB7(_thisAdjusted, method);
	return _returnValue;
}
// Method Definition Index: 85149
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Writer_Write_TisIl2CppFullySharedGenericStruct_m3255C6DE3AD541593524A784715AE50082831917_gshared (Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* __this, Il2CppFullySharedGenericStruct ___0_value, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	const uint32_t SizeOf_T_t4D7283DBD6CD71348652C5C25061A381CAB760A7 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 2));
	const Il2CppFullySharedGenericStruct L_2 = alloca(SizeOf_T_t4D7283DBD6CD71348652C5C25061A381CAB760A7);
	Il2CppFullySharedGenericStruct* V_0 = NULL;
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->rgctx_data, 2)) ? ___0_value : &___0_value));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39688));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 39689));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39690));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:502>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39691));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39692));
		Il2CppFullySharedGenericStruct* L_0;
		L_0 = Writer_Allocate_TisIl2CppFullySharedGenericStruct_m4503233E7BE788F93FD1C91B7BE65AC121483DB7(__this, il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39692));
		V_0 = L_0;
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:503>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39693));
		Il2CppFullySharedGenericStruct* L_1 = V_0;
		il2cpp_codegen_memcpy(L_2, ___0_value, SizeOf_T_t4D7283DBD6CD71348652C5C25061A381CAB760A7);
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericStruct*)L_1, L_2, SizeOf_T_t4D7283DBD6CD71348652C5C25061A381CAB760A7);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 2), (void**)(Il2CppFullySharedGenericStruct*)L_1, (void*)L_2);
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeStream.cs:504>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 39694));
		return;
	}
}
IL2CPP_EXTERN_C  void Writer_Write_TisIl2CppFullySharedGenericStruct_m3255C6DE3AD541593524A784715AE50082831917_AdjustorThunk (RuntimeObject* __this, Il2CppFullySharedGenericStruct ___0_value, const RuntimeMethod* method)
{
	Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<Writer_t16BC5D7104F5959779BA8C578EC794067872FB0F*>(__this + _offset);
	Writer_Write_TisIl2CppFullySharedGenericStruct_m3255C6DE3AD541593524A784715AE50082831917(_thisAdjusted, ___0_value, method);
}
// Method Definition Index: 91956
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Avx2_EmulatedGather_TisIl2CppFullySharedGenericStruct_TisIl2CppFullySharedGenericStruct_m78BBC4DBE234DA027814A059C7A569C168B14265_gshared (Il2CppFullySharedGenericStruct* ___0_dptr, void* ___1_base_addr, int32_t* ___2_indexPtr, int32_t ___3_scale, int32_t ___4_n, Il2CppFullySharedGenericStruct* ___5_mask, const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	const uint32_t SizeOf_U_tD3AAA6C44816F6B7C2E20A7D231588A6DD300594 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 0));
	void* L_12 = alloca(Il2CppFakeBoxBuffer::SizeNeededFor(il2cpp_rgctx_data(method->rgctx_data, 0)));
	const uint32_t SizeOf_T_t7746E565CB09ADDE66D7FE8BA2706651748F4314 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 5));
	const Il2CppFullySharedGenericStruct L_19 = alloca(SizeOf_T_t7746E565CB09ADDE66D7FE8BA2706651748F4314);
	const Il2CppFullySharedGenericStruct L_11 = alloca(SizeOf_U_tD3AAA6C44816F6B7C2E20A7D231588A6DD300594);
	Il2CppFullySharedGenericStruct V_0 = alloca(SizeOf_U_tD3AAA6C44816F6B7C2E20A7D231588A6DD300594);
	memset(V_0, 0, SizeOf_U_tD3AAA6C44816F6B7C2E20A7D231588A6DD300594);
	int32_t V_1 = 0;
	int64_t V_2 = 0;
	int64_t V_3 = 0;
	Il2CppFullySharedGenericStruct* V_4 = NULL;
	bool V_5 = false;
	bool V_6 = false;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_dptr), (&___1_base_addr), (&___2_indexPtr), (&___3_scale), (&___4_n), (&___5_mask));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, V_0, (&V_1), (&V_2), (&V_3), (&V_4));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20327));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 20328));
	int32_t G_B4_0 = 0;
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20329));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2355>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20330));
		il2cpp_codegen_initobj((Il2CppFullySharedGenericStruct*)V_0, SizeOf_U_tD3AAA6C44816F6B7C2E20A7D231588A6DD300594);
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2357>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20331));
		V_1 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20332));
		goto IL_006a;
	}

IL_000d:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20333));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2359>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20334));
		int32_t* L_0 = ___2_indexPtr;
		int32_t L_1 = V_1;
		int32_t L_2 = (*(((int32_t*)il2cpp_codegen_add((intptr_t)L_0, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_1), 4))))));
		V_2 = ((int64_t)L_2);
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2360>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20335));
		int64_t L_3 = V_2;
		int32_t L_4 = ___3_scale;
		V_3 = ((int64_t)il2cpp_codegen_multiply(L_3, ((int64_t)L_4)));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2361>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20336));
		void* L_5 = ___1_base_addr;
		int64_t L_6 = V_3;
		V_4 = (Il2CppFullySharedGenericStruct*)((void*)il2cpp_codegen_add((intptr_t)L_5, ((intptr_t)L_6)));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2362>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20337));
		Il2CppFullySharedGenericStruct* L_7 = ___5_mask;
		if ((((intptr_t)L_7) == ((intptr_t)((uintptr_t)0))))
		{
			goto IL_0045;
		}
	}
	{
		Il2CppFullySharedGenericStruct* L_8 = ___5_mask;
		int32_t L_9 = V_1;
		uint32_t L_10 = SizeOf_U_tD3AAA6C44816F6B7C2E20A7D231588A6DD300594;
		il2cpp_codegen_memcpy(L_11, V_0, SizeOf_U_tD3AAA6C44816F6B7C2E20A7D231588A6DD300594);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20338));
		int32_t L_13;
		L_13 = ConstrainedFuncInvoker1< int32_t, Il2CppFullySharedGenericStruct >::Invoke(il2cpp_rgctx_data(method->rgctx_data, 0), il2cpp_rgctx_method(method->rgctx_data, 3), L_12, (void*)((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_8, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_9), (int32_t)L_10)))), L_11);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20338));
		G_B4_0 = ((((int32_t)L_13) < ((int32_t)0))? 1 : 0);
		goto IL_0046;
	}

IL_0045:
	{
		G_B4_0 = 1;
	}

IL_0046:
	{
		V_5 = (bool)G_B4_0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20339));
		bool L_14 = V_5;
		if (!L_14)
		{
			goto IL_0065;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20340));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2364>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20341));
		Il2CppFullySharedGenericStruct* L_15 = ___0_dptr;
		int32_t L_16 = V_1;
		uint32_t L_17 = SizeOf_T_t7746E565CB09ADDE66D7FE8BA2706651748F4314;
		Il2CppFullySharedGenericStruct* L_18 = V_4;
		il2cpp_codegen_memcpy(L_19, L_18, SizeOf_T_t7746E565CB09ADDE66D7FE8BA2706651748F4314);
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericStruct*)((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_15, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_16), (int32_t)L_17)))), L_19, SizeOf_T_t7746E565CB09ADDE66D7FE8BA2706651748F4314);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 5), (void**)(Il2CppFullySharedGenericStruct*)((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_15, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_16), (int32_t)L_17)))), (void*)L_19);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20342));
	}

IL_0065:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20343));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2357>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20344));
		int32_t L_20 = V_1;
		V_1 = ((int32_t)il2cpp_codegen_add(L_20, 1));
	}

IL_006a:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2357>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20345));
		int32_t L_21 = V_1;
		int32_t L_22 = ___4_n;
		V_6 = (bool)((((int32_t)L_21) < ((int32_t)L_22))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20346));
		bool L_23 = V_6;
		if (L_23)
		{
			goto IL_000d;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2367>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20347));
		return;
	}
}
// Method Definition Index: 91955
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Avx2_EmulatedGather_TisIl2CppFullySharedGenericStruct_TisIl2CppFullySharedGenericStruct_m93179BB5AA8A484650210DDAA1EB8D4319DE5686_gshared (Il2CppFullySharedGenericStruct* ___0_dptr, void* ___1_base_addr, int64_t* ___2_indexPtr, int32_t ___3_scale, int32_t ___4_n, Il2CppFullySharedGenericStruct* ___5_mask, const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	const uint32_t SizeOf_U_t64249877289BCA4A66FB09171AC3649960014747 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 0));
	void* L_12 = alloca(Il2CppFakeBoxBuffer::SizeNeededFor(il2cpp_rgctx_data(method->rgctx_data, 0)));
	const uint32_t SizeOf_T_t2BE133648A5E32C27FC46CF83B739F6CD3C673A8 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 5));
	const Il2CppFullySharedGenericStruct L_19 = alloca(SizeOf_T_t2BE133648A5E32C27FC46CF83B739F6CD3C673A8);
	const Il2CppFullySharedGenericStruct L_11 = alloca(SizeOf_U_t64249877289BCA4A66FB09171AC3649960014747);
	Il2CppFullySharedGenericStruct V_0 = alloca(SizeOf_U_t64249877289BCA4A66FB09171AC3649960014747);
	memset(V_0, 0, SizeOf_U_t64249877289BCA4A66FB09171AC3649960014747);
	int32_t V_1 = 0;
	int64_t V_2 = 0;
	int64_t V_3 = 0;
	Il2CppFullySharedGenericStruct* V_4 = NULL;
	bool V_5 = false;
	bool V_6 = false;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_dptr), (&___1_base_addr), (&___2_indexPtr), (&___3_scale), (&___4_n), (&___5_mask));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, V_0, (&V_1), (&V_2), (&V_3), (&V_4));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20306));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 20307));
	int32_t G_B4_0 = 0;
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20308));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2339>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20309));
		il2cpp_codegen_initobj((Il2CppFullySharedGenericStruct*)V_0, SizeOf_U_t64249877289BCA4A66FB09171AC3649960014747);
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2341>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20310));
		V_1 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20311));
		goto IL_0069;
	}

IL_000d:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20312));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2343>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20313));
		int64_t* L_0 = ___2_indexPtr;
		int32_t L_1 = V_1;
		int64_t L_2 = (*(((int64_t*)il2cpp_codegen_add((intptr_t)L_0, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_1), 8))))));
		V_2 = L_2;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2344>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20314));
		int64_t L_3 = V_2;
		int32_t L_4 = ___3_scale;
		V_3 = ((int64_t)il2cpp_codegen_multiply(L_3, ((int64_t)L_4)));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2345>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20315));
		void* L_5 = ___1_base_addr;
		int64_t L_6 = V_3;
		V_4 = (Il2CppFullySharedGenericStruct*)((void*)il2cpp_codegen_add((intptr_t)L_5, ((intptr_t)L_6)));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2346>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20316));
		Il2CppFullySharedGenericStruct* L_7 = ___5_mask;
		if ((((intptr_t)L_7) == ((intptr_t)((uintptr_t)0))))
		{
			goto IL_0044;
		}
	}
	{
		Il2CppFullySharedGenericStruct* L_8 = ___5_mask;
		int32_t L_9 = V_1;
		uint32_t L_10 = SizeOf_U_t64249877289BCA4A66FB09171AC3649960014747;
		il2cpp_codegen_memcpy(L_11, V_0, SizeOf_U_t64249877289BCA4A66FB09171AC3649960014747);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20317));
		int32_t L_13;
		L_13 = ConstrainedFuncInvoker1< int32_t, Il2CppFullySharedGenericStruct >::Invoke(il2cpp_rgctx_data(method->rgctx_data, 0), il2cpp_rgctx_method(method->rgctx_data, 3), L_12, (void*)((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_8, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_9), (int32_t)L_10)))), L_11);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20317));
		G_B4_0 = ((((int32_t)L_13) < ((int32_t)0))? 1 : 0);
		goto IL_0045;
	}

IL_0044:
	{
		G_B4_0 = 1;
	}

IL_0045:
	{
		V_5 = (bool)G_B4_0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20318));
		bool L_14 = V_5;
		if (!L_14)
		{
			goto IL_0064;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20319));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2348>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20320));
		Il2CppFullySharedGenericStruct* L_15 = ___0_dptr;
		int32_t L_16 = V_1;
		uint32_t L_17 = SizeOf_T_t2BE133648A5E32C27FC46CF83B739F6CD3C673A8;
		Il2CppFullySharedGenericStruct* L_18 = V_4;
		il2cpp_codegen_memcpy(L_19, L_18, SizeOf_T_t2BE133648A5E32C27FC46CF83B739F6CD3C673A8);
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericStruct*)((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_15, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_16), (int32_t)L_17)))), L_19, SizeOf_T_t2BE133648A5E32C27FC46CF83B739F6CD3C673A8);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 5), (void**)(Il2CppFullySharedGenericStruct*)((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_15, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_16), (int32_t)L_17)))), (void*)L_19);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20321));
	}

IL_0064:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20322));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2341>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20323));
		int32_t L_20 = V_1;
		V_1 = ((int32_t)il2cpp_codegen_add(L_20, 1));
	}

IL_0069:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2341>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20324));
		int32_t L_21 = V_1;
		int32_t L_22 = ___4_n;
		V_6 = (bool)((((int32_t)L_21) < ((int32_t)L_22))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20325));
		bool L_23 = V_6;
		if (L_23)
		{
			goto IL_000d;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Avx2.cs:2351>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 20326));
		return;
	}
}
// Method Definition Index: 92430
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Sse4_2_ComputeStrCmpIntRes2_TisIl2CppFullySharedGenericStruct_m5BBC7FD25430C93A4DCF34A210DE56367BA1E204_gshared (Il2CppFullySharedGenericStruct* ___0_a, int32_t ___1_alen, Il2CppFullySharedGenericStruct* ___2_b, int32_t ___3_blen, int32_t ___4_len, int32_t ___5_imm8, int32_t ___6_allOnes, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&StrBoolArray_tCA66E1F688A4BC6FA749195F867F59E523508DD6_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	const uint32_t SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 1));
	const Il2CppFullySharedGenericStruct L_3 = alloca(SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
	const Il2CppFullySharedGenericStruct L_10 = L_3;
	const Il2CppFullySharedGenericStruct L_18 = L_3;
	const Il2CppFullySharedGenericStruct L_33 = L_3;
	const Il2CppFullySharedGenericStruct L_37 = L_3;
	const Il2CppFullySharedGenericStruct L_50 = L_3;
	const Il2CppFullySharedGenericStruct L_63 = L_3;
	const Il2CppFullySharedGenericStruct L_153 = L_3;
	const Il2CppFullySharedGenericStruct L_19 = alloca(SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
	const Il2CppFullySharedGenericStruct L_34 = L_19;
	const Il2CppFullySharedGenericStruct L_38 = L_19;
	const Il2CppFullySharedGenericStruct L_51 = L_19;
	const Il2CppFullySharedGenericStruct L_64 = L_19;
	const Il2CppFullySharedGenericStruct L_154 = L_19;
	bool V_0 = false;
	bool V_1 = false;
	StrBoolArray_tCA66E1F688A4BC6FA749195F867F59E523508DD6 V_2;
	memset((&V_2), 0, sizeof(V_2));
	int32_t V_3 = 0;
	int32_t V_4 = 0;
	int32_t V_5 = 0;
	int32_t V_6 = 0;
	Il2CppFullySharedGenericStruct V_7 = alloca(SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
	memset(V_7, 0, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
	bool V_8 = false;
	Il2CppFullySharedGenericStruct V_9 = alloca(SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
	memset(V_9, 0, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
	bool V_10 = false;
	bool V_11 = false;
	int32_t V_12 = 0;
	int32_t V_13 = 0;
	bool V_14 = false;
	bool V_15 = false;
	bool V_16 = false;
	bool V_17 = false;
	bool V_18 = false;
	bool V_19 = false;
	bool V_20 = false;
	bool V_21 = false;
	bool V_22 = false;
	bool V_23 = false;
	bool V_24 = false;
	bool V_25 = false;
	bool V_26 = false;
	bool V_27 = false;
	bool V_28 = false;
	int32_t V_29 = 0;
	int32_t V_30 = 0;
	bool V_31 = false;
	bool V_32 = false;
	bool V_33 = false;
	bool V_34 = false;
	bool V_35 = false;
	int32_t V_36 = 0;
	bool V_37 = false;
	bool V_38 = false;
	bool V_39 = false;
	bool V_40 = false;
	bool V_41 = false;
	bool V_42 = false;
	Il2CppFullySharedGenericStruct V_43 = alloca(SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
	memset(V_43, 0, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
	bool V_44 = false;
	bool V_45 = false;
	int32_t V_46 = 0;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_a), (&___1_alen), (&___2_b), (&___3_blen), (&___4_len), (&___5_imm8), (&___6_allOnes));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0), (&V_1), (&V_2), (&V_3), (&V_4), (&V_5), (&V_6), V_7, V_9, (&V_10), (&V_36));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25436));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 25437));
	int32_t G_B13_0 = 0;
	int32_t G_B26_0 = 0;
	int32_t G_B36_0 = 0;
	int32_t G_B46_0 = 0;
	int32_t G_B61_0 = 0;
	int32_t G_B60_0 = 0;
	int32_t G_B62_0 = 0;
	int32_t G_B62_1 = 0;
	int32_t G_B71_0 = 0;
	int32_t G_B70_0 = 0;
	int32_t G_B72_0 = 0;
	int32_t G_B73_0 = 0;
	int32_t G_B73_1 = 0;
	int32_t G_B81_0 = 0;
	int32_t G_B80_0 = 0;
	int32_t G_B82_0 = 0;
	int32_t G_B82_1 = 0;
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25438));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:223>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25439));
		V_0 = (bool)0;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:224>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25440));
		V_1 = (bool)0;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:225>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25441));
		il2cpp_codegen_initobj((&V_2), sizeof(StrBoolArray_tCA66E1F688A4BC6FA749195F867F59E523508DD6));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:228>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25442));
		V_3 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25443));
		goto IL_01ea;
	}

IL_0014:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25444));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:230>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25445));
		Il2CppFullySharedGenericStruct* L_0 = ___0_a;
		int32_t L_1 = V_3;
		uint32_t L_2 = SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77;
		il2cpp_codegen_memcpy(L_3, ((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_0, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_1), (int32_t)L_2)))), SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_memcpy(V_7, L_3, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:232>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25446));
		int32_t L_4 = V_3;
		int32_t L_5 = ___1_alen;
		V_8 = (bool)((((int32_t)L_4) == ((int32_t)L_5))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25447));
		bool L_6 = V_8;
		if (!L_6)
		{
			goto IL_0033;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:233>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25448));
		V_0 = (bool)1;
	}

IL_0033:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:235>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25449));
		V_1 = (bool)0;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:236>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25450));
		V_4 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25451));
		goto IL_01d6;
	}

IL_003d:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25452));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:238>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25453));
		Il2CppFullySharedGenericStruct* L_7 = ___2_b;
		int32_t L_8 = V_4;
		uint32_t L_9 = SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77;
		il2cpp_codegen_memcpy(L_10, ((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_7, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_8), (int32_t)L_9)))), SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_memcpy(V_9, L_10, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:239>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25454));
		int32_t L_11 = V_4;
		int32_t L_12 = ___3_blen;
		V_11 = (bool)((((int32_t)L_11) == ((int32_t)L_12))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25455));
		bool L_13 = V_11;
		if (!L_13)
		{
			goto IL_005e;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:240>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25456));
		V_1 = (bool)1;
	}

IL_005e:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:245>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25457));
		int32_t L_14 = ___5_imm8;
		V_13 = ((int32_t)(((int32_t)(L_14>>2))&3));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25458));
		int32_t L_15 = V_13;
		V_12 = L_15;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25459));
		int32_t L_16 = V_12;
		switch (L_16)
		{
			case 0:
			{
				goto IL_0082;
			}
			case 1:
			{
				goto IL_00c9;
			}
			case 2:
			{
				goto IL_013a;
			}
		}
	}
	{
		goto IL_017e;
	}

IL_0082:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:248>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25460));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25461));
		EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9* L_17;
		L_17 = EqualityComparer_1_get_Default_m20747610B059ED2853BC1F878FC39851A47F5F2D_inline(il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25461));
		il2cpp_codegen_memcpy(L_18, V_7, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_memcpy(L_19, V_9, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25462));
		NullCheck(L_17);
		bool L_20;
		L_20 = VirtualFuncInvoker2Invoker< bool, Il2CppFullySharedGenericStruct, Il2CppFullySharedGenericStruct >::Invoke(8, L_17, L_18, L_19);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25462));
		V_10 = L_20;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:249>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25463));
		bool L_21 = V_0;
		bool L_22 = V_1;
		V_14 = (bool)((int32_t)(((((int32_t)L_21) == ((int32_t)0))? 1 : 0)&(int32_t)L_22));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25464));
		bool L_23 = V_14;
		if (!L_23)
		{
			goto IL_00a3;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:250>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25465));
		V_10 = (bool)0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25466));
		goto IL_00c4;
	}

IL_00a3:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:251>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25467));
		bool L_24 = V_0;
		if (!L_24)
		{
			goto IL_00ac;
		}
	}
	{
		bool L_25 = V_1;
		G_B13_0 = ((((int32_t)L_25) == ((int32_t)0))? 1 : 0);
		goto IL_00ad;
	}

IL_00ac:
	{
		G_B13_0 = 0;
	}

IL_00ad:
	{
		V_15 = (bool)G_B13_0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25468));
		bool L_26 = V_15;
		if (!L_26)
		{
			goto IL_00b8;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:252>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25469));
		V_10 = (bool)0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25470));
		goto IL_00c4;
	}

IL_00b8:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:253>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25471));
		bool L_27 = V_0;
		bool L_28 = V_1;
		V_16 = (bool)((int32_t)((int32_t)L_27&(int32_t)L_28));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25472));
		bool L_29 = V_16;
		if (!L_29)
		{
			goto IL_00c4;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:254>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25473));
		V_10 = (bool)0;
	}

IL_00c4:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:255>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25474));
		goto IL_01c2;
	}

IL_00c9:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:258>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25475));
		int32_t L_30 = V_3;
		V_17 = (bool)((((int32_t)((int32_t)(L_30&1))) == ((int32_t)0))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25476));
		bool L_31 = V_17;
		if (!L_31)
		{
			goto IL_00ed;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:259>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25477));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25478));
		Comparer_1_t535E02B3998AA8B49230077EF0DFCB16BA44C985* L_32;
		L_32 = Comparer_1_get_Default_m9BA7A3EA0D33B540EFC408B0C9C2B69F7A0C9E76(il2cpp_rgctx_method(method->rgctx_data, 6));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25478));
		il2cpp_codegen_memcpy(L_33, V_9, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_memcpy(L_34, V_7, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25479));
		NullCheck(L_32);
		int32_t L_35;
		L_35 = VirtualFuncInvoker2Invoker< int32_t, Il2CppFullySharedGenericStruct, Il2CppFullySharedGenericStruct >::Invoke(6, L_32, L_33, L_34);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25479));
		V_10 = (bool)((((int32_t)((((int32_t)L_35) < ((int32_t)0))? 1 : 0)) == ((int32_t)0))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25480));
		goto IL_0103;
	}

IL_00ed:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:261>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25481));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25482));
		Comparer_1_t535E02B3998AA8B49230077EF0DFCB16BA44C985* L_36;
		L_36 = Comparer_1_get_Default_m9BA7A3EA0D33B540EFC408B0C9C2B69F7A0C9E76(il2cpp_rgctx_method(method->rgctx_data, 6));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25482));
		il2cpp_codegen_memcpy(L_37, V_9, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_memcpy(L_38, V_7, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25483));
		NullCheck(L_36);
		int32_t L_39;
		L_39 = VirtualFuncInvoker2Invoker< int32_t, Il2CppFullySharedGenericStruct, Il2CppFullySharedGenericStruct >::Invoke(6, L_36, L_37, L_38);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25483));
		V_10 = (bool)((((int32_t)((((int32_t)L_39) > ((int32_t)0))? 1 : 0)) == ((int32_t)0))? 1 : 0);
	}

IL_0103:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:263>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25484));
		bool L_40 = V_0;
		bool L_41 = V_1;
		V_18 = (bool)((int32_t)(((((int32_t)L_40) == ((int32_t)0))? 1 : 0)&(int32_t)L_41));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25485));
		bool L_42 = V_18;
		if (!L_42)
		{
			goto IL_0114;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:264>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25486));
		V_10 = (bool)0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25487));
		goto IL_0135;
	}

IL_0114:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:265>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25488));
		bool L_43 = V_0;
		if (!L_43)
		{
			goto IL_011d;
		}
	}
	{
		bool L_44 = V_1;
		G_B26_0 = ((((int32_t)L_44) == ((int32_t)0))? 1 : 0);
		goto IL_011e;
	}

IL_011d:
	{
		G_B26_0 = 0;
	}

IL_011e:
	{
		V_19 = (bool)G_B26_0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25489));
		bool L_45 = V_19;
		if (!L_45)
		{
			goto IL_0129;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:266>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25490));
		V_10 = (bool)0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25491));
		goto IL_0135;
	}

IL_0129:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:267>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25492));
		bool L_46 = V_0;
		bool L_47 = V_1;
		V_20 = (bool)((int32_t)((int32_t)L_46&(int32_t)L_47));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25493));
		bool L_48 = V_20;
		if (!L_48)
		{
			goto IL_0135;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:268>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25494));
		V_10 = (bool)0;
	}

IL_0135:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:269>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25495));
		goto IL_01c2;
	}

IL_013a:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:271>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25496));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25497));
		EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9* L_49;
		L_49 = EqualityComparer_1_get_Default_m20747610B059ED2853BC1F878FC39851A47F5F2D_inline(il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25497));
		il2cpp_codegen_memcpy(L_50, V_7, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_memcpy(L_51, V_9, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25498));
		NullCheck(L_49);
		bool L_52;
		L_52 = VirtualFuncInvoker2Invoker< bool, Il2CppFullySharedGenericStruct, Il2CppFullySharedGenericStruct >::Invoke(8, L_49, L_50, L_51);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25498));
		V_10 = L_52;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:272>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25499));
		bool L_53 = V_0;
		bool L_54 = V_1;
		V_21 = (bool)((int32_t)(((((int32_t)L_53) == ((int32_t)0))? 1 : 0)&(int32_t)L_54));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25500));
		bool L_55 = V_21;
		if (!L_55)
		{
			goto IL_015b;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:273>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25501));
		V_10 = (bool)0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25502));
		goto IL_017c;
	}

IL_015b:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:274>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25503));
		bool L_56 = V_0;
		if (!L_56)
		{
			goto IL_0164;
		}
	}
	{
		bool L_57 = V_1;
		G_B36_0 = ((((int32_t)L_57) == ((int32_t)0))? 1 : 0);
		goto IL_0165;
	}

IL_0164:
	{
		G_B36_0 = 0;
	}

IL_0165:
	{
		V_22 = (bool)G_B36_0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25504));
		bool L_58 = V_22;
		if (!L_58)
		{
			goto IL_0170;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:275>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25505));
		V_10 = (bool)0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25506));
		goto IL_017c;
	}

IL_0170:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:276>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25507));
		bool L_59 = V_0;
		bool L_60 = V_1;
		V_23 = (bool)((int32_t)((int32_t)L_59&(int32_t)L_60));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25508));
		bool L_61 = V_23;
		if (!L_61)
		{
			goto IL_017c;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:277>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25509));
		V_10 = (bool)1;
	}

IL_017c:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:278>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25510));
		goto IL_01c2;
	}

IL_017e:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:280>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25511));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25512));
		EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9* L_62;
		L_62 = EqualityComparer_1_get_Default_m20747610B059ED2853BC1F878FC39851A47F5F2D_inline(il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25512));
		il2cpp_codegen_memcpy(L_63, V_7, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_memcpy(L_64, V_9, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25513));
		NullCheck(L_62);
		bool L_65;
		L_65 = VirtualFuncInvoker2Invoker< bool, Il2CppFullySharedGenericStruct, Il2CppFullySharedGenericStruct >::Invoke(8, L_62, L_63, L_64);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25513));
		V_10 = L_65;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:281>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25514));
		bool L_66 = V_0;
		bool L_67 = V_1;
		V_24 = (bool)((int32_t)(((((int32_t)L_66) == ((int32_t)0))? 1 : 0)&(int32_t)L_67));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25515));
		bool L_68 = V_24;
		if (!L_68)
		{
			goto IL_019f;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:282>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25516));
		V_10 = (bool)0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25517));
		goto IL_01c0;
	}

IL_019f:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:283>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25518));
		bool L_69 = V_0;
		if (!L_69)
		{
			goto IL_01a8;
		}
	}
	{
		bool L_70 = V_1;
		G_B46_0 = ((((int32_t)L_70) == ((int32_t)0))? 1 : 0);
		goto IL_01a9;
	}

IL_01a8:
	{
		G_B46_0 = 0;
	}

IL_01a9:
	{
		V_25 = (bool)G_B46_0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25519));
		bool L_71 = V_25;
		if (!L_71)
		{
			goto IL_01b4;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:284>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25520));
		V_10 = (bool)1;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25521));
		goto IL_01c0;
	}

IL_01b4:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:285>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25522));
		bool L_72 = V_0;
		bool L_73 = V_1;
		V_26 = (bool)((int32_t)((int32_t)L_72&(int32_t)L_73));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25523));
		bool L_74 = V_26;
		if (!L_74)
		{
			goto IL_01c0;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:286>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25524));
		V_10 = (bool)1;
	}

IL_01c0:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:287>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25525));
		goto IL_01c2;
	}

IL_01c2:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:290>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25526));
		int32_t L_75 = V_3;
		int32_t L_76 = V_4;
		bool L_77 = V_10;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25527));
		StrBoolArray_SetBit_m212C6D1A8A4C422AF979D6B3BC7CD5B9BD0F3F01((&V_2), L_75, L_76, L_77, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25527));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25528));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:236>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25529));
		int32_t L_78 = V_4;
		V_4 = ((int32_t)il2cpp_codegen_add(L_78, 1));
	}

IL_01d6:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:236>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25530));
		int32_t L_79 = V_4;
		int32_t L_80 = ___4_len;
		V_27 = (bool)((((int32_t)L_79) < ((int32_t)L_80))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25531));
		bool L_81 = V_27;
		if (L_81)
		{
			goto IL_003d;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25532));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:228>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25533));
		int32_t L_82 = V_3;
		V_3 = ((int32_t)il2cpp_codegen_add(L_82, 1));
	}

IL_01ea:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:228>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25534));
		int32_t L_83 = V_3;
		int32_t L_84 = ___4_len;
		V_28 = (bool)((((int32_t)L_83) < ((int32_t)L_84))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25535));
		bool L_85 = V_28;
		if (L_85)
		{
			goto IL_0014;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:294>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25536));
		V_6 = 0;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:297>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25537));
		int32_t L_86 = ___5_imm8;
		V_30 = ((int32_t)(((int32_t)(L_86>>2))&3));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25538));
		int32_t L_87 = V_30;
		V_29 = L_87;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25539));
		int32_t L_88 = V_29;
		switch (L_88)
		{
			case 0:
			{
				goto IL_0223;
			}
			case 1:
			{
				goto IL_0270;
			}
			case 2:
			{
				goto IL_02cb;
			}
			case 3:
			{
				goto IL_02fb;
			}
		}
	}
	{
		goto IL_035a;
	}

IL_0223:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:300>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25540));
		V_3 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25541));
		goto IL_0260;
	}

IL_0227:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25542));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:302>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25543));
		V_4 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25544));
		goto IL_024f;
	}

IL_022d:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25545));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:304>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25546));
		int32_t L_89 = V_6;
		int32_t L_90 = V_4;
		int32_t L_91 = V_3;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25547));
		bool L_92;
		L_92 = StrBoolArray_GetBit_mCA50A9F3A3FA5C552305C9B762264A6058F33E78((&V_2), L_90, L_91, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25547));
		if (L_92)
		{
			G_B61_0 = L_89;
			goto IL_023f;
		}
		G_B60_0 = L_89;
	}
	{
		G_B62_0 = 0;
		G_B62_1 = G_B60_0;
		goto IL_0240;
	}

IL_023f:
	{
		G_B62_0 = 1;
		G_B62_1 = G_B61_0;
	}

IL_0240:
	{
		int32_t L_93 = V_3;
		V_6 = ((int32_t)(G_B62_1|((int32_t)(G_B62_0<<((int32_t)(L_93&((int32_t)31)))))));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25548));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:302>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25549));
		int32_t L_94 = V_4;
		V_4 = ((int32_t)il2cpp_codegen_add(L_94, 1));
	}

IL_024f:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:302>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25550));
		int32_t L_95 = V_4;
		int32_t L_96 = ___4_len;
		V_31 = (bool)((((int32_t)L_95) < ((int32_t)L_96))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25551));
		bool L_97 = V_31;
		if (L_97)
		{
			goto IL_022d;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25552));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:300>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25553));
		int32_t L_98 = V_3;
		V_3 = ((int32_t)il2cpp_codegen_add(L_98, 1));
	}

IL_0260:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:300>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25554));
		int32_t L_99 = V_3;
		int32_t L_100 = ___4_len;
		V_32 = (bool)((((int32_t)L_99) < ((int32_t)L_100))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25555));
		bool L_101 = V_32;
		if (L_101)
		{
			goto IL_0227;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:312>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25556));
		goto IL_035a;
	}

IL_0270:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:314>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25557));
		V_3 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25558));
		goto IL_02bb;
	}

IL_0274:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25559));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:316>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25560));
		V_4 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25561));
		goto IL_02aa;
	}

IL_027a:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25562));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:318>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25563));
		int32_t L_102 = V_6;
		int32_t L_103 = V_4;
		int32_t L_104 = V_3;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25564));
		bool L_105;
		L_105 = StrBoolArray_GetBit_mCA50A9F3A3FA5C552305C9B762264A6058F33E78((&V_2), L_103, L_104, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25564));
		if (!L_105)
		{
			G_B71_0 = L_102;
			goto IL_0297;
		}
		G_B70_0 = L_102;
	}
	{
		int32_t L_106 = V_4;
		int32_t L_107 = V_3;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25565));
		bool L_108;
		L_108 = StrBoolArray_GetBit_mCA50A9F3A3FA5C552305C9B762264A6058F33E78((&V_2), ((int32_t)il2cpp_codegen_add(L_106, 1)), L_107, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25565));
		if (L_108)
		{
			G_B72_0 = G_B70_0;
			goto IL_029a;
		}
		G_B71_0 = G_B70_0;
	}

IL_0297:
	{
		G_B73_0 = 0;
		G_B73_1 = G_B71_0;
		goto IL_029b;
	}

IL_029a:
	{
		G_B73_0 = 1;
		G_B73_1 = G_B72_0;
	}

IL_029b:
	{
		int32_t L_109 = V_3;
		V_6 = ((int32_t)(G_B73_1|((int32_t)(G_B73_0<<((int32_t)(L_109&((int32_t)31)))))));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25566));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:316>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25567));
		int32_t L_110 = V_4;
		V_4 = ((int32_t)il2cpp_codegen_add(L_110, 2));
	}

IL_02aa:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:316>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25568));
		int32_t L_111 = V_4;
		int32_t L_112 = ___4_len;
		V_33 = (bool)((((int32_t)L_111) < ((int32_t)L_112))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25569));
		bool L_113 = V_33;
		if (L_113)
		{
			goto IL_027a;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25570));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:314>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25571));
		int32_t L_114 = V_3;
		V_3 = ((int32_t)il2cpp_codegen_add(L_114, 1));
	}

IL_02bb:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:314>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25572));
		int32_t L_115 = V_3;
		int32_t L_116 = ___4_len;
		V_34 = (bool)((((int32_t)L_115) < ((int32_t)L_116))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25573));
		bool L_117 = V_34;
		if (L_117)
		{
			goto IL_0274;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:321>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25574));
		goto IL_035a;
	}

IL_02cb:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:323>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25575));
		V_3 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25576));
		goto IL_02ee;
	}

IL_02cf:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25577));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:325>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25578));
		int32_t L_118 = V_6;
		int32_t L_119 = V_3;
		int32_t L_120 = V_3;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25579));
		bool L_121;
		L_121 = StrBoolArray_GetBit_mCA50A9F3A3FA5C552305C9B762264A6058F33E78((&V_2), L_119, L_120, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25579));
		if (L_121)
		{
			G_B81_0 = L_118;
			goto IL_02e0;
		}
		G_B80_0 = L_118;
	}
	{
		G_B82_0 = 0;
		G_B82_1 = G_B80_0;
		goto IL_02e1;
	}

IL_02e0:
	{
		G_B82_0 = 1;
		G_B82_1 = G_B81_0;
	}

IL_02e1:
	{
		int32_t L_122 = V_3;
		V_6 = ((int32_t)(G_B82_1|((int32_t)(G_B82_0<<((int32_t)(L_122&((int32_t)31)))))));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25580));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:323>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25581));
		int32_t L_123 = V_3;
		V_3 = ((int32_t)il2cpp_codegen_add(L_123, 1));
	}

IL_02ee:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:323>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25582));
		int32_t L_124 = V_3;
		int32_t L_125 = ___4_len;
		V_35 = (bool)((((int32_t)L_124) < ((int32_t)L_125))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25583));
		bool L_126 = V_35;
		if (L_126)
		{
			goto IL_02cf;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:327>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25584));
		goto IL_035a;
	}

IL_02fb:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:329>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25585));
		int32_t L_127 = ___6_allOnes;
		V_6 = L_127;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:330>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25586));
		V_3 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25587));
		goto IL_034d;
	}

IL_0303:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25588));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:332>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25589));
		int32_t L_128 = V_3;
		V_36 = L_128;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:333>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25590));
		V_4 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25591));
		goto IL_033a;
	}

IL_030c:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25592));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:335>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25593));
		int32_t L_129 = V_4;
		int32_t L_130 = V_36;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25594));
		bool L_131;
		L_131 = StrBoolArray_GetBit_mCA50A9F3A3FA5C552305C9B762264A6058F33E78((&V_2), L_129, L_130, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25594));
		V_37 = (bool)((((int32_t)L_131) == ((int32_t)0))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25595));
		bool L_132 = V_37;
		if (!L_132)
		{
			goto IL_032d;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:336>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25596));
		int32_t L_133 = V_6;
		int32_t L_134 = V_3;
		V_6 = ((int32_t)(L_133&((~((int32_t)(1<<((int32_t)(L_134&((int32_t)31)))))))));
	}

IL_032d:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:337>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25597));
		int32_t L_135 = V_36;
		V_36 = ((int32_t)il2cpp_codegen_add(L_135, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25598));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:333>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25599));
		int32_t L_136 = V_4;
		V_4 = ((int32_t)il2cpp_codegen_add(L_136, 1));
	}

IL_033a:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:333>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25600));
		int32_t L_137 = V_4;
		int32_t L_138 = ___4_len;
		int32_t L_139 = V_3;
		V_38 = (bool)((((int32_t)L_137) < ((int32_t)((int32_t)il2cpp_codegen_subtract(L_138, L_139))))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25601));
		bool L_140 = V_38;
		if (L_140)
		{
			goto IL_030c;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25602));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:330>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25603));
		int32_t L_141 = V_3;
		V_3 = ((int32_t)il2cpp_codegen_add(L_141, 1));
	}

IL_034d:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:330>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25604));
		int32_t L_142 = V_3;
		int32_t L_143 = ___4_len;
		V_39 = (bool)((((int32_t)L_142) < ((int32_t)L_143))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25605));
		bool L_144 = V_39;
		if (L_144)
		{
			goto IL_0303;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:340>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25606));
		goto IL_035a;
	}

IL_035a:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:343>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25607));
		V_5 = 0;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:346>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25608));
		V_1 = (bool)0;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:347>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25609));
		V_3 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25610));
		goto IL_0401;
	}

IL_0366:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25611));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:349>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25612));
		int32_t L_145 = ___5_imm8;
		V_40 = (bool)((!(((uint32_t)((int32_t)(L_145&((int32_t)16)))) <= ((uint32_t)0)))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25613));
		bool L_146 = V_40;
		if (!L_146)
		{
			goto IL_03ee;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25614));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:351>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25615));
		int32_t L_147 = ___5_imm8;
		V_41 = (bool)((!(((uint32_t)((int32_t)(L_147&((int32_t)32)))) <= ((uint32_t)0)))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25616));
		bool L_148 = V_41;
		if (!L_148)
		{
			goto IL_03dc;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25617));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:353>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25618));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25619));
		EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9* L_149;
		L_149 = EqualityComparer_1_get_Default_m20747610B059ED2853BC1F878FC39851A47F5F2D_inline(il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25619));
		Il2CppFullySharedGenericStruct* L_150 = ___2_b;
		int32_t L_151 = V_3;
		uint32_t L_152 = SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77;
		il2cpp_codegen_memcpy(L_153, ((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_150, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_151), (int32_t)L_152)))), SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_initobj((Il2CppFullySharedGenericStruct*)V_43, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		il2cpp_codegen_memcpy(L_154, V_43, SizeOf_T_t7F8E2A189F579B2C727588D60559F5E6306C2E77);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25620));
		NullCheck(L_149);
		bool L_155;
		L_155 = VirtualFuncInvoker2Invoker< bool, Il2CppFullySharedGenericStruct, Il2CppFullySharedGenericStruct >::Invoke(8, L_149, L_153, L_154);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25620));
		V_42 = L_155;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25621));
		bool L_156 = V_42;
		if (!L_156)
		{
			goto IL_03b3;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25622));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:355>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25623));
		V_1 = (bool)1;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25624));
	}

IL_03b3:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:358>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25625));
		bool L_157 = V_1;
		V_44 = L_157;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25626));
		bool L_158 = V_44;
		if (!L_158)
		{
			goto IL_03ca;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:359>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25627));
		int32_t L_159 = V_5;
		int32_t L_160 = V_6;
		int32_t L_161 = V_3;
		V_5 = ((int32_t)(L_159|((int32_t)(L_160&((int32_t)(1<<((int32_t)(L_161&((int32_t)31)))))))));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25628));
		goto IL_03d9;
	}

IL_03ca:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:361>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25629));
		int32_t L_162 = V_5;
		int32_t L_163 = V_6;
		int32_t L_164 = V_3;
		V_5 = ((int32_t)(L_162|((int32_t)(((~L_163))&((int32_t)(1<<((int32_t)(L_164&((int32_t)31)))))))));
	}

IL_03d9:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25630));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25631));
		goto IL_03eb;
	}

IL_03dc:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:364>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25632));
		int32_t L_165 = V_5;
		int32_t L_166 = V_6;
		int32_t L_167 = V_3;
		V_5 = ((int32_t)(L_165|((int32_t)(((~L_166))&((int32_t)(1<<((int32_t)(L_167&((int32_t)31)))))))));
	}

IL_03eb:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25633));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25634));
		goto IL_03fc;
	}

IL_03ee:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:367>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25635));
		int32_t L_168 = V_5;
		int32_t L_169 = V_6;
		int32_t L_170 = V_3;
		V_5 = ((int32_t)(L_168|((int32_t)(L_169&((int32_t)(1<<((int32_t)(L_170&((int32_t)31)))))))));
	}

IL_03fc:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25636));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:347>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25637));
		int32_t L_171 = V_3;
		V_3 = ((int32_t)il2cpp_codegen_add(L_171, 1));
	}

IL_0401:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:347>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25638));
		int32_t L_172 = V_3;
		int32_t L_173 = ___4_len;
		V_45 = (bool)((((int32_t)L_172) < ((int32_t)L_173))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25639));
		bool L_174 = V_45;
		if (L_174)
		{
			goto IL_0366;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:370>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25640));
		int32_t L_175 = V_5;
		V_46 = L_175;
		goto IL_0415;
	}

IL_0415:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:374>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25641));
		int32_t L_176 = V_46;
		return L_176;
	}
}
// Method Definition Index: 92429
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Sse4_2_ComputeStringLength_TisIl2CppFullySharedGenericStruct_m764CDB4D47CB1C77EAA40D60D44F53C4E97CD8D6_gshared (Il2CppFullySharedGenericStruct* ___0_ptr, int32_t ___1_max, const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	const uint32_t SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 4));
	const Il2CppFullySharedGenericStruct L_4 = alloca(SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64);
	const Il2CppFullySharedGenericStruct L_5 = alloca(SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64);
	int32_t V_0 = 0;
	bool V_1 = false;
	Il2CppFullySharedGenericStruct V_2 = alloca(SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64);
	memset(V_2, 0, SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64);
	int32_t V_3 = 0;
	bool V_4 = false;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_ptr), (&___1_max));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25418));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 25419));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25420));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:210>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25421));
		V_0 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25422));
		goto IL_0037;
	}

IL_0005:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25423));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:212>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25424));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25425));
		EqualityComparer_1_t458C8DC3748A89A213F4738B57D3742C4896ABE9* L_0;
		L_0 = EqualityComparer_1_get_Default_m20747610B059ED2853BC1F878FC39851A47F5F2D_inline(il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25425));
		Il2CppFullySharedGenericStruct* L_1 = ___0_ptr;
		int32_t L_2 = V_0;
		uint32_t L_3 = SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64;
		il2cpp_codegen_memcpy(L_4, ((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_1, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_2), (int32_t)L_3)))), SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64);
		il2cpp_codegen_initobj((Il2CppFullySharedGenericStruct*)V_2, SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64);
		il2cpp_codegen_memcpy(L_5, V_2, SizeOf_T_t2125B686AA2A4D4755B95692CBE3C48B69824C64);
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25426));
		NullCheck(L_0);
		bool L_6;
		L_6 = VirtualFuncInvoker2Invoker< bool, Il2CppFullySharedGenericStruct, Il2CppFullySharedGenericStruct >::Invoke(8, L_0, L_4, L_5);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25426));
		V_1 = L_6;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25427));
		bool L_7 = V_1;
		if (!L_7)
		{
			goto IL_0032;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25428));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:214>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25429));
		int32_t L_8 = V_0;
		V_3 = L_8;
		goto IL_0045;
	}

IL_0032:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25430));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:210>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25431));
		int32_t L_9 = V_0;
		V_0 = ((int32_t)il2cpp_codegen_add(L_9, 1));
	}

IL_0037:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:210>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25432));
		int32_t L_10 = V_0;
		int32_t L_11 = ___1_max;
		V_4 = (bool)((((int32_t)L_10) < ((int32_t)L_11))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25433));
		bool L_12 = V_4;
		if (L_12)
		{
			goto IL_0005;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:217>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25434));
		int32_t L_13 = ___1_max;
		V_3 = L_13;
		goto IL_0045;
	}

IL_0045:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:218>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25435));
		int32_t L_14 = V_3;
		return L_14;
	}
}
// Method Definition Index: 92425
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 Sse4_2_ComputeStrmOutput_TisIl2CppFullySharedGenericStruct_m64ADE71FB4B90FEC60799387186E249935DE041C_gshared (int32_t ___0_len, int32_t ___1_imm8, Il2CppFullySharedGenericStruct ___2_allOnesT, int32_t ___3_intRes2, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	const uint32_t SizeOf_T_t4AB7E7218B07206B6D97D6E91CAC0F37510C246B = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 0));
	const Il2CppFullySharedGenericStruct L_9 = alloca(SizeOf_T_t4AB7E7218B07206B6D97D6E91CAC0F37510C246B);
	v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 V_0;
	memset((&V_0), 0, sizeof(V_0));
	bool V_1 = false;
	Il2CppFullySharedGenericStruct* V_2 = NULL;
	int32_t V_3 = 0;
	bool V_4 = false;
	bool V_5 = false;
	v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 V_6;
	memset((&V_6), 0, sizeof(V_6));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_len), (&___1_imm8), (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->rgctx_data, 0)) ? ___2_allOnesT : &___2_allOnesT), (&___3_intRes2));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0), (&V_2), (&V_3));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25337));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 25338));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25339));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:141>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25340));
		il2cpp_codegen_initobj((&V_0), sizeof(v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:142>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25341));
		int32_t L_0 = ___1_imm8;
		V_1 = (bool)((!(((uint32_t)((int32_t)(L_0&((int32_t)64)))) <= ((uint32_t)0)))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25342));
		bool L_1 = V_1;
		if (!L_1)
		{
			goto IL_006e;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25343));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:145>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25344));
		uint8_t* L_2 = (uint8_t*)(&(&V_0)->___Byte0);
		V_2 = (Il2CppFullySharedGenericStruct*)((uintptr_t)L_2);
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:146>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25345));
		V_3 = 0;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25346));
		goto IL_0061;
	}

IL_0022:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25347));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:148>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25348));
		int32_t L_3 = ___3_intRes2;
		int32_t L_4 = V_3;
		V_4 = (bool)((!(((uint32_t)((int32_t)(L_3&((int32_t)(1<<((int32_t)(L_4&((int32_t)31)))))))) <= ((uint32_t)0)))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25349));
		bool L_5 = V_4;
		if (!L_5)
		{
			goto IL_0049;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25350));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:150>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25351));
		Il2CppFullySharedGenericStruct* L_6 = V_2;
		int32_t L_7 = V_3;
		uint32_t L_8 = SizeOf_T_t4AB7E7218B07206B6D97D6E91CAC0F37510C246B;
		il2cpp_codegen_memcpy(L_9, ___2_allOnesT, SizeOf_T_t4AB7E7218B07206B6D97D6E91CAC0F37510C246B);
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericStruct*)((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_6, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_7), (int32_t)L_8)))), L_9, SizeOf_T_t4AB7E7218B07206B6D97D6E91CAC0F37510C246B);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->rgctx_data, 0), (void**)(Il2CppFullySharedGenericStruct*)((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_6, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_7), (int32_t)L_8)))), (void*)L_9);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25352));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25353));
		goto IL_005c;
	}

IL_0049:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25354));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:154>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25355));
		Il2CppFullySharedGenericStruct* L_10 = V_2;
		int32_t L_11 = V_3;
		uint32_t L_12 = SizeOf_T_t4AB7E7218B07206B6D97D6E91CAC0F37510C246B;
		il2cpp_codegen_initobj(((Il2CppFullySharedGenericStruct*)il2cpp_codegen_add((intptr_t)L_10, ((intptr_t)il2cpp_codegen_multiply(((intptr_t)L_11), (int32_t)L_12)))), SizeOf_T_t4AB7E7218B07206B6D97D6E91CAC0F37510C246B);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25356));
	}

IL_005c:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25357));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:146>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25358));
		int32_t L_13 = V_3;
		V_3 = ((int32_t)il2cpp_codegen_add(L_13, 1));
	}

IL_0061:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:146>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25359));
		int32_t L_14 = V_3;
		int32_t L_15 = ___0_len;
		V_5 = (bool)((((int32_t)L_14) < ((int32_t)L_15))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25360));
		bool L_16 = V_5;
		if (L_16)
		{
			goto IL_0022;
		}
	}
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25361));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25362));
		goto IL_0078;
	}

IL_006e:
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25363));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:161>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25364));
		int32_t L_17 = ___3_intRes2;
		(&V_0)->___SInt0 = L_17;
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25365));
	}

IL_0078:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:164>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25366));
		v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 L_18 = V_0;
		V_6 = L_18;
		goto IL_007d;
	}

IL_007d:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:165>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25367));
		v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 L_19 = V_6;
		return L_19;
	}
}
// Method Definition Index: 92427
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Sse4_2_cmpestri_emulation_TisIl2CppFullySharedGenericStruct_m92A1CC07F00E8D1EFF164A7AAA2CEF3A90BC8071_gshared (Il2CppFullySharedGenericStruct* ___0_a, int32_t ___1_alen, Il2CppFullySharedGenericStruct* ___2_b, int32_t ___3_blen, int32_t ___4_len, int32_t ___5_imm8, int32_t ___6_allOnes, Il2CppFullySharedGenericStruct ___7_allOnesT, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var);
		il2cpp_rgctx_method_init(method);
	}
	int32_t V_0 = 0;
	int32_t V_1 = 0;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_a), (&___1_alen), (&___2_b), (&___3_blen), (&___4_len), (&___5_imm8), (&___6_allOnes), (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->rgctx_data, 2)) ? ___7_allOnesT : &___7_allOnesT));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25378));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 25379));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25380));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:176>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25381));
		Il2CppFullySharedGenericStruct* L_0 = ___0_a;
		int32_t L_1 = ___1_alen;
		Il2CppFullySharedGenericStruct* L_2 = ___2_b;
		int32_t L_3 = ___3_blen;
		int32_t L_4 = ___4_len;
		int32_t L_5 = ___5_imm8;
		int32_t L_6 = ___6_allOnes;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25382));
		il2cpp_codegen_runtime_class_init_inline(Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var);
		int32_t L_7;
		L_7 = Sse4_2_ComputeStrCmpIntRes2_TisIl2CppFullySharedGenericStruct_m5BBC7FD25430C93A4DCF34A210DE56367BA1E204(L_0, L_1, L_2, L_3, L_4, L_5, L_6, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25382));
		V_0 = L_7;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:178>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25383));
		int32_t L_8 = ___4_len;
		int32_t L_9 = ___5_imm8;
		int32_t L_10 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25384));
		int32_t L_11;
		L_11 = Sse4_2_ComputeStriOutput_mC9EFEB2A2B9B95760CEE913DF4EF7F57BE662123(L_8, L_9, L_10, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25384));
		V_1 = L_11;
		goto IL_001e;
	}

IL_001e:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:179>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25385));
		int32_t L_12 = V_1;
		return L_12;
	}
}
// Method Definition Index: 92424
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 Sse4_2_cmpestrm_emulation_TisIl2CppFullySharedGenericStruct_m81548202F0BF107992042F154D34BCB0C7366524_gshared (Il2CppFullySharedGenericStruct* ___0_a, int32_t ___1_alen, Il2CppFullySharedGenericStruct* ___2_b, int32_t ___3_blen, int32_t ___4_len, int32_t ___5_imm8, int32_t ___6_allOnes, Il2CppFullySharedGenericStruct ___7_allOnesT, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	const uint32_t SizeOf_T_t42FC5CD236BFE90D4A941BFCE621367A7EA03BDC = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 2));
	const Il2CppFullySharedGenericStruct L_10 = alloca(SizeOf_T_t42FC5CD236BFE90D4A941BFCE621367A7EA03BDC);
	const Il2CppFullySharedGenericStruct L_12 = alloca(SizeOf_T_t42FC5CD236BFE90D4A941BFCE621367A7EA03BDC);
	int32_t V_0 = 0;
	v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 V_1;
	memset((&V_1), 0, sizeof(V_1));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_a), (&___1_alen), (&___2_b), (&___3_blen), (&___4_len), (&___5_imm8), (&___6_allOnes), (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->rgctx_data, 2)) ? ___7_allOnesT : &___7_allOnesT));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25329));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 25330));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25331));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:133>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25332));
		Il2CppFullySharedGenericStruct* L_0 = ___0_a;
		int32_t L_1 = ___1_alen;
		Il2CppFullySharedGenericStruct* L_2 = ___2_b;
		int32_t L_3 = ___3_blen;
		int32_t L_4 = ___4_len;
		int32_t L_5 = ___5_imm8;
		int32_t L_6 = ___6_allOnes;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25333));
		il2cpp_codegen_runtime_class_init_inline(Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var);
		int32_t L_7;
		L_7 = Sse4_2_ComputeStrCmpIntRes2_TisIl2CppFullySharedGenericStruct_m5BBC7FD25430C93A4DCF34A210DE56367BA1E204(L_0, L_1, L_2, L_3, L_4, L_5, L_6, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25333));
		V_0 = L_7;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:135>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25334));
		int32_t L_8 = ___4_len;
		int32_t L_9 = ___5_imm8;
		il2cpp_codegen_memcpy(L_10, ___7_allOnesT, SizeOf_T_t42FC5CD236BFE90D4A941BFCE621367A7EA03BDC);
		int32_t L_11 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25335));
		v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 L_13;
		L_13 = Sse4_2_ComputeStrmOutput_TisIl2CppFullySharedGenericStruct_m64ADE71FB4B90FEC60799387186E249935DE041C(L_8, L_9, il2cpp_codegen_memcpy(L_12, L_10, SizeOf_T_t42FC5CD236BFE90D4A941BFCE621367A7EA03BDC), L_11, il2cpp_rgctx_method(method->rgctx_data, 3));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25335));
		V_1 = L_13;
		goto IL_0020;
	}

IL_0020:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:136>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25336));
		v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 L_14 = V_1;
		return L_14;
	}
}
// Method Definition Index: 92426
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Sse4_2_cmpistri_emulation_TisIl2CppFullySharedGenericStruct_m0723D40FF7E3DA850D8AF6948CB6C949F855583D_gshared (Il2CppFullySharedGenericStruct* ___0_a, Il2CppFullySharedGenericStruct* ___1_b, int32_t ___2_len, int32_t ___3_imm8, int32_t ___4_allOnes, Il2CppFullySharedGenericStruct ___5_allOnesT, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var);
		il2cpp_rgctx_method_init(method);
	}
	int32_t V_0 = 0;
	int32_t V_1 = 0;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_a), (&___1_b), (&___2_len), (&___3_imm8), (&___4_allOnes), (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->rgctx_data, 3)) ? ___5_allOnesT : &___5_allOnesT));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25368));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 25369));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25370));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:169>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25371));
		Il2CppFullySharedGenericStruct* L_0 = ___0_a;
		Il2CppFullySharedGenericStruct* L_1 = ___0_a;
		int32_t L_2 = ___2_len;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25372));
		il2cpp_codegen_runtime_class_init_inline(Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var);
		int32_t L_3;
		L_3 = Sse4_2_ComputeStringLength_TisIl2CppFullySharedGenericStruct_m764CDB4D47CB1C77EAA40D60D44F53C4E97CD8D6(L_1, L_2, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25372));
		Il2CppFullySharedGenericStruct* L_4 = ___1_b;
		Il2CppFullySharedGenericStruct* L_5 = ___1_b;
		int32_t L_6 = ___2_len;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25373));
		int32_t L_7;
		L_7 = Sse4_2_ComputeStringLength_TisIl2CppFullySharedGenericStruct_m764CDB4D47CB1C77EAA40D60D44F53C4E97CD8D6(L_5, L_6, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25373));
		int32_t L_8 = ___2_len;
		int32_t L_9 = ___3_imm8;
		int32_t L_10 = ___4_allOnes;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25374));
		int32_t L_11;
		L_11 = Sse4_2_ComputeStrCmpIntRes2_TisIl2CppFullySharedGenericStruct_m5BBC7FD25430C93A4DCF34A210DE56367BA1E204(L_0, L_3, L_4, L_7, L_8, L_9, L_10, il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25374));
		V_0 = L_11;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:171>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25375));
		int32_t L_12 = ___2_len;
		int32_t L_13 = ___3_imm8;
		int32_t L_14 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25376));
		int32_t L_15;
		L_15 = Sse4_2_ComputeStriOutput_mC9EFEB2A2B9B95760CEE913DF4EF7F57BE662123(L_12, L_13, L_14, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25376));
		V_1 = L_15;
		goto IL_0026;
	}

IL_0026:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:172>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25377));
		int32_t L_16 = V_1;
		return L_16;
	}
}
// Method Definition Index: 92423
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 Sse4_2_cmpistrm_emulation_TisIl2CppFullySharedGenericStruct_m16F77547DC1C2BE0F6959A4B639E1210EF674C66_gshared (Il2CppFullySharedGenericStruct* ___0_a, Il2CppFullySharedGenericStruct* ___1_b, int32_t ___2_len, int32_t ___3_imm8, int32_t ___4_allOnes, Il2CppFullySharedGenericStruct ___5_allOnesT, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	const uint32_t SizeOf_T_tC319464E6946647CC7BFD95709030A0B11A82E13 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 3));
	const Il2CppFullySharedGenericStruct L_14 = alloca(SizeOf_T_tC319464E6946647CC7BFD95709030A0B11A82E13);
	const Il2CppFullySharedGenericStruct L_16 = alloca(SizeOf_T_tC319464E6946647CC7BFD95709030A0B11A82E13);
	int32_t V_0 = 0;
	v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 V_1;
	memset((&V_1), 0, sizeof(V_1));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_a), (&___1_b), (&___2_len), (&___3_imm8), (&___4_allOnes), (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->rgctx_data, 3)) ? ___5_allOnesT : &___5_allOnesT));
	DECLARE_METHOD_LOCALS(methodExecutionContextLocals, (&V_0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, methodExecutionContextLocals);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25319));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Burst + 25320));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25321));
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:126>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25322));
		Il2CppFullySharedGenericStruct* L_0 = ___0_a;
		Il2CppFullySharedGenericStruct* L_1 = ___0_a;
		int32_t L_2 = ___2_len;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25323));
		il2cpp_codegen_runtime_class_init_inline(Sse4_2_t40477411E6B6B2D01F3B0EA9D1B0A6281833C37C_il2cpp_TypeInfo_var);
		int32_t L_3;
		L_3 = Sse4_2_ComputeStringLength_TisIl2CppFullySharedGenericStruct_m764CDB4D47CB1C77EAA40D60D44F53C4E97CD8D6(L_1, L_2, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25323));
		Il2CppFullySharedGenericStruct* L_4 = ___1_b;
		Il2CppFullySharedGenericStruct* L_5 = ___1_b;
		int32_t L_6 = ___2_len;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25324));
		int32_t L_7;
		L_7 = Sse4_2_ComputeStringLength_TisIl2CppFullySharedGenericStruct_m764CDB4D47CB1C77EAA40D60D44F53C4E97CD8D6(L_5, L_6, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25324));
		int32_t L_8 = ___2_len;
		int32_t L_9 = ___3_imm8;
		int32_t L_10 = ___4_allOnes;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25325));
		int32_t L_11;
		L_11 = Sse4_2_ComputeStrCmpIntRes2_TisIl2CppFullySharedGenericStruct_m5BBC7FD25430C93A4DCF34A210DE56367BA1E204(L_0, L_3, L_4, L_7, L_8, L_9, L_10, il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25325));
		V_0 = L_11;
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:128>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25326));
		int32_t L_12 = ___2_len;
		int32_t L_13 = ___3_imm8;
		il2cpp_codegen_memcpy(L_14, ___5_allOnesT, SizeOf_T_tC319464E6946647CC7BFD95709030A0B11A82E13);
		int32_t L_15 = V_0;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25327));
		v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 L_17;
		L_17 = Sse4_2_ComputeStrmOutput_TisIl2CppFullySharedGenericStruct_m64ADE71FB4B90FEC60799387186E249935DE041C(L_12, L_13, il2cpp_codegen_memcpy(L_16, L_14, SizeOf_T_tC319464E6946647CC7BFD95709030A0B11A82E13), L_15, il2cpp_rgctx_method(method->rgctx_data, 4));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25327));
		V_1 = L_17;
		goto IL_0028;
	}

IL_0028:
	{
		//<source_info:./Library/PackageCache/com.unity.burst@6bb9aca3ef38/Runtime/Intrinsics/x86/Sse4_2.cs:129>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Burst + 25328));
		v128_t9D2F2BF6DCFF1D82BF38064CF157489E1E680B61 L_18 = V_1;
		return L_18;
	}
}
// Method Definition Index: 84396
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void StreamingState_Update_TisIl2CppFullySharedGenericStruct_m301FBB6A80BBA46BB5AC2B0DF206CAB72593DE1D_gshared (StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020* __this, Il2CppFullySharedGenericStruct* ___0_input, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020_0_0_0_var);
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020_il2cpp_TypeInfo_var);
		il2cpp_rgctx_method_init(method);
	}
	DECLARE_METHOD_THIS(methodExecutionContextThis, (&__this));
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_input));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, methodExecutionContextThis, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30736));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 30737));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30738));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/xxHash3.StreamingState.cs:145>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30739));
		Il2CppFullySharedGenericStruct* L_0 = ___0_input;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30740));
		void* L_1;
		L_1 = UnsafeUtilityExtensions_AddressOf_TisIl2CppFullySharedGenericStruct_m9A8A98C3D874841DE9AB55CBCFD69D17C27A0E2A_inline(L_0, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30740));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30741));
		int32_t L_2;
		L_2 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30741));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30742));
		il2cpp_codegen_runtime_class_init_inline(StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020_il2cpp_TypeInfo_var);
		StreamingState_Update_mD0C172FBC9AB99BC72DF8CC3665ABB61658AB9E5(__this, L_1, L_2, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30742));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/xxHash3.StreamingState.cs:146>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 30743));
		return;
	}
}
IL2CPP_EXTERN_C  void StreamingState_Update_TisIl2CppFullySharedGenericStruct_m301FBB6A80BBA46BB5AC2B0DF206CAB72593DE1D_AdjustorThunk (RuntimeObject* __this, Il2CppFullySharedGenericStruct* ___0_input, const RuntimeMethod* method)
{
	StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<StreamingState_t407BC6BBA6752E76D2075153BF945841B2D06020*>(__this + _offset);
	StreamingState_Update_TisIl2CppFullySharedGenericStruct_m301FBB6A80BBA46BB5AC2B0DF206CAB72593DE1D(_thisAdjusted, ___0_input, method);
}
// Method Definition Index: 83411
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Array_Allocate_TisIl2CppFullySharedGenericStruct_m472C3AE183E3C768741B28481DD1F012013B13A6_gshared (int64_t ___0_count, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___1_allocator, const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	Il2CppFullySharedGenericStruct* V_0 = NULL;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_count), (&___1_allocator));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20620));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 20621));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20622));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/Memory.cs:103>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20623));
		int64_t L_0 = ___0_count;
		AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 L_1 = ___1_allocator;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20624));
		Il2CppFullySharedGenericStruct* L_2;
		L_2 = Array_Resize_TisIl2CppFullySharedGenericStruct_m07039200651D43DBB7FBC0CB244761DA34C164FD((Il2CppFullySharedGenericStruct*)((uintptr_t)0), ((int64_t)0), L_0, L_1, il2cpp_rgctx_method(method->rgctx_data, 0));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20624));
		V_0 = L_2;
		goto IL_000f;
	}

IL_000f:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/Memory.cs:104>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20625));
		Il2CppFullySharedGenericStruct* L_3 = V_0;
		return L_3;
	}
}
// Method Definition Index: 83412
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Array_Free_TisIl2CppFullySharedGenericStruct_m6AA7597FA98F8020ABEFACEA0A1D00A384716627_gshared (Il2CppFullySharedGenericStruct* ___0_pointer, int64_t ___1_count, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___2_allocator, const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	bool V_0 = false;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_pointer), (&___1_count), (&___2_allocator));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20626));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 20627));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20628));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/Memory.cs:110>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20629));
		Il2CppFullySharedGenericStruct* L_0 = ___0_pointer;
		V_0 = (bool)((((intptr_t)L_0) == ((intptr_t)((uintptr_t)0)))? 1 : 0);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20630));
		bool L_1 = V_0;
		if (!L_1)
		{
			goto IL_000c;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/Memory.cs:111>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20631));
		goto IL_0017;
	}

IL_000c:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/Memory.cs:112>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20632));
		Il2CppFullySharedGenericStruct* L_2 = ___0_pointer;
		int64_t L_3 = ___1_count;
		AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 L_4 = ___2_allocator;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20633));
		Il2CppFullySharedGenericStruct* L_5;
		L_5 = Array_Resize_TisIl2CppFullySharedGenericStruct_m07039200651D43DBB7FBC0CB244761DA34C164FD(L_2, L_3, ((int64_t)0), L_4, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20633));
	}

IL_0017:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/Memory.cs:113>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20634));
		return;
	}
}
// Method Definition Index: 83410
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* Array_Resize_TisIl2CppFullySharedGenericStruct_m07039200651D43DBB7FBC0CB244761DA34C164FD_gshared (Il2CppFullySharedGenericStruct* ___0_oldPointer, int64_t ___1_oldCount, int64_t ___2_newCount, AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 ___3_allocator, const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	Il2CppFullySharedGenericStruct* V_0 = NULL;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_oldPointer), (&___1_oldCount), (&___2_newCount), (&___3_allocator));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20612));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 20613));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20614));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/Memory.cs:96>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20615));
		Il2CppFullySharedGenericStruct* L_0 = ___0_oldPointer;
		int64_t L_1 = ___1_oldCount;
		int64_t L_2 = ___2_newCount;
		AllocatorHandle_t3CA09720B1F89F91A8DDBA95E74C28A1EC3E3148 L_3 = ___3_allocator;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20616));
		int32_t L_4;
		L_4 = UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_inline(il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20616));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20617));
		int32_t L_5;
		L_5 = UnsafeUtility_AlignOf_TisIl2CppFullySharedGenericStruct_m11D1023B182BE19CF0F1A57DBE826004A1B81A41(il2cpp_rgctx_method(method->rgctx_data, 2));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20617));
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20618));
		void* L_6;
		L_6 = Array_Resize_mC7BE2965DE3FCF4014D43B606D94951480A65380((void*)L_0, L_1, L_2, L_3, ((int64_t)L_4), L_5, NULL);
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20618));
		V_0 = (Il2CppFullySharedGenericStruct*)L_6;
		goto IL_0018;
	}

IL_0018:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/Memory.cs:97>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 20619));
		Il2CppFullySharedGenericStruct* L_7 = V_0;
		return L_7;
	}
}
// Method Definition Index: 69119
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR Il2CppFullySharedGenericAny* UnsafeUtility_As_TisIl2CppFullySharedGenericAny_TisIl2CppFullySharedGenericAny_mD6BECC32C10552E82C8D23115CAF774983D95F0C_gshared_inline (Il2CppFullySharedGenericAny* ___0_from, const RuntimeMethod* method) 
{
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_from));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1692));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1693));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1694));
		Il2CppFullySharedGenericAny* L_0 = ___0_from;
		return (Il2CppFullySharedGenericAny*)(L_0);
	}
}
// Method Definition Index: 69118
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR int32_t UnsafeUtility_SizeOf_TisIl2CppFullySharedGenericStruct_mB6FBF9DDC79FEC02EC8705E9E527E1CD495564BF_gshared_inline (const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	const uint32_t SizeOf_T_tE6588938356AD51CD7B5532933E8B84E7779C6E2 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 0));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, NULL, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1689));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1690));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1691));
		uint32_t L_0 = SizeOf_T_tE6588938356AD51CD7B5532933E8B84E7779C6E2;
		return (int32_t)L_0;
	}
}
// Method Definition Index: 69113
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void UnsafeUtility_ReadArrayElement_TisIl2CppFullySharedGenericAny_m295186AA082411C57485F8BDB824E4D8AC1C6D93_gshared_inline (void* ___0_source, int32_t ___1_index, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	const uint32_t SizeOf_T_t3818EBA71DF5EA591716A05E0BBD988D81931B5C = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->rgctx_data, 0));
	const Il2CppFullySharedGenericAny L_3 = alloca(SizeOf_T_t3818EBA71DF5EA591716A05E0BBD988D81931B5C);
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_source), (&___1_index));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1674));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1675));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1676));
		void* L_0 = ___0_source;
		int32_t L_1 = ___1_index;
		uint32_t L_2 = SizeOf_T_t3818EBA71DF5EA591716A05E0BBD988D81931B5C;
		il2cpp_codegen_memcpy(L_3, ((void*)il2cpp_codegen_add((intptr_t)L_0, ((intptr_t)((int64_t)il2cpp_codegen_multiply(((int64_t)L_1), ((int64_t)((int32_t)L_2))))))), SizeOf_T_t3818EBA71DF5EA591716A05E0BBD988D81931B5C);
		il2cpp_codegen_memcpy(il2cppRetVal, L_3, SizeOf_T_t3818EBA71DF5EA591716A05E0BBD988D81931B5C);
		return;
	}
}
// Method Definition Index: 69109
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void UnsafeUtility_CopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mBE6568C7ECF69CD1E86FDFF4E25D6CB529F76BF3_gshared_inline (void* ___0_ptr, Il2CppFullySharedGenericStruct* ___1_output, const RuntimeMethod* method) 
{
	il2cpp_rgctx_method_init(method);
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_ptr), (&___1_output));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1658));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1659));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1660));
		void* L_0 = ___0_ptr;
		Il2CppFullySharedGenericStruct* L_1 = ___1_output;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1661));
		UnsafeUtility_InternalCopyPtrToStructure_TisIl2CppFullySharedGenericStruct_mD132267FDFD79997EE2A47470E89CE83AC7CA91E(L_0, L_1, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1661));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1662));
		return;
	}
}
// Method Definition Index: 69072
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void* NativeArrayUnsafeUtility_GetUnsafePtr_TisIl2CppFullySharedGenericStruct_m4AB802D5B1B296D0F976C1E7631699B0C4A4D00F_gshared_inline (NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 ___0_nativeArray, const RuntimeMethod* method) 
{
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_nativeArray));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1533));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1534));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1535));
		NativeArray_1_tDB8B8DC66CC8E16ED6D9A8C75D2C1AFC80AC1E18 L_0 = ___0_nativeArray;
		void* L_1 = L_0.___m_Buffer;
		return L_1;
	}
}
// Method Definition Index: 69121
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR Il2CppFullySharedGenericStruct* UnsafeUtility_AsRef_TisIl2CppFullySharedGenericStruct_m78B0690121A96EFFDA7D6D3ADAF97940CF8136BE_gshared_inline (void* ___0_ptr, const RuntimeMethod* method) 
{
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_ptr));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1698));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1699));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnityEngine_CoreModule + 1700));
		void* L_0 = ___0_ptr;
		return (Il2CppFullySharedGenericStruct*)(L_0);
	}
}
// Method Definition Index: 11684
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* EqualityComparer_1_get_Default_mA09C502B9197D9DD4E25A431E2C4BC5468631270_gshared_inline (const RuntimeMethod* method) 
{
	EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* V_0 = NULL;
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, NULL, NULL);
	CHECK_PAUSE_POINT;
	{
		EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* L_0 = ((EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC_StaticFields*)il2cpp_codegen_static_fields_for(il2cpp_rgctx_data(InitializedTypeInfo(method->klass)->rgctx_data, 2)))->___defaultComparer;
		il2cpp_codegen_memory_barrier();
		V_0 = L_0;
		EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* L_1 = V_0;
		if (L_1)
		{
			goto IL_0019;
		}
	}
	{
		EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* L_2;
		L_2 = EqualityComparer_1_CreateComparer_mF50863260964D9553ECFD6B8D81059A734FCB781(il2cpp_rgctx_method(InitializedTypeInfo(method->klass)->rgctx_data, 3));
		V_0 = L_2;
		EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* L_3 = V_0;
		il2cpp_codegen_memory_barrier();
		((EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC_StaticFields*)il2cpp_codegen_static_fields_for(il2cpp_rgctx_data(InitializedTypeInfo(method->klass)->rgctx_data, 2)))->___defaultComparer = L_3;
		Il2CppCodeGenWriteBarrier((void**)(&((EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC_StaticFields*)il2cpp_codegen_static_fields_for(il2cpp_rgctx_data(InitializedTypeInfo(method->klass)->rgctx_data, 2)))->___defaultComparer), (void*)L_3);
	}

IL_0019:
	{
		EqualityComparer_1_t974B6EF56BCA01CA6AD3434C04A3F054C43783CC* L_4 = V_0;
		return L_4;
	}
}
// Method Definition Index: 85189
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void* UnsafeUtilityExtensions_AddressOf_TisIl2CppFullySharedGenericStruct_m9A8A98C3D874841DE9AB55CBCFD69D17C27A0E2A_gshared_inline (Il2CppFullySharedGenericStruct* ___0_value, const RuntimeMethod* method) 
{
	if (!il2cpp_rgctx_is_initialized(method))
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&VoidU2A_t104EAEFBD2D237A8C29618913DA9B4D99355E965_0_0_0_var);
		il2cpp_rgctx_method_init(method);
	}
	void* V_0 = NULL;
	DECLARE_METHOD_PARAMS(methodExecutionContextParameters, (&___0_value));
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, methodExecutionContextParameters, NULL);
	CHECK_METHOD_ENTRY_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 40056));
	CHECK_METHOD_EXIT_SEQ_POINT(methodExitChecker, methodExecutionContext, (g_sequencePointsUnity_Collections + 40057));
	{
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 40058));
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeUtilityEx.cs:90>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 40059));
		Il2CppFullySharedGenericStruct* L_0 = ___0_value;
		STORE_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 40060));
		void* L_1;
		L_1 = ILSupport_AddressOf_TisIl2CppFullySharedGenericStruct_m373C1FEADC4248F808294AA8958583E51840E129_inline(L_0, il2cpp_rgctx_method(method->rgctx_data, 1));
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 40060));
		V_0 = L_1;
		goto IL_000a;
	}

IL_000a:
	{
		//<source_info:./Library/PackageCache/com.unity.collections@5b6ebd78ccc0/Unity.Collections/UnsafeUtilityEx.cs:91>
		CHECK_SEQ_POINT(methodExecutionContext, (g_sequencePointsUnity_Collections + 40061));
		void* L_2 = V_0;
		return L_2;
	}
}
// Method Definition Index: 102024
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void* ILSupport_AddressOf_TisIl2CppFullySharedGenericStruct_m373C1FEADC4248F808294AA8958583E51840E129_gshared_inline (Il2CppFullySharedGenericStruct* ___0_thing, const RuntimeMethod* method) 
{
	DECLARE_METHOD_EXEC_CTX(methodExecutionContext, method, NULL, NULL, NULL);
	CHECK_PAUSE_POINT;
	{
		Il2CppFullySharedGenericStruct* L_0 = ___0_thing;
		return (void*)(L_0);
	}
}
