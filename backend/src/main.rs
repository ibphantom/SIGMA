mod routes;

use axum::{
    routing::{get, post},
    Router,
};
use routes::{decrypt, encrypt, key_import, keys, sign, verify, auth::auth};
use std::net::SocketAddr;
use tower_http::{
    trace::TraceLayer,
    cors::{CorsLayer, Any},
};
use tracing_subscriber;

#[tokio::main]
async fn main() {
    dotenv::dotenv().ok();
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/api/sign", post(sign::sign))
        .route("/api/verify", post(verify::verify))
        .route("/api/encrypt", post(encrypt::encrypt))
        .route("/api/decrypt", post(decrypt::decrypt))
        .route("/api/keys/list", get(keys::list_keys))
        .route("/api/keys/import", post(key_import::import_key))
        .route("/api/auth", post(auth))
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        )
        .layer(TraceLayer::new_for_http());

    let addr = SocketAddr::from(([0, 0, 0, 0], 34998));
    println!("Listening on http://{}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
