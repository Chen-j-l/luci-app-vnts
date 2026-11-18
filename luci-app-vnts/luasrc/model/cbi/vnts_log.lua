f = SimpleForm("vnts")
f.reset = false
f.submit = false
f:append(Template("vnts/vnts_log"))
return f
