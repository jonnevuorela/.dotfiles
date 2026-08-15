-- Monitor and workspace configuration
hl.config({
	general = {
		resize_on_border = true,
	},
})

for workspace = 1, 5 do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-1" })
end

for workspace = 6, 9 do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-2" })
end

hl.monitor({
	output = "DP-1",
	mode = "2560x1440@170",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "DP-2",
	mode = "3840x2160@60",
	position = "-2560x0",
	scale = 1.5,
})

-- Social/Gaming apps on workspace 6
o.window({ class = "^(vesktop|steam|youtube-music|lutris)$" }, { workspace = "6" })

-- Wine window handling
o.window({ title = ".*wine.*" }, { tile = true })
o.window({ class = "^wine$" }, { tile = true, suppress_event = "fullscreen maximize" })
