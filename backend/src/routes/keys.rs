use axum::{http::StatusCode, response::IntoResponse};
use tracing::info;

pub async fn list_keys_handler() -> impl IntoResponse {
    info!("Hit /keys/list endpoint");
    (StatusCode::OK, "List keys endpoint is live")
}
