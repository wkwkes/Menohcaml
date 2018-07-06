module Ffi_bindings = Menohcaml_bindings.Ffi_bindings

let prefix = "menoh_stub"

(* let c_header = "#include <menoh/menoh.h>" *)
let c_header = "#include <menoh/menoh.h>"

let () =
  let generate_ml, generate_c = ref false, ref false in
  let () =
    Arg.(parse [ ("-ml", Set generate_ml, "Generate ML");
                 ("-c", Set generate_c, "Generate C") ])
      (fun _ -> failwith "unexpected anonymous argument")
      "stubgen [-ml|-c]"
  in
  match !generate_ml, !generate_c with
  | false, false
  | true, true ->
    failwith "Exactly one of -ml and -c must be specified"
  | true, false ->
    Cstubs.write_ml Format.std_formatter ~prefix (module Ffi_bindings.Bindings)
  | false, true ->
    print_endline c_header;
    Cstubs.write_c Format.std_formatter ~prefix (module Ffi_bindings.Bindings)
