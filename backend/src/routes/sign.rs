use axum::{extract::Multipart, response::IntoResponse, Json};
use sequoia_openpgp::{parse::Parse, Cert};
use sequoia_openpgp::serialize::stream::{Message, Signer};
use sequoia_openpgp::types::HashAlgorithm;
use std::io::Write;
use uuid::Uuid;
use base64::{engine::general_purpose, Engine as _};
use serde_json::json;
use crate::error::AppError;

pub async fn sign_handler(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    while let Some(field) = multipart.next_field().await.map_err(|_| AppError::Internal("Multipart error".into()))? {
        let data = field.bytes().await.map_err(|_| AppError::Internal("Read failed".into()))?;

        let cert = Cert::from_file("/data/gnupg/private.asc")?;
        let keypair = cert
            .keys()
            .secret()
            .with_policy(&Default::default(), None)
            .alive()
            .revoked(false)
            .for_signing()
            .next()
            .ok_or_else(|| AppError::Internal("No signing key found".into()))?;

        let mut output = Vec::new();
        {
            let mut signer = Signer::detached(Message::new(&mut output), keypair.key().clone(), HashAlgorithm::SHA2_256)?;
            signer.write_all(&data)?;
            signer.finalize()?;
        }

        let base64_sig = general_purpose::STANDARD.encode(&output);

        return Ok(Json(json!({ "signature": base64_sig })));
    }

    Err(AppError::BadRequest("No file uploaded".into()))
}
