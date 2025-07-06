use axum::Json;
use axum::response::IntoResponse;
use crate::routes::error::AppError;
use std::fs;
use std::path::Path;

pub async fn list_keys() -> Result<impl IntoResponse, AppError> {
    let key_dir = Path::new("/data/gnupg/keys");
    let mut keys = vec![];

    if key_dir.exists() {
        for entry in fs::read_dir(key_dir)? {
            let entry = entry?;
            if let Some(name) = entry.file_name().to_str() {
                keys.push(name.to_string());
            }
        }
    }

    Ok(Json(serde_json::json!({
        "keys": keys
    })))
}
