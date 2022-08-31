#[derive(Debug)]
pub struct UnionMember {
    pub typename: String,
    pub member_record_name: String,
}

#[derive(Debug)]
pub struct Union {
    pub record_name: String,
    pub comment: Option<String>,
    pub members: Vec<UnionMember>,
    pub at_path: Vec<String>,
}

#[derive(Debug, Clone)]
pub enum ScalarValues {
    String,
    Float,
    Boolean,
    Any,
}

#[derive(Debug, Clone)]
pub enum PropType {
    DataId,
    Scalar(ScalarValues),
    StringLiteral(String),
    Enum(String),
    Array((bool, Box<PropType>)),
    FragmentSpreads(Vec<String>),
    InputObjectReference(String),
    RecordReference(String),
    UnionReference(String),
    RelayResolver(String),

    // Warning, this means we couldn't match this identifier into a "proper"
    // type. Should probably investigate when this happens.
    RawIdentifier(String),
}

#[derive(Debug)]
pub struct PropValue {
    // This key is safe for ReScript use, meaning it has been transformed
    // already if it was an illegal name in ReScript. If it was indeed
    // transformed, the original name is located in `original_name`.
    pub key: String,

    // The original, untransformed name.
    pub original_key: Option<String>,
    pub comment: Option<String>,
    pub nullable: bool,
    pub prop_type: Box<PropType>,
}

#[derive(Debug)]
pub struct Object {
    pub comment: Option<String>,
    pub values: Vec<PropValue>,
    pub at_path: Vec<String>,
    pub record_name: String,

    // Currently only used with input objects, as we need the original type name
    // there.
    pub original_type_name: Option<String>,

    // We use this flag to allow for printing objects found in unions before
    // other objects. This is because of the hierarchy/recursiveness of types,
    // which leads to us needing to print objects in a specific order.
    pub found_in_union: bool,
}

#[derive(Debug)]
pub struct FullEnum {
    pub name: String,
    pub values: Vec<String>,
}

// Because the runtime representation does not fully match of ReScript and what
// Relay gives us, we need to convert back and forth between what Relay gives us
// and what ReScript expects. This primarily means converting raw unions to
// polymorphic variants, etc. For that, we have "conversion instructions". We
// keep track of what conversions are needed anywhere in what Relay gives us,
// and apply them accordingly.
#[derive(Debug, Clone)]
pub enum ConverterInstructions {
    ConvertUnion(String),
    ConvertCustomField(String),
    HasFragments,
    ConvertTopLevelNodeField(String),
    RootObject(String), // TODO: Rename
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Context {
    Fragment,
    Response,
    RawResponse,
    Variables,
    RootObject(String),

    // TODO: This doesn't really make sense, but it uncovered the need for a
    // refactor I simply do not have the energy to do right now.
    NotRelevant,
}

#[derive(Debug)]
pub struct InstructionContainer {
    pub context: Context,
    pub at_path: Vec<String>,
    pub instruction: ConverterInstructions,
}

#[derive(Debug)]
pub enum ConversionDirection {
    Wrap,
    Unwrap,
}

#[derive(Debug)]
pub enum NullableType {
    Undefined,
    Null,
}

#[derive(Debug)]
pub struct ProvidedVariable {
    pub key: String,
    pub return_type: String,
}
