import gleam/bytes_builder.{type BytesBuilder}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}

pub fn my_service(_request: Request(t)) -> Response(BytesBuilder) {
  let body = bytes_builder.from_string("aaaa world!")

  response.new(200)
  |> response.prepend_header("made-with", "Gleam")
  |> response.set_body(body)
}
