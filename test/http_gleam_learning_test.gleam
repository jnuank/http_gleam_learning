import gleeunit
import gleeunit/should
import gleam/function
import mockth

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn mock_test() {

  let assert Ok(_) =
    mockth.expect("gleam@function", "identity", fn(a) { case a { "world" -> "hello" _ -> panic as "not expected value" } })

  mockth.validate("gleam@function")
  |> should.equal(True)

  mockth.mocked()
  |> should.equal(["gleam@function"])

  function.identity("world")
  |> should.equal("hello")

  mockth.unload_all()


}
