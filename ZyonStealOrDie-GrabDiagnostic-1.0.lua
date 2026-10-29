-- Read-only observation of replicated player/character state for 35 seconds.
local Players=game:GetService('Players')
local StarterGui=game:GetService('StarterGui')
local localPlayer=Players.LocalPlayer
local started=os.clock()
local running=true
local connections={}
local seen=setmetatable({}, {__mode='k'})
local observed=setmetatable({}, {__mode='k'})
local rows={'ZYON / GRAB — 35 segundos; somente observação local'}
local count=0
local dropped=0
local lastNotice=-10
local tokens={'grab','grip','captur','caught','captive','victim','held','holding','restrain','carrytarget','carriedby','agarr','preso'}
local function relevant(value)
    local name=tostring(value):lower()
    for _,token in ipairs(tokens) do
        if name:find(token,1,true) then return true end
    end
    return false
end
local function notify(message)
    pcall(function()
        StarterGui:SetCore('SendNotification',{Title='ZYON / Grab',Text=message,Duration=5})
    end)
end
local function connect(signal,callback)
    table.insert(connections,signal:Connect(function(...)
        if running then callback(...) end
    end))
end
local function log(message,candidate)
    if not running then return end
    if count>=600 then dropped+=1; return end
    count+=1
    local line=string.format('%.2fs | %s',os.clock()-started,message)
    table.insert(rows,line)
    print(line)
    if candidate and os.clock()-lastNotice>=2 then
        lastNotice=os.clock()
        notify('Possível mudança de captura registrada agora. Continue até completar 35s.')
    end
end
local function sample(obj,key,value,initial)
    seen[obj]=seen[obj] or {}
    local serialized=tostring(value):sub(1,240)
    local previous=seen[obj][key]
    seen[obj][key]=serialized
    if previous==serialized then return end
    local path=obj:GetFullName()
    if initial and not relevant(key..' '..path) then return end
    log(path..' ['..key..'] '..(initial and '= ' or ((previous or '<não observado>')..' -> '))..serialized,
        not initial and relevant(key..' '..path))
end
local function noisy(name)
    local lower=name:lower()
    return lower=='lookyaw' or lower=='lookpitch' or lower=='playtime'
end
local function watchObject(obj)
    if observed[obj] then return end
    observed[obj]=true
    for name,value in pairs(obj:GetAttributes()) do
        if not noisy(name) then sample(obj,'atributo '..name,value,true) end
    end
    connect(obj.AttributeChanged,function(name)
        if not noisy(name) then sample(obj,'atributo '..name,obj:GetAttribute(name),false) end
    end)
    if obj:IsA('ValueBase') and relevant(obj:GetFullName()) then
        sample(obj,'Value',obj.Value,true)
        connect(obj.Changed,function() sample(obj,'Value',obj.Value,false) end)
    end
    if obj:IsA('Humanoid') then
        for _,property in ipairs({'PlatformStand','Sit','AutoRotate','Health'}) do
            sample(obj,property,obj[property],true)
            connect(obj:GetPropertyChangedSignal(property),function()
                sample(obj,property,obj[property],false)
            end)
        end
        connect(obj.StateChanged,function(old,new)
            log(obj:GetFullName()..' estado '..old.Name..' -> '..new.Name,false)
        end)
    end
end
local function watchTree(root)
    watchObject(root)
    for _,obj in ipairs(root:GetDescendants()) do watchObject(obj) end
    connect(root.DescendantAdded,function(obj)
        if relevant(obj.Name) then log('Objeto criado: '..obj:GetFullName()..' ('..obj.ClassName..')',true) end
        watchObject(obj)
    end)
    connect(root.DescendantRemoving,function(obj)
        if relevant(obj.Name) then log('Objeto removido: '..obj:GetFullName(),true) end
    end)
end
local function watchPlayer(p)
    watchObject(p)
    log('Jogador '..p.Name..' | IsEntity='..tostring(p:GetAttribute('IsEntity'))..' | EntityKind='..tostring(p:GetAttribute('EntityKind')),false)
    if p.Character then watchTree(p.Character) end
    connect(p.CharacterAdded,function(char)
        log('Personagem criado: '..p.Name,false)
        watchTree(char)
    end)
    -- Values outside the character, excluding interface/inventory trees.
    for _,obj in ipairs(p:GetDescendants()) do
        if obj:IsA('ValueBase') and relevant(obj:GetFullName()) then watchObject(obj) end
    end
    connect(p.DescendantAdded,function(obj)
        if obj:IsA('ValueBase') and relevant(obj:GetFullName()) then watchObject(obj) end
    end)
end
print('ZYON: observando por 35 segundos. Como monstro, agarre um sobrevivente normalmente.')
notify('Diagnóstico iniciado: agarre alguém nos próximos 35 segundos.')
log('Local: '..localPlayer.Name..' | PlaceId='..game.PlaceId,false)
for _,p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
connect(Players.PlayerAdded,watchPlayer)
task.wait(math.max(0,35-(os.clock()-started)))
running=false
for _,connection in ipairs(connections) do connection:Disconnect() end
table.insert(rows,'FIM | eventos omitidos pelo limite: '..dropped)
table.insert(rows,'Avisos são indícios, não confirmação de captura. Ausência de evento não prova ausência de grab; nenhum remoto foi interceptado ou executado.')
local report=table.concat(rows,'\n')
print(report)
local copied=false
if type(setclipboard)=='function' then copied=pcall(setclipboard,report) end
notify(copied and 'Concluído. Relatório copiado: cole no chat.' or 'Concluído. Copie o relatório no console.')
print(copied and 'Relatório copiado. Cole no chat.' or 'Copie o relatório pelo console.')
