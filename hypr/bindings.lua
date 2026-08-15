-- Application bindings

for i = 1, 9 do
	o.bind("CTRL + " .. i, nil, hl.dsp.focus({ workspace = tostring(i) }))
end
