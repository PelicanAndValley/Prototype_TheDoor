@tool
extends Area3D;

class_name DynamicWindArea;

@export
var max_wind_strength : float = 10;
@export
var resolution = Vector3i(128, 128, 128);
@export
var wind_normal : ImageTexture3D;
@export
var do_compute : bool = false;

var _child_forces : Array[DynamicWindForce] = [];
var _config_warnings : PackedStringArray = [];
var _shader_rid : RID;
var _uniform_set : RID;
var _wind_forces_buffer : RID;
var _wind_normal_buffer : RID;
var _bindings : Array[RDUniform] = [];
var _pipeline : RID;
var _rd : RenderingDevice;

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED:
			load_child_forces();
		NOTIFICATION_PARENTED:
			load_child_forces();


func load_child_forces () -> void:
	_child_forces = [];
	for child in get_children():
		if child is DynamicWindForce:
			_child_forces.append(child as DynamicWindForce);
	if _child_forces.size() == 0:
		_config_warnings = ["This node contains no forces and so will have no effect. Add DynamicWindForce children to provide direction to the wind."];
	else:
		_config_warnings = [];


# Return stored value
func _get_configuration_warnings() -> PackedStringArray:
	return _config_warnings;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if do_compute:
		if _rd:
			_rd.sync();
		setup_compute();
		compute();
		free_compute_resources();
		do_compute = false;

func _get_force_directions () -> PackedVector3Array:
	var forces := PackedVector3Array();
	for wind_force in _child_forces:
		var new_force = -wind_force.basis.z * wind_force.strength;
		forces.append(new_force);
	return forces;

func _get_force_positions () -> PackedVector3Array:
	var positions := PackedVector3Array();
	for wind_force in _child_forces:
		var pos = wind_force.position;
		positions.append(pos);
	return positions;

func _generate_uniform(data_buffer: RID, type: RenderingDevice.UniformType, binding: int) -> RDUniform:
	var data_uniform = RDUniform.new()
	data_uniform.uniform_type = type
	data_uniform.binding = binding
	data_uniform.add_id(data_buffer)
	return data_uniform

func _create_3d_texture(width: int, height: int, depth: int, format: Image.Format) -> ImageTexture3D:
	var imgs : Array[Image] = [];
	for i in depth:
		var new_img := Image.create_empty(width, height, false, format);
		imgs.append(new_img);
	print("IMGS ", imgs.size(), " DIM ", imgs[0].get_width(), "x", imgs[0].get_height());
	var tex_3d = ImageTexture3D.new();
	print(tex_3d.create(format, width, height, depth, false, imgs));
	return tex_3d;

func _texture_3d_to_bytes(texture: ImageTexture3D) -> PackedByteArray:
	var bytes := PackedByteArray();
	for img: Image in texture.get_data():
		var img_bytes = img.get_data();
		bytes.append_array(img_bytes);
	return bytes;

func setup_compute():
	
	wind_normal = _create_3d_texture(resolution.x, resolution.y, resolution.z, Image.FORMAT_RGBAH);
	
	# We will be using our own RenderingDevice to handle the compute commands
	_rd = RenderingServer.create_local_rendering_device()
	
	# Create shader and pipeline
	var shader_file = load("res://addons/dynamic_wind/compute_wind.glsl")
	var shader_spirv = shader_file.get_spirv()
	_shader_rid = _rd.shader_create_from_spirv(shader_spirv)
	_pipeline = _rd.compute_pipeline_create(_shader_rid);
	
	var fmt = RDTextureFormat.new()
	fmt.width = resolution.x;
	fmt.height = resolution.y;
	fmt.depth = resolution.z;
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT;
	fmt.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT;
	fmt.texture_type = RenderingDevice.TEXTURE_TYPE_3D;
	
	var view := RDTextureView.new()
	_wind_normal_buffer = _rd.texture_create(fmt, view, [_texture_3d_to_bytes(wind_normal)]);
	var wind_normal_uniform = _generate_uniform(_wind_normal_buffer, RenderingDevice.UNIFORM_TYPE_IMAGE, 1)
	
	_bindings = [
		wind_normal_uniform
	];


func compute():
	
	print("COMPUTING")
	
	_uniform_set = _rd.uniform_set_create(_bindings, _shader_rid, 0);
	# Start compute list to start recording our compute commands
	var compute_list = _rd.compute_list_begin()
	# Bind the pipeline, this tells the GPU what shader to use
	_rd.compute_list_bind_compute_pipeline(compute_list, _pipeline)
	# Binds the uniform set with the data we want to give our shader
	_rd.compute_list_bind_uniform_set(compute_list, _uniform_set, 0);
	# Dispatch 1x1x1 (XxYxZ) work groups
	_rd.compute_list_dispatch(compute_list, resolution.x / 8, resolution.y / 8, resolution.z / 8)
	#rd.compute_list_add_barrier(compute_list)
	# Tell the GPU we are done with this compute task
	_rd.compute_list_end()
	# Force the GPU to start our commands
	_rd.submit()
	# Force the CPU to wait for the GPU to finish with the recorded commands
	_rd.sync()
	
	var output_images : Array[Image] = [];
	# Only 1 3D layer
	var image_data := _rd.texture_get_data(_wind_normal_buffer, 0);
	for i in resolution.z: # TODO change
		var slice_size = resolution.x * resolution.y * 8;
		var data_slice = image_data.slice(i * slice_size, (i * slice_size) + slice_size);
		var image := Image.create_from_data(resolution.x, resolution.y, false, Image.FORMAT_RGBAH, data_slice);
		output_images.append(image);
	wind_normal.update(output_images);

func free_compute_resources () -> void:
	print("FREE");
	#var _shader_rid : RID;
	#var _uniform_set : RID;
	#var _bindings : Array[RID] = [];
	#var _pipeline : RID;
	_rd.free_rid(_uniform_set);
	_rd.free_rid(_wind_normal_buffer);
	_rd.free_rid(_wind_forces_buffer);
	_rd.free_rid(_pipeline);
	_rd.free_rid(_shader_rid);
