open Core.Std

type cfg = {
  server : Bistro_client.cfg ;
  db_path : string ;
  workdir : string option ;
  np : int ;
  mem : int ;
}

let run cfg =
  Lwt.return ()

let main host port db_path np mem workdir () =
  let cfg = {
    server = Bistro_client.{ host ; port } ;
    db_path ;
    workdir ;
    np ;
    mem ;
  }
  in
  Lwt_unix.run (run cfg)

let spec =
  let open Command.Spec in
  empty
  +> flag "--host"     (required string) ~doc:"ADDR Address of a bistro server"
  +> flag "--port"     (required int)    ~doc:"PORT Port of the server"
  +> flag "--bistrodb" (required string) ~doc:"DIR Path of the server's database"
  +> flag "--np"       (required int)    ~doc:"INT Number of available processors"
  +> flag "--mem"      (required int)    ~doc:"INT Available memory (in GB)"
  +> flag "--workdir"  (optional string) ~doc:"DIR Scratch directory"

let command =
  Command.basic
    ~summary:"Bistro worker"
    spec
    main

let () = Command.run ~version:"0.1" command

