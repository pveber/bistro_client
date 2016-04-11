open Rresult
open Bistro_client_api

type 'a result = ('a, R.msg) Rresult.result

type cfg = {
  host : string ;
  port : int
}

val call : cfg -> 'a request -> 'a result Lwt.t
