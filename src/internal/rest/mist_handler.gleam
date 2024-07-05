import gleam/erlang/process
import gleam/otp/actor
import gleam/option.{None, Some}
import gleam/io
import gleam/result
import gleam/iterator

import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import gleam/bytes_builder

pub fn handler(req: Request(Connection)) -> Response(ResponseData) {

	let selector = process.new_selector()
	let state = Nil

	let not_found =
		response.new(404)
		|> response.set_body(mist.Bytes(bytes_builder.new()))


	req
	|> io.debug
	|> request.path_segments
	|> io.debug

	case request.path_segments(req) {
		["ws"] -> 
			mist.websocket(
				request: req,
				on_init: fn(_con) { #(state, Some(selector))},
				on_close: fn(_state) { io.println("goodbye!")},
				handler: handle_ws_message
			)
		["echo"] -> echo_body(req)
		["chunk"] -> serve_chunk(req)
		_ -> echo_req(req)
	}

}

fn serve_chunk(_request: Request(Connection)) -> Response(ResponseData) {

	let iter = 
		["one", "two", "three"]
		|> iterator.from_list
		|> iterator.map(bytes_builder.from_string)
		|> io.debug

	response.new(200)
	|> response.set_body(mist.Chunked(iter))
	|> response.set_header("content-type", "text/plain")
}

fn echo_req(request: Request(Connection)) -> Response(ResponseData) {

	mist.read_body(request, 1024 * 1024 * 10)
	|> result.map(fn(req) {
		response.new(200)
		|> response.set_body(mist.Bytes(bytes_builder.from_string(req.path)))
	})
	|> result.lazy_unwrap(fn() {
		response.new(400)
		|> response.set_body(mist.Bytes(bytes_builder.new()))
	})
} 

fn echo_body(request: Request(Connection)) -> Response(ResponseData) {
	let content_type = 
		request
		|> request.get_header("content-type")
		|> result.unwrap("text/plain")
	
	mist.read_body(request, 1024 * 1024 * 10)
	|> result.map(fn(req) {
		response.new(200)
		|> response.set_body(mist.Bytes(bytes_builder.from_bit_array(req.body)))
		|> response.set_header("content-type", content_type)
	})
	|> result.lazy_unwrap(fn() {
		response.new(400)
		|> response.set_body(mist.Bytes(bytes_builder.new()))
	})
}

pub type MyMessage { 
	Broadcast(String)
}

fn handle_ws_message(state, conn, message) {
	case message {
		mist.Text("ping") -> {
			let assert Ok(_) = mist.send_text_frame(conn, "pong")
			actor.continue(state)
		}
		mist.Text(_) | mist.Binary(_) -> {
			actor.continue(state)
		}
		mist.Custom(Broadcast(text)) -> {
			let assert Ok(_) = mist.send_text_frame(conn, text)
			actor.continue(state)
		}
		mist.Closed | mist.Shutdown -> actor.Stop(process.Normal)
	}
}