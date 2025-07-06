use axum::{http::Request, middleware::Next, response::Response};
use axum::http::StatusCode;

pub async fn auth_layer<B>(req: Request<B>, next: Next<B>) -> Result<Response, StatusCode> {
    if let Some(auth_header) = req.headers().get("Authorization") {
        if auth_header == "Bearer your_api_token_here" {
            return Ok(next.run(req).await);
        }
    }

    Err(StatusCode::UNAUTHORIZED)
}
