mod middleware;
mod routes;

use axum::{
    routing::{get, post},
    Router,
};
use routes::{decrypt, encrypt, key_import, keys, sign, verify};
use std::net::SocketAddr;
use tower_http::trace::TraceLayer;
use tracing_subscriber;

#[tokio::main]
async fn main() {
    dotenv::dotenv().ok();
    tracing_subscriber::fmt::init();

    let port: u16 = std::env::var("SIGMA_PORT")
        .unwrap_or_else(|_| "34998".into())
        .parse()
        .expect("Invalid SIGMA_PORT");

    let app = Router::new()
        .route("/sign", post(sign::sign))
        .route("/verify", post(verify::verify))
        .route("/encrypt", post(encrypt::encrypt))
        .route("/decrypt", post(decrypt::decrypt))
        .route("/keys/list", get(keys::list_keys))
        .route("/keys/import", post(key_import::import_key))
        .layer(TraceLayer::new_for_http());

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    println!("Listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
