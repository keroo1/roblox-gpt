-- Read-only report. No game callbacks, remotes, GUI properties or controls are changed.
local player = game:GetService("Players").LocalPlayer
local lines = {"ZYON / estado do diálogo e erros do cliente"}
local function add(value) table.insert(lines, tostring(value)) end
local function property(object, key)
    local ok, value = pcall(function() return object[key] end)
    return ok and tostring(value) or "ilegível"
end
local gui = player:FindFirstChild("PlayerGui")
local root = gui and gui:FindFirstChild("NPCDialogue")
add("NPCDialogue=" .. tostring(root ~= nil))
if root then
    add("Enabled=" .. property(root, "Enabled"))
    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("GuiButton") then
            add(object:GetFullName() .. " text=" .. property(object,"Text"))
            for _, event in ipairs({"MouseButton1Click", "Activated"}) do
                if type(getconnections) == "function" then
                    local ok, list = pcall(getconnections, object[event])
                    if ok and type(list) == "table" then
                        add(event .. " total=" .. #list)
                        for index, connection in ipairs(list) do
                            if index > 10 then break end
                            add("  conexão " .. index .. " Enabled=" .. property(connection,"Enabled") .. " Connected=" .. property(connection,"Connected"))
                            local readable, fn = pcall(function() return connection.Function end)
                            if readable and type(fn) == "function" and debug and debug.info then
                                local found, source, line = pcall(debug.info, fn, "sl")
                                if found then add("  origem=" .. tostring(source) .. ":" .. tostring(line)) end
                            end
                        end
                    else add(event .. ": conexões ilegíveis") end
                else add("getconnections indisponível"); break end
            end
        elseif object:IsA("LocalScript") then
            add("Script: " .. object:GetFullName() .. " Disabled=" .. property(object,"Disabled"))
        end
    end
end
add("--- Erros recentes do cliente ---")
local ok, history = pcall(function() return game:GetService("LogService"):GetLogHistory() end)
if ok and type(history) == "table" then
    local selected, count = {}, 0
    for index = math.max(1, #history-299), #history do
        local entry = history[index]
        if entry.messageType == Enum.MessageType.MessageError then
            count=count+1
            for nearby=index, math.min(index+6,#history) do selected[nearby]=true end
        end
    end
    add("Erros nas últimas 300 entradas: " .. count)
    local emitted=0
    for index=math.max(1,#history-299),#history do
        if selected[index] then
            local entry=history[index]
            add(tostring(entry.timestamp).." "..tostring(entry.message):sub(1,1600))
            emitted=emitted+1
            if emitted>=90 then add("Limite de 90 linhas atingido."); break end
        end
    end
else add("Histórico indisponível: " .. tostring(history)) end
local report=table.concat(lines,"\n")
print(report)
if type(setclipboard)=="function" then pcall(setclipboard,report) end
if type(writefile)=="function" then pcall(writefile,"ZyonArcane-dialogo-estado.txt",report) end
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="Zyon: relatório concluído",Text="Cole no chat o relatório copiado.",Duration=10
    })
end)
return report
