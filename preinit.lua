-- Need to set up some detours quickly before anything else runs
local files = lje.env.find_script_files("detours/*")
for _, path in ipairs(files) do
    lje.con_printf("Loading detour '$green{%s}'", path)
    lje.require(path)
end