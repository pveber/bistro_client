open Core_kernel.Std
open Rresult
open Bistro_client_api
open Lwt
open Cohttp
open Cohttp_lwt_unix

type 'a result = ('a, R.msg) Rresult.result

type cfg = {
  host : string ;
  port : int
}

let make_uri { host ; port } path query =
  let path = String.concat ~sep:"/" path in
  Uri.make ~scheme:"http" ~host ~port ~path ~query ()

let call
  : cfg -> 'a request -> 'a result Lwt.t
  = fun cfg req ->
    let msg = message_of_request req in
    let body =
      Message.sexp_of_t msg
      |> Sexp.to_string_hum
      |> Cohttp_lwt_body.of_string
    in
    let uri = make_uri cfg [ "api" ] [] in
    Client.post ~body uri >>= fun (resp, body) ->
    match resp.Response.status with
    | `OK ->
      Cohttp_lwt_body.to_string body
      >|= Sexp.of_string
      >|= response_deserializer req
      >|= R.ok
    | code ->
      Cohttp_lwt_body.to_string body >|= fun body ->
      R.error_msgf
        "post_wave failed with error %s and body %s"
        (Code.string_of_status code)
        body

