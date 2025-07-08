use axum::{
    routing::{get, post},
    Router, Json, extract::Multipart, http::StatusCode,
};
use std::net::SocketAddr;
use tower_http::services::ServeDir;

mod routes;
use routes::{
    sign::sign,
    verify::verify,
    encrypt::encrypt,
    decrypt::decrypt,
    keys::list_keys,
    key_import::import_key,
    auth::auth,
    error::AppError,
};

#[tokio::main]
async fn main() -> Result<(), AppError> {
    let app = Router::new()
        .route("/api/sign", post(sign))
        .route("/api/verify", post(verify))
        .route("/api/encrypt", post(encrypt))
        .route("/api/decrypt", post(decrypt))
        .route("/api/keys", get(list_keys))
        .route("/api/import-key", post(import_key))
        .route("/api/auth", post(auth))
        .nest_service("/", ServeDir::new("/dist").append_index_html_on_directories(true));

    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    println!("Listening on http://{}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await?;

    Ok(())
}
