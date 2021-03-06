open Sexplib.Std
open Bistro_engine


type token = string
  [@@deriving sexp]

type task = {
  task_id : string ;
  task_step : Bistro.Workflow.step
}
  [@@deriving sexp]

type _ request =
  | Request_task : unit -> task option request
  | I'm_alive  : token -> unit request
  | Post_wave  : Db.Wave.t -> unit request

type 'b request_handler = {
  f : 'a. 'a request -> 'b
}

module Message = struct
  type t =
    | Request_id
    | I'm_alive of token
    | Post_wave of Db.Wave.t
  [@@deriving sexp]

end

let message_of_request
  : type a. a request -> Message.t =
  function
  | Request_task () -> Message.Request_id
  | I'm_alive id -> Message.I'm_alive id
  | Post_wave w -> Message.Post_wave w

let request_of_message
  : 'b request_handler -> Message.t -> 'b
  = fun h ->
    function
    | Message.Request_id -> h.f (Request_task ())
    | Message.I'm_alive id -> h.f (I'm_alive id)
    | Message.Post_wave w -> h.f (Post_wave w)

let response_serializer
  : type a. a request -> a -> Sexplib.Sexp.t
  = function
    | Request_task _ -> [%sexp_of: task option]
    | I'm_alive _ -> sexp_of_unit
    | Post_wave _ -> sexp_of_unit

let response_deserializer
  : type a. a request -> Sexplib.Sexp.t -> a
  = function
    | Request_task _ -> [%of_sexp: task option]
    | I'm_alive _ -> unit_of_sexp
    | Post_wave _ -> unit_of_sexp
