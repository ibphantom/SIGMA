use axum::{http::StatusCode, response::IntoResponse};
use tracing::info;

pub async fn sign_handler() -> impl IntoResponse {
    info!("Hit /sign endpoint");
    (StatusCode::OK, "Sign endpoint is live")
}
