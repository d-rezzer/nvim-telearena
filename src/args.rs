use neovim_lib::Value;

pub fn parse_string(value: &Value) -> Result<String, String> {
    value
        .as_str()
        .ok_or("cannot parse error".to_owned())
        .map(|s| String::from(s))
}

pub fn parse_usize(value: &Value) -> Result<usize, String> {
    value
        .as_u64()
        .ok_or("cannot parse usize".to_owned())
        .map(|n| n as usize)
}
