open Ctypes

module Types (F : Cstubs.Types.TYPE) = struct
  open F
  type menoh_dtype = int32
  let menoh_dtype_float = constant "menoh_dtype_float" int32_t

  module Menoh_error = struct 
    let success = constant "menoh_error_code_success" int32_t
    let std_error = constant "menoh_error_code_std_error" int32_t    
    let unknown_error = constant "menoh_error_code_unknown_error" int32_t 
    let invalid_filename = constant "menoh_error_code_invalid_filename" int32_t 
    let unsupported_onnx_opset_version = constant "menoh_error_code_unsupported_onnx_opset_version" int32_t 
    let onnx_parse_error = constant "menoh_error_code_onnx_parse_error" int32_t 
    let invalid_dtype = constant "menoh_error_code_invalid_dtype" int32_t 
    let invalid_attribute_type = constant "menoh_error_code_invalid_attribute_type" int32_t 
    let unsupported_operator_attribute = constant "menoh_error_code_unsupported_operator_attribute" int32_t 
    let dimension_mismatch = constant "menoh_error_code_dimension_mismatch" int32_t 
    let variable_not_found = constant "menoh_error_code_variable_not_found" int32_t 
    let index_out_of_range = constant "menoh_error_code_index_out_of_range" int32_t 
    let json_parse_error = constant "menoh_error_code_json_parse_error" int32_t 
    let invalid_backend_name = constant "menoh_error_code_invalid_backend_name" int32_t 
    let unsupported_operator = constant "menoh_error_code_unsupported_operator" int32_t 
    let failed_to_configure_operator = constant "menoh_error_code_failed_to_configure_operator" int32_t 
    let backend_error = constant "menoh_error_code_backend_error" int32_t 
    let same_named_variable_already_exist = constant "menoh_error_code_same_named_variable_already_exist" int32_t 
  end
end

