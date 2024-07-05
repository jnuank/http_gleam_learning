import gleam/erlang/process
import gleam/http/elli
import internal/rest/example_handler
import internal/rest/mist_handler
import mist.{type Connection, type ResponseData}

pub fn main() {
  // Okじゃなかったら
  let assert Ok(_) =
    mist_handler.handler
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}
