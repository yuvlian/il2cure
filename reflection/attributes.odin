package reflection

// ECMA-335 II.22.15 Field attributes bit masks
Field_Attributes :: distinct u32

Field_Attributes_FieldAccessMask    :: Field_Attributes(0x0007)
Field_Attributes_CompilerControlled :: Field_Attributes(0x0000)
Field_Attributes_Private            :: Field_Attributes(0x0001)
Field_Attributes_FamANDAssem        :: Field_Attributes(0x0002)
Field_Attributes_Assembly           :: Field_Attributes(0x0003)
Field_Attributes_Family             :: Field_Attributes(0x0004)
Field_Attributes_FamORAssem         :: Field_Attributes(0x0005)
Field_Attributes_Public             :: Field_Attributes(0x0006)
Field_Attributes_Static             :: Field_Attributes(0x0010)
Field_Attributes_InitOnly           :: Field_Attributes(0x0020)
Field_Attributes_Literal            :: Field_Attributes(0x0040)
Field_Attributes_NotSerialized      :: Field_Attributes(0x0080)
Field_Attributes_SpecialName        :: Field_Attributes(0x0200)
Field_Attributes_RTSpecialName      :: Field_Attributes(0x0400)
Field_Attributes_HasFieldMarshal    :: Field_Attributes(0x1000)
Field_Attributes_PinvokeImpl        :: Field_Attributes(0x2000)
Field_Attributes_HasDefault         :: Field_Attributes(0x8000)

// ECMA-335 II.22.19 Method attributes bit masks
Method_Attributes :: distinct u32

Method_Attributes_MemberAccessMask      :: Method_Attributes(0x0007)
Method_Attributes_CompilerControlled    :: Method_Attributes(0x0000)
Method_Attributes_Private               :: Method_Attributes(0x0001)
Method_Attributes_FamANDAssem           :: Method_Attributes(0x0002)
Method_Attributes_Assembly              :: Method_Attributes(0x0003)
Method_Attributes_Family                :: Method_Attributes(0x0004)
Method_Attributes_FamORAssem            :: Method_Attributes(0x0005)
Method_Attributes_Public                :: Method_Attributes(0x0006)
Method_Attributes_Static                :: Method_Attributes(0x0010)
Method_Attributes_Final                 :: Method_Attributes(0x0020)
Method_Attributes_Virtual               :: Method_Attributes(0x0040)
Method_Attributes_HideBySig             :: Method_Attributes(0x0080)
Method_Attributes_VtableLayoutMask      :: Method_Attributes(0x0100)
Method_Attributes_ReuseSlot             :: Method_Attributes(0x0000)
Method_Attributes_NewSlot               :: Method_Attributes(0x0100)
Method_Attributes_CheckAccessOnOverride :: Method_Attributes(0x0200)
Method_Attributes_Abstract              :: Method_Attributes(0x0400)
Method_Attributes_SpecialName           :: Method_Attributes(0x0800)
Method_Attributes_RTSpecialName         :: Method_Attributes(0x1000)
Method_Attributes_PinvokeImpl           :: Method_Attributes(0x2000)
Method_Attributes_HasSecurity           :: Method_Attributes(0x4000)
Method_Attributes_RequireSecObject      :: Method_Attributes(0x8000)

// ECMA-335 II.22.26 Property attributes bit masks
Property_Attributes :: distinct u32

Property_Attributes_None          :: Property_Attributes(0x0000)
Property_Attributes_SpecialName   :: Property_Attributes(0x0200)
Property_Attributes_RTSpecialName :: Property_Attributes(0x0400)
Property_Attributes_HasDefault    :: Property_Attributes(0x1000)

// ECMA-335 II.23.1.15 TypeDef attributes bit masks
Type_Attributes :: distinct u32

Type_Attributes_VisibilityMask     :: Type_Attributes(0x00000007)
Type_Attributes_NotPublic          :: Type_Attributes(0x00000000)
Type_Attributes_Public             :: Type_Attributes(0x00000001)
Type_Attributes_NestedPublic       :: Type_Attributes(0x00000002)
Type_Attributes_NestedPrivate      :: Type_Attributes(0x00000003)
Type_Attributes_NestedFamily       :: Type_Attributes(0x00000004)
Type_Attributes_NestedAssembly     :: Type_Attributes(0x00000005)
Type_Attributes_NestedFamANDAssem  :: Type_Attributes(0x00000006)
Type_Attributes_NestedFamORAssem   :: Type_Attributes(0x00000007)
Type_Attributes_LayoutMask         :: Type_Attributes(0x00000018)
Type_Attributes_AutoLayout         :: Type_Attributes(0x00000000)
Type_Attributes_SequentialLayout   :: Type_Attributes(0x00000008)
Type_Attributes_ExplicitLayout     :: Type_Attributes(0x00000010)
Type_Attributes_ClassSemanticsMask :: Type_Attributes(0x00000020)
Type_Attributes_Class              :: Type_Attributes(0x00000000)
Type_Attributes_Interface          :: Type_Attributes(0x00000020)
Type_Attributes_Abstract           :: Type_Attributes(0x00000080)
Type_Attributes_Sealed             :: Type_Attributes(0x00000100)
Type_Attributes_SpecialName        :: Type_Attributes(0x00000400)
Type_Attributes_RTSpecialName      :: Type_Attributes(0x00000800)
Type_Attributes_Import             :: Type_Attributes(0x00001000)
Type_Attributes_Serializable       :: Type_Attributes(0x00002000)
Type_Attributes_WindowsRuntime     :: Type_Attributes(0x00004000)
Type_Attributes_StringFormatMask   :: Type_Attributes(0x00030000)
Type_Attributes_AnsiClass          :: Type_Attributes(0x00000000)
Type_Attributes_UnicodeClass       :: Type_Attributes(0x00010000)
Type_Attributes_AutoClass          :: Type_Attributes(0x00020000)
Type_Attributes_CustomFormatClass  :: Type_Attributes(0x00030000)
Type_Attributes_CustomFormatMask   :: Type_Attributes(0x00C00000)
Type_Attributes_BeforeFieldInit    :: Type_Attributes(0x00100000)
Type_Attributes_HasSecurity        :: Type_Attributes(0x00040000)
Type_Attributes_ReservedMask       :: Type_Attributes(0x00040800)

has_flags :: proc (value, mask: $T) -> bool {
	return u32(value) & u32(mask) == u32(mask)
}
