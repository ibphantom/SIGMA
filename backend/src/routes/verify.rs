use axum::{http::StatusCode, response::IntoResponse};

pub async fn verify_handler() -> impl IntoResponse {
    (StatusCode::OK, "Verify endpoint hit")
}
