use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use std::fmt::{Display, Formatter, Result as FmtResult};
use std::io;

#[derive(Debug)]
pub struct AppError {
    pub message: String,
    pub code: StatusCode,
}

impl AppError {
    pub fn new(message: &str, code: StatusCode) -> Self {
        Self {
            message: message.to_string(),
            code,
        }
    }

    pub fn message(msg: &str) -> Self {
        Self::new(msg, StatusCode::BAD_REQUEST)
    }
}

impl From<io::Error> for AppError {
    fn from(err: io::Error) -> Self {
        AppError::new(&err.to_string(), StatusCode::INTERNAL_SERVER_ERROR)
    }
}

impl From<anyhow::Error> for AppError {
    fn from(err: anyhow::Error) -> Self {
        AppError::new(&err.to_string(), StatusCode::INTERNAL_SERVER_ERROR)
    }
}

impl Display for AppError {
    fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
        write!(f, "{}", self.message)
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        (self.code, self.message).into_response()
    }
} 
