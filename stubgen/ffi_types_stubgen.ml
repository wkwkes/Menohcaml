module Ffi_bindings = Menohcaml_bindings.Ffi_bindings

let prefix = "menohcaml_stub"
let c_header = "#include <menoh/menoh.h>"
let () =
  print_endline c_header;
  Cstubs.Types.write_c Format.std_formatter (module Ffi_bindings.Types)