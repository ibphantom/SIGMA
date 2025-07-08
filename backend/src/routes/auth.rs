use axum::{Json, response::IntoResponse};
use serde::{Deserialize, Serialize};
use crate::routes::error::AppError;

#[derive(Debug, Deserialize)]
pub struct AuthRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct AuthResponse {
    pub success: bool,
    pub token: Option<String>,
    pub message: String,
}

pub async fn auth(Json(payload): Json<AuthRequest>) -> Result<impl IntoResponse, AppError> {
    if payload.username == "admin" && payload.password == "admin" {
        let token = "mock-token-123";
        Ok(Json(AuthResponse {
            success: true,
            token: Some(token.to_string()),
            message: "Authentication successful".into(),
        }))
    } else {
        Ok(Json(AuthResponse {
            success: false,
            token: None,
            message: "Invalid credentials".into(),
        }))
    }
}
