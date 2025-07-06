use axum::{extract::Multipart, response::IntoResponse, routing::post, Json, Router};
use sequoia_openpgp::{serialize::stream::Encryptor, Cert, Result};
use std::fs::File;
use std::io::{BufReader, Write};
use std::path::PathBuf;

pub async fn encrypt(mut multipart: Multipart) -> impl IntoResponse {
    let mut file_bytes = Vec::new();

    while let Some(field) = multipart.next_field().await.unwrap() {
        let data = field.bytes().await.unwrap();
        file_bytes.extend(data);
    }

    // Load recipient key (example: hardcoded path for now)
    let cert_path = PathBuf::from("/data/gnupg/public.asc");
    let f = File::open(cert_path).unwrap();
    let cert = Cert::from_reader(BufReader::new(f)).unwrap();

    let mut output = Vec::new();
    let message = Encryptor::for_recipients(&[&cert])
        .build(&mut output)
        .unwrap();
    let mut sink = message;
    sink.write_all(&file_bytes).unwrap();
    sink.finalize().unwrap();

    Json(String::from_utf8_lossy(&output).to_string())
}

pub fn routes() -> Router {
    Router::new().route("/encrypt", post(encrypt))
}
