use axum::{extract::Multipart, response::IntoResponse, Json};
use std::fs::File;
use std::io::Write;
use uuid::Uuid;
use serde_json::json;
use crate::error::AppError;

pub async fn import_key_handler(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    while let Some(field) = multipart.next_field().await.map_err(|_| AppError::Internal("Multipart error".into()))? {
        let filename = field.file_name().unwrap_or("key.asc");
        let key_data = field.bytes().await.map_err(|_| AppError::Internal("Read failed".into()))?;

        let file_path = format!("/data/gnupg/{}_{}", Uuid::new_v4(), filename);
        let mut file = File::create(&file_path)?;
        file.write_all(&key_data)?;

        return Ok(Json(json!({ "status": "Key imported", "file": file_path })));
    }

    Err(AppError::BadRequest("No file uploaded".into()))
}
