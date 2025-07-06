pub mod middleware;
pub mod routes;

use routes::{sign, verify, encrypt, decrypt, keys, key_import};
use middleware::auth::Auth;

let app = Router::new()
    .route("/sign", post(sign::sign))
    .route("/verify", post(verify::verify))
    .route("/encrypt", post(encrypt::encrypt))
    .route("/decrypt", post(decrypt::decrypt))
    .route("/keys/list", get(keys::list_keys))
    .route("/keys/import", post(key_import::import_key).layer(axum::middleware::from_fn(auth)))
    .layer(TraceLayer::new_for_http());
