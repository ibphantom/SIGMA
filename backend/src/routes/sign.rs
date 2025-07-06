use axum::{extract::Multipart, response::{IntoResponse, Response}, routing::post, Router};
use axum::http::{header, StatusCode};
use sequoia_openpgp::{serialize::stream::Signer, Cert};
use std::{fs::File, io::{BufReader, Cursor, Write}, path::PathBuf};

pub async fn sign(mut multipart: Multipart) -> impl IntoResponse {
    let mut file_bytes = Vec::new();

    while let Some(field) = multipart.next_field().await.unwrap() {
        let data = field.bytes().await.unwrap();
        file_bytes.extend(data);
    }

    let cert_path = PathBuf::from("/data/gnupg/private.asc");
    let file = File::open(cert_path).unwrap();
    let cert = Cert::from_reader(BufReader::new(file)).unwrap();

    let mut output = Vec::new();
    let signer = Signer::new(&cert).build(&mut output).unwrap();
    signer.write_all(&file_bytes).unwrap();
    signer.finalize().unwrap();

    let sig_name = "output.sig";
    let response = Response::builder()
        .status(StatusCode::OK)
        .header(header::CONTENT_TYPE, "application/pgp-signature")
        .header(header::CONTENT_DISPOSITION, format!("attachment; filename=\"{}\"", sig_name))
        .body(axum::body::Body::from(output))
        .unwrap();

    response
}

pub fn routes() -> Router {
    Router::new().route("/sign", post(sign))
}
