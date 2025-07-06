use axum::{routing::post, Router};
use std::net::SocketAddr;

mod routes;
use routes::{sign::sign_handler, verify::verify_handler, keys::list_keys_handler};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/sign", post(sign_handler))
        .route("/verify", post(verify_handler))
        .route("/keys/list", post(list_keys_handler));

    let addr = SocketAddr::from(([0, 0, 0, 0], 8000));
    println!("Server running at http://{}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
} 
