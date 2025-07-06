use axum::{extract::Multipart, http::StatusCode, response::IntoResponse, Json};
use sequoia_openpgp::{parse::Parse, Cert, Packet};
use sequoia_openpgp::serialize::stream::{Message, Signer, SignerBuilder};
use sequoia_openpgp::types::HashAlgorithm;
use std::fs::File;
use std::io::{BufReader, Read, Write};
use uuid::Uuid;
use tracing::info;
use serde_json::json;
use crate::error::AppError;

pub async fn sign_handler(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    info!("Received file for signing");
    
    while let Some(field) = multipart.next_field().await.map_err(|_| AppError::Internal("Invalid multipart".into()))? {
        let file_name = field.file_name().unwrap_or("file").to_string();
        let data = field.bytes().await.map_err(|_| AppError::Internal("Read failed".into()))?;

        let input_path = format!("/data/gnupg/input_{}", Uuid::new_v4());
        let sig_path = format!("{}.sig", &input_path);

        std::fs::write(&input_path, &data)?;

        let cert = Cert::from_file("/data/gnupg/private.asc")?;
        let keypair = cert.keys().secret().with_policy(&Default::default(), None).alive().revoked(false).for_signing().next()
            .ok_or_else(|| AppError::Internal("No signing key found".into()))?;

        let mut output = File::create(&sig_path)?;
        let mut signer = Signer::detached(Message::new(&mut output), keypair.key().clone(), HashAlgorithm::SHA2_256)?;
        signer.write_all(&data)?;
        signer.finalize()?;

        return Ok(Json(json!({ "signature": format!("{}.sig", file_name) })));
    }

    Err(AppError::BadRequest("No file uploaded".into()))
}
