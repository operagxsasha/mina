(* Cache proofs using the lmdb *)

open Core
open Lmdb_storage.Generic

type value = Pickles.Proof.Proofs_verified_2.t

module F (Db : Db) = struct
  type holder = (int, Bigstring.t) Db.t

  let mk_maps { Db.create } =
    create Lmdb_storage.Conv.uint32_be Lmdb.Conv.bigstring

  let config = { default_config with initial_mmap_size = 1 lsl 20 }
end

module Rw = Read_write (F)
module Ro = Read_only (F)

let counter = ref 0

let db_dir = ".mina-config" ^ "/" ^ "lm_cache.db"

type t = { idx : int } [@@deriving compare, equal, sexp, yojson, hash]

let unwrap ({ idx = x } : t) : value =
  (* Read from the db. *)
  let env, db = Ro.create db_dir in
  Ro.get ~env db x |> Option.value_exn
  |> Binable.of_bigstring (module Pickles.Proof.Proofs_verified_2.Stable.Latest)

let generate (x : value) : t =
  let env, db = Rw.create db_dir in
  let new_counter = !counter in
  incr counter ;
  let res = { idx = new_counter } in
  Rw.set ~env db new_counter
    (Binable.to_bigstring
       (module Pickles.Proof.Proofs_verified_2.Stable.Latest)
       x ) ;
  res
