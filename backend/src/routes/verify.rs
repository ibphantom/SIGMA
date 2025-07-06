use axum::{http::StatusCode, response::IntoResponse};
use tracing::info;

pub async fn verify_handler() -> impl IntoResponse {
    info!("Hit /verify endpoint");
    (StatusCode::OK, "Verify endpoint is live")
}
