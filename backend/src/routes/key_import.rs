use axum::{extract::{Multipart, FromRequestParts}, response::IntoResponse};
use crate::routes::error::AppError;
use crate::routes::auth::Auth;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;
use uuid::Uuid;

pub async fn import_key(Auth: Auth, mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    while let Some(field) = multipart.next_field().await? {
        if field.name() == Some("file") {
            let file_data = field.bytes().await?;
            let filename = field.file_name().unwrap_or("imported.asc");
            let mut path = PathBuf::from("/data/gnupg/keys");
            path.push(format!("{}_{}", Uuid::new_v4(), filename));

            let mut out = File::create(path)?;
            out.write_all(&file_data)?;
        }
    }

    Ok("Key imported")
}
