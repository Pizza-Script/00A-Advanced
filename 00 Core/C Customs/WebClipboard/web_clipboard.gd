class_name WebClipboard

# github.com/godotengine/godot/issues/83752										# Clipboard issue
# reddit.com/r/godot/comments/1f5ycz6
# adarkroom.doublespeakgames.com												# Dark Room [sample project]
# github.com/TinyTakinTeller/GodotProjectZero

# Editor Settings > General > Docks > FileSystem > TextFile Extensions > .js
# Export > Web > Resources > Filters to export > *.js

# WebClipboard.output_text(_text, "Title")										# [COPY]  DisplayServer.clipboard_set(_text)
# _text = await WebClipboard.input_text("Input", "Title")						# [PASTE] _text = DisplayServer.clipboard_get()

# 00 Core > B Control > MyInput
# if OS.get_name() == "Web":

static var js_path: String = "res://00 Core/D Tools/WebClipboard/web_clipboard.js"
static var js_modal: String = _read_file(js_path)


static func output_text(text: String, title: String, description: String = "", button: String = "Accept") -> void:
	await _js_await(text, title, description, button)


static func input_text(text: String, title: String, description: String = "", button: String = "Accept") -> String:
	return await _js_await(text, title, description, button)


static func _read_file(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var content: String = file.get_as_text()
	file.close()
	return content


static func _js_await(text: String, title: String, description: String, button: String) -> String:
	if FileAccess.file_exists(js_path) == false:
		printerr("ERROR: JS File Missing!")

	# var script_path: String = get_script().get_path().get_base_dir() + "/"	# .get_script() can't call in static
	var command: String = js_modal.format({"input": text, "atitle": title, "subtitle": description, "button": button})
	var output: Variant = JavaScriptBridge.eval(command)
	while true:
		output = JavaScriptBridge.eval("window.globalTextAreaResult")
		if output != null:
			break
		await RenderingServer.frame_post_draw
	JavaScriptBridge.eval("window.globalTextAreaResult = null;")
	return str(output)
