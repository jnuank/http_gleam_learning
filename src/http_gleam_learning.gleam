import gleam/http/elli

import internal/rest/example_handler



pub fn main() {
  elli.become(example_handler.my_service, 3000)
}
