use axum::{http::StatusCode, response::IntoResponse};

pub async fn sign_handler() -> impl IntoResponse {
    (StatusCode::OK, "Sign endpoint hit")
}
