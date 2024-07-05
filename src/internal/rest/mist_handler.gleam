import gleam/erlang/process
import gleam/otp/actor
import gleam/option.{None, Some}
import gleam/io

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

	case request.path_segments(req) {
		["ws"] -> 
			mist.websocket(
				request: req,
				on_init: fn(_con) { #(state, Some(selector))},
				on_close: fn(_state) { io.println("goodbye!")},
				handler: handle_ws_message
			)
		_ -> not_found
	}

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