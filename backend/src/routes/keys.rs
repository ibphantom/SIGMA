use axum::{http::StatusCode, response::IntoResponse};

pub async fn list_keys_handler() -> impl IntoResponse {
    (StatusCode::OK, "List keys endpoint hit")
}
