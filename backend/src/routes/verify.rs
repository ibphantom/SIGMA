use axum::{extract::Multipart, Json};
use axum::response::IntoResponse;
use crate::routes::error::AppError;
use std::io::Write;
use std::fs::{File, remove_file};
use uuid::Uuid;

pub async fn verify(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    let mut media_bytes = None;
    let mut sig_bytes = None;

    while let Some(field) = multipart.next_field().await? {
        match field.name() {
            Some("file") => {
                media_bytes = Some(field.bytes().await?.to_vec());
            }
            Some("sig") => {
                sig_bytes = Some(field.bytes().await?.to_vec());
            }
            _ => {}
        }
    }

    let media = media_bytes.ok_or(AppError::message("Missing media file"))?;
    let sig = sig_bytes.ok_or(AppError::message("Missing signature file"))?;

    // Dummy verification logic
    let valid = media.len() > 0 && sig.len() > 0; // Replace with actual GPG logic

    Ok(Json(serde_json::json!({
        "verified": valid
    })))
}
