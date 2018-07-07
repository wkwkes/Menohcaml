open Ctypes

module Types = Menohcaml_bindings.Ffi_bindings.Types(Ffi_generated_types)
module Bindings = Menohcaml_bindings.Ffi_bindings.Bindings(Ffi_generated)

open Types
open Bindings

type nonrec menoh_dtype = menoh_dtype
let menoh_dtype_float = menoh_dtype_float

module Menoh_error = struct 
  type t =
    | Success
    | Std_error
    | Unknown_error
    | Invalid_filename
    | Unsupported_onnx_opset_version
    | Onnx_parse_error
    | Invalid_dtype
    | Invalid_attribute_type
    | Unsupported_operator_attribute
    | Dimension_mismatch
    | Variable_not_found
    | Index_out_of_range
    | Json_parse_error
    | Invalid_backend_name
    | Unsupported_operator
    | Failed_to_configure_operator
    | Backend_error
    | Same_named_variable_already_exist
    | Others
    [@@deriving show]

  exception Menoh_error of string

  let of_int32 = let open Types.Menoh_error in function
      | x when x = success -> Success
      | x when x = std_error -> Std_error
      | x when x = unknown_error -> Unknown_error
      | x when x = invalid_filename -> Invalid_filename
      | x when x = unsupported_onnx_opset_version -> Unsupported_onnx_opset_version
      | x when x = onnx_parse_error -> Onnx_parse_error
      | x when x = invalid_dtype -> Invalid_dtype
      | x when x = invalid_attribute_type -> Invalid_attribute_type
      | x when x = unsupported_operator_attribute -> Unsupported_operator_attribute
      | x when x = dimension_mismatch -> Dimension_mismatch
      | x when x = variable_not_found -> Variable_not_found
      | x when x = index_out_of_range -> Index_out_of_range
      | x when x = json_parse_error -> Json_parse_error
      | x when x = invalid_backend_name -> Invalid_backend_name
      | x when x = unsupported_operator -> Unsupported_operator
      | x when x = failed_to_configure_operator -> Failed_to_configure_operator
      | x when x = backend_error -> Backend_error
      | x when x = same_named_variable_already_exist -> Same_named_variable_already_exist
      | e -> Others

  let error_check f = match of_int32 (f ()) with
    | Others | Success -> ()
    | e -> raise @@ Menoh_error (Printf.sprintf "%s : %s" (show e) (menoh_get_last_error_message()))
end

open Menoh_error

let get_handle ty_h ty_t = allocate ty_h (from_voidp ty_t null)

module Model_data : sig
  type h (* handler *) = menoh_model_data_handle
  val make_from_onnx : string -> h
  val delete : h -> unit
end = struct
  type h = menoh_model_data_handle
  let make_from_onnx p =  
    let h = get_handle menoh_model_data_handle menoh_model_data in
    error_check (fun () -> menoh_make_model_data_from_onnx p h); !@ h
  let delete h = menoh_delete_model_data h
end

module Vpt_builder : sig 
  type h = menoh_variable_profile_table_builder_handle
  val make : unit -> h
  val delete : h -> unit
  val add_input_profile_dims_2 : h -> string -> int32 -> int32 -> int32 -> unit
  val add_input_profile_dims_4 : h -> string -> menoh_dtype -> int32 -> int32 -> int32 -> int32 -> unit
  val add_output_profile : h -> string -> menoh_dtype -> unit
end = struct 
  type h = menoh_variable_profile_table_builder_handle
  let make () = 
    let h = get_handle menoh_variable_profile_table_builder_handle menoh_variable_profile_table_builder in
    error_check (fun () -> menoh_make_variable_profile_table_builder h); (!@ h)
  let delete h = menoh_delete_variable_profile_table_builder h
  let add_input_profile_dims_2 h name dtype num size = 
    error_check (fun () -> menoh_variable_profile_table_builder_add_input_profile_dims_2 h name dtype num size) 
  let add_input_profile_dims_4 h name dtype num channel height width =
    error_check (fun () -> menoh_variable_profile_table_builder_add_input_profile_dims_4 h name dtype num channel height width)
  let add_output_profile h name dtype = 
    error_check (fun () -> menoh_variable_profile_table_builder_add_output_profile h name dtype)
