import gleam/io
import gleam/http/elli
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/bytes_builder.{type BytesBuilder}

pub fn my_service(_request: Request(t)) -> Response(BytesBuilder) {
  let body = bytes_builder.from_string("Hello, world!")

  response.new(200)
  |> response.prepend_header("made-with", "Gleam")
  |> response.set_body(body)
}


pub fn main() {
  elli.become(my_service, 3000)
}
