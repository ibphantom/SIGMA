use axum::{extract::Multipart, Json};
use axum::response::IntoResponse;
use crate::routes::error::AppError;
use std::fs::File;
use std::io::Write;
use uuid::Uuid;

pub async fn encrypt(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    let mut file_data = None;
    let mut recipient = None;

    while let Some(field) = multipart.next_field().await? {
        match field.name() {
            Some("file") => file_data = Some(field.bytes().await?.to_vec()),
            Some("recipient") => recipient = Some(field.text().await?),
            _ => {}
        }
    }

    let data = file_data.ok_or(AppError::message("Missing file"))?;
    let to = recipient.ok_or(AppError::message("Missing recipient"))?;

    // Dummy encryption
    let output_path = format!("/data/gnupg/{}.enc", Uuid::new_v4());
    let mut file = File::create(&output_path)?;
    file.write_all(data.as_slice())?;

    Ok(Json(serde_json::json!({
        "encrypted": true,
        "output": output_path
    })))
}
