use axum::{extract::Multipart, response::{IntoResponse, Response}, routing::post, Json, Router};
use axum::http::{header, StatusCode};
use sequoia_openpgp::{serialize::stream::Signer, Cert};
use std::{fs::File, io::{BufReader, Cursor, Write}, path::PathBuf};
use crate::error::AppError;

pub async fn sign(mut multipart: Multipart) -> Result<impl IntoResponse, AppError> {
    let mut file_bytes = Vec::new();

    while let Some(field) = multipart.next_field().await.map_err(|_| AppError::BadRequest)? {
        let data = field.bytes().await.map_err(|_| AppError::BadRequest)?;
        file_bytes.extend(data);
    }

    let cert_path = PathBuf::from("/data/gnupg/private.asc");
    let file = File::open(cert_path).map_err(|_| AppError::InternalError)?;
    let cert = Cert::from_reader(BufReader::new(file)).map_err(|_| AppError::InternalError)?;

    let mut output = Vec::new();
    let signer = Signer::new(&cert).build(&mut output).map_err(|_| AppError::InternalError)?;
    signer.write_all(&file_bytes).map_err(|_| AppError::InternalError)?;
    signer.finalize().map_err(|_| AppError::InternalError)?;

    let sig_name = "output.sig";
    let response = Response::builder()
        .status(StatusCode::OK)
        .header(header::CONTENT_TYPE, "application/pgp-signature")
        .header(header::CONTENT_DISPOSITION, format!("attachment; filename=\"{}\"", sig_name))
        .body(axum::body::Body::from(output))
        .map_err(|_| AppError::InternalError)?;

    Ok(response)
}

pub fn routes() -> Router {
    Router::new().route("/sign", post(sign))
}
