use axum::{extract::Multipart, response::IntoResponse, Json};
use sequoia_openpgp::{Cert, parse::Parse, parse::stream::*};
use std::fs::File;
use std::io::{BufReader, Read};
use serde_json::json;
use crate::error::AppError;

pub async fn verify_handler(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    let mut file_data = None;
    let mut sig_data = None;

    while let Some(field) = multipart.next_field().await.map_err(|_| AppError::Internal("Invalid multipart".into()))? {
        match field.name() {
            Some("file") => file_data = Some(field.bytes().await.map_err(|_| AppError::Internal("Failed to read file".into()))?),
            Some("signature") => sig_data = Some(field.bytes().await.map_err(|_| AppError::Internal("Failed to read signature".into()))?),
            _ => {}
        }
    }

    let file_data = file_data.ok_or(AppError::BadRequest("Missing file".into()))?;
    let sig_data = sig_data.ok_or(AppError::BadRequest("Missing signature".into()))?;

    let cert = Cert::from_file("/data/gnupg/public.asc")?;

    let helper = Helper { cert: &cert };
    let mut verifier = DetachedVerifierBuilder::from_bytes(&sig_data)?.with_policy(&Default::default(), None, helper)?;
    verifier.write_all(&file_data)?;
    verifier.finalize()?;

    Ok(Json(json!({ "verified": true })))
}

struct Helper<'a> {
    cert: &'a Cert,
}

impl<'a> VerificationHelper for Helper<'a> {
    fn get_certs(&mut self, _: &[KeyHandle]) -> Result<Vec<Cert>, sequoia_openpgp::Error> {
        Ok(vec![self.cert.clone()])
    }

    fn check(&mut self, _: MessageStructure) -> Result<(), sequoia_openpgp::Error> {
        Ok(())
    }
}
