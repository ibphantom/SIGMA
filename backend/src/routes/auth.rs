use axum::http::request::Parts;
use axum::extract::FromRequestParts;
use async_trait::async_trait;
use axum::http::StatusCode;

#[derive(Debug)]
pub struct Auth;

#[async_trait]
impl<S> FromRequestParts<S> for Auth
where
    S: Send + Sync,
{
    type Rejection = StatusCode;

    async fn from_request_parts(_parts: &mut Parts, _state: &S) -> Result<Self, Self::Rejection> {
        // Placeholder: allow all for now
        Ok(Auth)
    }
}
