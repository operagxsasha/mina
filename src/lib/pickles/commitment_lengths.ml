open Kimchi_backend_types

let default ~num_chunks =
  { Kimchi_backend_common.Plonk_types.Messages.Poly.w =
      Vector.init Kimchi_backend_common.Plonk_types.Columns.n ~f:(fun _ -> num_chunks)
  ; z = num_chunks
  ; t = 7 * num_chunks
  }
