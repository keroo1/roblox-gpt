-- Read-only structure and interaction report. Does not invoke game remotes.
local Players=game:GetService('Players')
local Prompts=game:GetService('ProximityPromptService')
local player=Players.LocalPlayer
local rows={'ZYON / AFTERMATH — diagnóstico 1.0','PlaceId: '..game.PlaceId,'GameId: '..game.GameId}
local started=os.clock()
local active=true
local connections={}
local samples={item=0,vehicle=0,humanoid=0,prompt=0,corpse=0}
local omissions=0
local visited=setmetatable({}, {__mode='k'})
local function out(message)
    if #rows<650 then table.insert(rows,string.format('%.2fs | %s',os.clock()-started,message)) else omissions+=1 end
end
local function attrs(obj)
    local keys={}
    for key in pairs(obj:GetAttributes()) do table.insert(keys,key) end
    table.sort(keys)
    for i,key in ipairs(keys) do
        if i>18 then break end
        local value=obj:GetAttribute(key)
        if typeof(value)~='string' or #value<160 then out('  atributo '..key..' = '..tostring(value)) end
    end
end
local function describe(obj,kind)
    if visited[obj] or samples[kind]>=20 then return end
    visited[obj]=true
    samples[kind]+=1
    out(kind..' | '..obj.ClassName..' | '..obj:GetFullName())
    attrs(obj)
    local parent=obj.Parent
    if parent and parent~=workspace then
        out('  pai: '..parent.ClassName..' | '..parent:GetFullName())
        attrs(parent)
        for i,child in ipairs(parent:GetChildren()) do
            if i>12 then break end
            out('  filho: '..child.ClassName..' | '..child.Name)
        end
    end
end
local function inspect(obj)
    if obj:IsA('ProximityPrompt') then
        describe(obj,'prompt')
        if samples.prompt<=20 and visited[obj] then
            out(string.format('  prompt: objeto=%s ação=%s duração=%.2f alcance=%.1f',obj.ObjectText,obj.ActionText,obj.HoldDuration,obj.MaxActivationDistance))
        end
    elseif obj:IsA('VehicleSeat') then
        describe(obj,'vehicle')
    elseif obj:IsA('Humanoid') then
        describe(obj,'humanoid')
        out('  HP='..tostring(obj.Health)..' / '..tostring(obj.MaxHealth))
    elseif obj:IsA('Model') or obj:IsA('BasePart') then
        local name=obj.Name:lower()
        if name:find('corpse',1,true) or name:find('ragdoll',1,true) or name:find('deadbody',1,true) or name=='body' or name=='bodies' then describe(obj,'corpse')
        elseif name:find('vehicle',1,true) or name:find('truck',1,true) or name=='car' then describe(obj,'vehicle')
        elseif name:find('loot',1,true) or name:find('pickup',1,true) or name:find('item',1,true) or obj:GetAttribute('ItemId')~=nil then describe(obj,'item') end
    end
end
local function bind(signal,fn)
    table.insert(connections,signal:Connect(function(...)
        if active then fn(...) end
    end))
end
print('ZYON: observando por 20s. Aproxime-se de itens e carros e colete um item normalmente.')
out('PERSONAGEM')
if player.Character then
    out(player.Character:GetFullName())
    attrs(player.Character)
    for _,obj in ipairs(player.Character:GetChildren()) do out('  '..obj.ClassName..' | '..obj.Name) end
end
out('ESTRUTURA DO MAPA')
for i,root in ipairs(workspace:GetChildren()) do
    if i>100 then out('Demais raízes omitidas.'); break end
    out(root.ClassName..' | '..root.Name..' | filhos='..#root:GetChildren())
    if root:IsA('Folder') then
        for j,child in ipairs(root:GetChildren()) do
            if j>8 then break end
            out('  '..child.ClassName..' | '..child.Name)
        end
    end
end
bind(Prompts.PromptTriggered,function(prompt,who)
    if who and who~=player then return end
    out('INTERAÇÃO: '..prompt:GetFullName()..' | '..prompt.ObjectText..' | '..prompt.ActionText)
    attrs(prompt)
    if prompt.Parent then attrs(prompt.Parent) end
end)
bind(workspace.DescendantAdded,function(obj) pcall(inspect,obj) end)
local objects=workspace:GetDescendants()
for i,obj in ipairs(objects) do
    pcall(inspect,obj)
    if i%500==0 then task.wait() end
    if os.clock()-started>=20 then out('Varredura interrompida ao atingir 20s.'); break end
end
task.wait(math.max(0,20-(os.clock()-started)))
active=false
for _,connection in ipairs(connections) do connection:Disconnect() end
out('AMOSTRAS: itens='..samples.item..' veículos='..samples.vehicle..' humanoids='..samples.humanoid..' prompts='..samples.prompt..' corpos candidatos='..samples.corpse)
table.insert(rows,'Linhas omitidas pelo limite: '..omissions)
table.insert(rows,'Nomes são candidatos, não classificação confirmada. Objetos não replicados ao cliente não aparecem.')
local report=table.concat(rows,'\n')
print(report)
local copied=false
if type(setclipboard)=='function' then copied=pcall(setclipboard,report) end
print(copied and 'Relatório copiado. Cole no chat.' or 'Copie o relatório pelo console.')
pcall(function()
    game:GetService('StarterGui'):SetCore('SendNotification',{Title='ZYON / Aftermath',Text=copied and 'Relatório copiado. Cole no chat.' or 'Relatório disponível no console.',Duration=8})
end)
