open Menohcaml.Menoh

let conv1_1_in_name = "140326425860192"
let fc6_out_name = "140326200777584"
let softmax_out_name = "140326200803680"

let model_data = Model_data.make_from_onnx 
    "path/to/VGG16.onnx"

let vpt_builder = Vpt_builder.make ()

let () = Vpt_builder.add_input_profile_dims_4 vpt_builder conv1_1_in_name menoh_dtype_float 1l 3l 224l 224l

let () = Vpt_builder.add_output_profile vpt_builder fc6_out_name menoh_dtype_float

let () = Vpt_builder.add_output_profile vpt_builder softmax_out_name menoh_dtype_float

let variable_profile_table = Vpt.build vpt_builder model_data 

let softmax_out_dims = [| 0l; 0l |]

let () = softmax_out_dims.(0) <- (Vpt.get_dims_at variable_profile_table softmax_out_name 0l)

let () = softmax_out_dims.(1) <- (Vpt.get_dims_at variable_profile_table softmax_out_name 1l)

let () = optimize model_data variable_profile_table

let model_builder = Model_builder.make variable_profile_table

let input_buff = Ctypes.(CArray.make float (1 * 3 * 224 * 224))

let () = Model_builder.attach_external_buffer model_builder conv1_1_in_name Ctypes.(to_voidp @@ CArray.start input_buff)

let model = Model.build model_builder model_data "mkldnn" "" 

let () = Model_data.delete model_data

let fc6_output_buff = Model.get_variable_buffer_handle model fc6_out_name |> Ctypes.(from_voidp float)

let softmax_output_buff = Model.get_variable_buffer_handle model softmax_out_name |> Ctypes.(from_voidp float)

let () = 
  for i = 0 to 1 * 3 * 224 * 224 - 1 do 
    Ctypes.(CArray.set input_buff i 0.5)
  done

let () = Model.run model

let () = 
  let open Ctypes in
  let open CArray in
  let fc6_output_buff_ar = (from_ptr fc6_output_buff 10) in
  for i = 0 to 9 do
    Printf.printf "%f " (get fc6_output_buff_ar i)
  done;
  print_newline();
  let d0 = softmax_out_dims.(0) |> Int32.to_int in
  let d1 = softmax_out_dims.(1) |> Int32.to_int in
  let softmax_output_buff_ar = (from_ptr softmax_output_buff (d0 * d1)) in
  for n = 0 to d0 - 1 do 
    for i = 0 to d1 - 1 do
      Printf.printf "%f " (get softmax_output_buff_ar (n * d1 + i))
    done;
    print_newline()
  done

let () = Model.delete(model)
let () = Model_builder.delete(model_builder)
let () = Vpt_builder.delete(vpt_builder)
