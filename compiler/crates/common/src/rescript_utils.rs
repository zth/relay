use intern::string_key::Intern;
use intern::string_key::StringKey;

pub fn get_module_name_from_file_path(str: &str) -> String {
    match std::path::Path::new(str).file_stem().unwrap().to_str() {
        None => String::from(""),
        Some(str) => str.to_string(),
    }
}

pub fn get_load_fn_code() -> StringKey {
    "@live let load: (
  ~environment: RescriptRelay.Environment.t,
  ~variables: Types.variables,
  ~fetchPolicy: RescriptRelay.fetchPolicy=?,
  ~fetchKey: string=?,
  ~networkCacheConfig: RescriptRelay.cacheConfig=?,
) => queryRef = (
  ~environment,
  ~variables,
  ~fetchPolicy=?,
  ~fetchKey=?,
  ~networkCacheConfig=?,
) =>
  RescriptRelay.loadQuery(
    environment,
    node,
    variables->Internal.convertVariables,
    {
      fetchKey,
      fetchPolicy,
      networkCacheConfig,
    },
  )"
    .intern()
}

pub fn get_load_query_code(include_load_fn: bool) -> StringKey {
    format!(
        "{}

@live
let queryRefToObservable = token => {{
  let raw = token->Internal.tokenToRaw
  raw.source->Nullable.toOption
}}
  
@live
let queryRefToPromise = token => {{
  Promise.make((resolve, _reject) => {{
    switch token->queryRefToObservable {{
    | None => resolve(Error())
    | Some(o) =>
      open RescriptRelay.Observable
      let _: subscription = o->subscribe(makeObserver(~complete=() => resolve(Ok())))
    }}
  }})
}}",
        if include_load_fn {
            get_load_fn_code()
        } else {
            "".intern()
        }
    )
    .intern()
}
