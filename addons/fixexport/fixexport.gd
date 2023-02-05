@tool
extends EditorPlugin

var fixer

func _enter_tree() -> void:
	fixer = FixExport.new()
	add_export_plugin(fixer)
	DirAccess.make_dir_absolute(".export")

func _exit_tree() -> void:
	remove_export_plugin(fixer)

class FixExport extends EditorExportPlugin:
	func _export_end():
		print("Copying files...")
		DirAccess.make_dir_recursive_absolute(".export/.godot/imported/")
		copy_file("dikhololo_night_4k.exr-51512b6e9c27b98e483ef56bcc37b165.bptc.ctex")
		copy_file("Floor_Cathedral_001_Displacement.exr-e564b464e3336fab9a73e45e335c79c7.bptc.ctex")
	
	func copy_file(file: String):
		DirAccess.copy_absolute(".godot/imported/%s" % file, ".export/.godot/imported/%s" % file)