module Bindings (F : Ctypes.FOREIGN) = struct
  open F
  let menoh_dtype = int32_t
  let menoh_error_code = int32_t

  type _menoh_model_data
  type menoh_model_data = _menoh_model_data structure
  let menoh_model_data : menoh_model_data typ = structure "menoh_model_data"

  type menoh_model_data_handle = menoh_model_data ptr
  let menoh_model_data_handle : menoh_model_data_handle typ = ptr menoh_model_data

  type _menoh_variable_profile_table_builder
  type menoh_variable_profile_table_builder = _menoh_variable_profile_table_builder structure
  let menoh_variable_profile_table_builder : menoh_variable_profile_table_builder typ = structure "menoh_variable_profile_table_builder" 
  type menoh_variable_profile_table_builder_handle = menoh_variable_profile_table_builder ptr
  let menoh_variable_profile_table_builder_handle : menoh_variable_profile_table_builder_handle typ = ptr menoh_variable_profile_table_builder

  type _menoh_variable_profile_table
  type menoh_variable_profile_table = _menoh_variable_profile_table structure
  let menoh_variable_profile_table : menoh_variable_profile_table typ = structure "menoh_variable_profile_table"
  type menoh_variable_profile_table_handle = menoh_variable_profile_table ptr
  let menoh_variable_profile_table_handle : menoh_variable_profile_table_handle typ = ptr menoh_variable_profile_table

  type _menoh_model_builder
  type menoh_model_builder = _menoh_model_builder structure
  let menoh_model_builder : menoh_model_builder typ = structure "menoh_model_builder"
  type menoh_model_builder_handle = menoh_model_builder ptr
  let menoh_model_builder_handle : menoh_model_builder_handle typ = ptr menoh_model_builder

  type _menoh_model
  type menoh_model = _menoh_model structure
  let menoh_model : menoh_model typ = structure "menoh_model"
  type menoh_model_handle = menoh_model ptr
  let menoh_model_handle : menoh_model_handle typ = ptr menoh_model

  let menoh_get_last_error_message = foreign "menoh_get_last_error_message" (void @-> returning string)

  let menoh_make_model_data_from_onnx = 
    foreign "menoh_make_model_data_from_onnx" (string @-> ptr menoh_model_data_handle @-> returning menoh_error_code)


  let menoh_delete_model_data = 
    foreign "menoh_delete_model_data" (menoh_model_data_handle @-> returning void)

  let menoh_make_variable_profile_table_builder =
    foreign "menoh_make_variable_profile_table_builder" (ptr menoh_variable_profile_table_builder_handle @-> returning menoh_error_code)

  let menoh_delete_variable_profile_table_builder =
    foreign "menoh_delete_variable_profile_table_builder" (menoh_variable_profile_table_builder_handle @-> returning void)

  let menoh_variable_profile_table_builder_add_input_profile_dims_2 =
    foreign "menoh_variable_profile_table_builder_add_input_profile_dims_2" (menoh_variable_profile_table_builder_handle @-> string @-> menoh_dtype @-> int32_t @-> int32_t @-> returning menoh_error_code)

  let menoh_variable_profile_table_builder_add_input_profile_dims_4 =
    foreign "menoh_variable_profile_table_builder_add_input_profile_dims_4" (menoh_variable_profile_table_builder_handle @-> string @-> menoh_dtype @-> int32_t @-> int32_t @-> int32_t @-> int32_t @-> returning menoh_error_code)

  let menoh_variable_profile_table_builder_add_output_profile =
    foreign "menoh_variable_profile_table_builder_add_output_profile" (menoh_variable_profile_table_builder_handle @-> string @-> menoh_dtype @-> returning menoh_error_code)

  let menoh_build_variable_profile_table =
    foreign "menoh_build_variable_profile_table" (menoh_variable_profile_table_builder_handle @-> menoh_model_data_handle @-> ptr menoh_variable_profile_table_handle @-> returning menoh_error_code)

  let menoh_delete_variable_profile_table =
    foreign "menoh_delete_variable_profile_table" (menoh_variable_profile_table_handle @-> returning void)

  let menoh_variable_profile_table_get_dtype =
    foreign "menoh_variable_profile_table_get_dtype" (menoh_variable_profile_table_handle @-> string @-> ptr menoh_dtype @-> returning menoh_error_code)

  let menoh_variable_profile_table_get_dims_size =
    foreign "menoh_variable_profile_table_get_dims_size" (menoh_variable_profile_table_handle @-> string @-> ptr int32_t @-> returning menoh_error_code)

  let menoh_variable_profile_table_get_dims_at =
    foreign "menoh_variable_profile_table_get_dims_at" (menoh_variable_profile_table_handle @-> string @-> int32_t @-> ptr int32_t @-> returning menoh_error_code)

  let menoh_model_data_optimize = 
    foreign "menoh_model_data_optimize" (menoh_model_data_handle @-> menoh_variable_profile_table_handle @-> returning menoh_error_code)

  let menoh_make_model_builder = 
    foreign "menoh_make_model_builder" (menoh_variable_profile_table_handle @-> ptr menoh_model_builder_handle @-> returning menoh_error_code)

  let menoh_delete_model_builder =
    foreign "menoh_delete_model_builder" (menoh_model_builder_handle @-> returning void)

  let menoh_model_builder_attach_external_buffer = 
    foreign "menoh_model_builder_attach_external_buffer" (menoh_model_builder_handle @-> string @-> ptr void @-> returning menoh_error_code)

  let menoh_build_model = 
    foreign "menoh_build_model" (menoh_model_builder_handle @-> menoh_model_data_handle @-> string @-> string @-> ptr menoh_model_handle @-> returning menoh_error_code)

  let menoh_delete_model =
    foreign "menoh_delete_model" (menoh_model_handle @-> returning void)

  let menoh_model_get_variable_buffer_handle = 
    foreign "menoh_model_get_variable_buffer_handle" (menoh_model_handle @-> string @-> ptr (ptr void) @-> returning menoh_error_code)

  let menoh_model_get_variable_dtype =
    foreign "menoh_model_get_variable_dtype" (menoh_model_handle @-> string @-> ptr menoh_dtype @-> returning menoh_error_code)

  let menoh_model_get_variable_dims_size =
    foreign "menoh_model_get_variable_dims_size" (menoh_model_handle @-> string @-> ptr int32_t @-> returning menoh_error_code)

  let menoh_model_get_variable_dims_at =
    foreign "menoh_model_get_variable_dims_at" (menoh_model_handle @-> string @-> int32_t @-> ptr int32_t @-> returning menoh_error_code)

  let menoh_model_run = 
    foreign "menoh_model_run" (menoh_model_handle @-> returning menoh_error_code)
end