end

module Vpt : sig
  type h = menoh_variable_profile_table_handle
  val build : Vpt_builder.h -> Model_data.h -> h 
  val delete : h -> unit
  val get_dtype : h -> string -> menoh_dtype
  val get_dims_size : h -> string -> int32
  val get_dims_at : h -> string -> int32 -> int32
end = struct 
  type h = menoh_variable_profile_table_handle
  let build vptb_h md_h = 
    let h = get_handle menoh_variable_profile_table_handle menoh_variable_profile_table in
    error_check (fun () -> menoh_build_variable_profile_table vptb_h md_h h); (!@ h)
  let delete h = menoh_delete_variable_profile_table h
  let get_dtype h vname = 
    let dst_dtype = allocate int32_t 0l in
    error_check (fun () -> menoh_variable_profile_table_get_dtype h vname dst_dtype); (!@ dst_dtype)
  let get_dims_size h vname =
    let dst_size = allocate int32_t 0l in 
    error_check (fun () -> menoh_variable_profile_table_get_dims_size h vname dst_size); (!@ dst_size)
  let get_dims_at h vname index =
    let dst_size = allocate int32_t 0l in 
    error_check (fun () -> menoh_variable_profile_table_get_dims_at h vname index dst_size); (!@ dst_size)
end

let optimize : Model_data.h -> Vpt.h -> unit = 
  fun mh vh -> error_check (fun () -> menoh_model_data_optimize mh vh)

module Model_builder : sig 
  type h = menoh_model_builder_handle
  val make : Vpt.h -> h
  val delete : h -> unit
  val attach_external_buffer : h -> string -> unit ptr -> unit
end = struct
  type h = menoh_model_builder_handle
  let make vpt_h = 
    let h = get_handle menoh_model_builder_handle menoh_model_builder in
    error_check (fun () -> menoh_make_model_builder vpt_h h); (!@ h)
  let delete h = menoh_delete_model_builder h
  let attach_external_buffer h vname buffer_handle =
    error_check (fun () -> menoh_model_builder_attach_external_buffer h vname buffer_handle)
end

module Model : sig 
  type h = menoh_model_handle
  val build : Model_builder.h -> Model_data.h -> string -> string -> h
  val delete : h -> unit
  val get_variable_buffer_handle : h -> string -> unit ptr
  val get_variable_dtype : h -> string -> int32
  val get_variable_dims_size : h -> string -> int32
  val get_variable_dims_at : h -> string -> int32 -> int32
  val run : h -> unit
end = struct 
  type h = menoh_model_handle
  let build mb_h md_h bname bconf =
    let h = get_handle menoh_model_handle menoh_model in
    error_check (fun () -> menoh_build_model mb_h md_h bname bconf h); (!@ h)
  let delete h = menoh_delete_model h
  let get_variable_buffer_handle h vname =
    let dst_data = allocate (ptr void) (from_voidp void null) in
    error_check (fun () -> menoh_model_get_variable_buffer_handle h vname dst_data);
    (!@ dst_data)
  let get_variable_dtype h vname =
    let dst_type = allocate int32_t 0l in
    error_check (fun () -> menoh_model_get_variable_dtype h vname dst_type); (!@ dst_type)
  let get_variable_dims_size h vname =
    let dst_size = allocate int32_t 0l in
    error_check (fun () -> menoh_model_get_variable_dims_size h vname dst_size); (!@ dst_size)
  let get_variable_dims_at h vname index =
    let dst_size = allocate int32_t 0l in
    error_check (fun () -> menoh_model_get_variable_dims_at h vname index dst_size); (!@ dst_size)
  let run h = error_check (fun () -> menoh_model_run h)
end

module Ctypes = Ctypes