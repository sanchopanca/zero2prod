use std::net::TcpListener;

use actix_web::{dev::Server, web, App, HttpServer};

use crate::routes::{health_check, subscribe};

pub fn run(listener: TcpListener) -> std::io::Result<Server> {
    let server = HttpServer::new(|| {
        App::new()
            .route("/health_check", web::get().to(health_check))
            .route("/subscriptions", web::post().to(subscribe))
    })
    .listen(listener)?
    .run();

    Ok(server)
}
