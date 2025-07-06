use axum::{async_trait, extract::FromRequestParts, http::request::Parts, response::IntoResponse};
use axum::http::StatusCode;
use std::env;

pub struct Auth;

#[async_trait]
impl<S> FromRequestParts<S> for Auth
where
    S: Send + Sync,
{
    type Rejection = (StatusCode, String);

    async fn from_request_parts(parts: &mut Parts, _state: &S) -> Result<Self, Self::Rejection> {
        let auth_header = parts
            .headers
            .get("Authorization")
            .and_then(|h| h.to_str().ok())
            .ok_or((StatusCode::UNAUTHORIZED, "Missing Authorization header".to_string()))?;

        let expected_token = env::var("AUTH_TOKEN").unwrap_or_default();

        if auth_header == format!("Bearer {}", expected_token) {
            Ok(Auth)
        } else {
            Err((StatusCode::UNAUTHORIZED, "Invalid token".to_string()))
        }
    }
}
