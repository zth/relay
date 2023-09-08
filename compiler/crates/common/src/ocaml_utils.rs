pub fn get_module_name_from_file_path(str: &str) -> String {
    match std::path::Path::new(str).file_stem().unwrap().to_str() {
        None => String::from(""),
        Some(str) => str.to_string(),
    }
}
