use axum::{response::IntoResponse, Json};
use sequoia_openpgp::Cert;
use std::fs;
use crate::error::AppError;
use serde_json::json;

pub async fn list_keys_handler() -> Result<impl IntoResponse, AppError> {
    let files = fs::read_dir("/data/gnupg")?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map_or(false, |ext| ext == "asc"))
        .collect::<Vec<_>>();

    let mut key_info = vec![];
    for file in files {
        if let Ok(cert) = Cert::from_file(file.path()) {
            for uid in cert.userids() {
                key_info.push(uid.userid().to_string());
            }
        }
    }

    Ok(Json(json!({ "keys": key_info })))
}
