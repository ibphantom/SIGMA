use axum::{extract::Multipart, response::{IntoResponse, Response}, Json};
use axum::http::{HeaderMap, header};
use std::fs::File;
use std::io::Write;
use uuid::Uuid;
use crate::routes::error::AppError;
use sequoia_openpgp::cert::prelude::*;
use sequoia_openpgp::serialize::stream::*;
use sequoia_openpgp::{Result as PgpResult, Message};

pub async fn sign(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    let mut file_bytes = vec![];
    let mut filename = None;

    while let Some(field) = multipart.next_field().await? {
        let name = field.name().unwrap_or("file");
        if name == "file" {
            filename = field.file_name().map(String::from);
            file_bytes = field.bytes().await?.to_vec();
        }
    }

    let sig_id = Uuid::new_v4().to_string();
    let sig_path = format!("/data/gnupg/{}.sig", sig_id);
    let mut sig_file = File::create(&sig_path)?;

    // Dummy signing logic; replace with actual key and signer
    sig_file.write_all(b"SIGNATURE")?;

    let mut headers = HeaderMap::new();
    headers.insert(header::CONTENT_TYPE, "application/octet-stream".parse().unwrap());
    headers.insert(header::CONTENT_DISPOSITION, format!("attachment; filename=\"{}.sig\"", sig_id).parse().unwrap());

    let response: Response = (headers, sig_path).into_response();
    Ok(response)
}
