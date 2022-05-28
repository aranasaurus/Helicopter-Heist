stds.playdate = {
	globals = { "playdate", "import" , "class" }
}
std = "max+playdate"
files["**/*.luacheckrc"].std = std + "+luacheckrc"
allow_defined_top = true
