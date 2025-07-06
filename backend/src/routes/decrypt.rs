use axum::{extract::Multipart, response::IntoResponse, routing::post, Json, Router};
use sequoia_openpgp::{parse::stream::DecryptorBuilder, Cert, Result};
use std::fs::File;
use std::io::{BufReader, Cursor};
use std::path::PathBuf;

pub async fn decrypt(mut multipart: Multipart) -> impl IntoResponse {
    let mut enc_bytes = Vec::new();

    while let Some(field) = multipart.next_field().await.unwrap() {
        let data = field.bytes().await.unwrap();
        enc_bytes.extend(data);
    }

    let cert_path = PathBuf::from("/data/gnupg/private.asc");
    let file = File::open(cert_path).unwrap();
    let cert = Cert::from_reader(BufReader::new(file)).unwrap();

    let decryptor = DecryptorBuilder::from_bytes(&enc_bytes).unwrap().with_policy(&sequoia_openpgp::policy::StandardPolicy, None, None).unwrap();
    let mut decrypted = Vec::new();
    std::io::copy(&mut decryptor, &mut decrypted).unwrap();

    Json(String::from_utf8_lossy(&decrypted).to_string())
}

pub fn routes() -> Router {
    Router::new().route("/decrypt", post(decrypt))
}
