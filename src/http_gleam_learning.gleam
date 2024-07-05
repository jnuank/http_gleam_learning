import gleam/http/elli
import internal/rest/example_handler
import mist.{type Connection, type ResponseData}
import internal/rest/mist_handler
import gleam/erlang/process



pub fn main() {
  // Okじゃなかったら
  let assert Ok(_) = mist_handler.handler
  |> mist.new
  |> mist.port(3000)
  |> mist.start_http

  process.sleep_forever()
}
