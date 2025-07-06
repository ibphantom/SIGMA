use axum::{extract::Multipart, Json};
use axum::response::IntoResponse;
use crate::routes::error::AppError;
use std::fs::File;
use std::io::Write;

pub async fn decrypt(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    let mut file_data = None;

    while let Some(field) = multipart.next_field().await? {
        if field.name() == Some("file") {
            file_data = Some(field.bytes().await?.to_vec());
        }
    }

    let data = file_data.ok_or(AppError::message("Missing encrypted file"))?;

    // Dummy decryption logic
    let decrypted_msg = format!("Decrypted {} bytes", data.len());

    Ok(Json(serde_json::json!({
        "decrypted": true,
        "message": decrypted_msg
    })))
}
