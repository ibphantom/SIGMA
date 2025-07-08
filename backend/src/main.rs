use axum::{
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use tower_http::cors::CorsLayer;

#[derive(Serialize, Deserialize)]
struct SignRequest {
    message: String,
}

#[derive(Serialize, Deserialize)]
struct SignResponse {
    signature: String,
}

async fn sign_message(Json(payload): Json<SignRequest>) -> Json<SignResponse> {
    // Placeholder - implement actual signing with sequoia-openpgp
    Json(SignResponse {
        signature: format!("SIGNED: {}", payload.message),
    })
}

async fn health_check() -> StatusCode {
    StatusCode::OK
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/health", get(health_check))
        .route("/sign", post(sign_message))
        .layer(CorsLayer::permissive());

    println!("Server running on http://0.0.0.0:8080");
    
    axum::Server::bind(&"0.0.0.0:8080".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
