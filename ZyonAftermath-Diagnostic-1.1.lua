-- Zyon Aftermath: read-only targeted structure report.
local Players=game:GetService('Players')
local p=Players.LocalPlayer
local rows={'ZYON / AFTERMATH — DETALHES 1.1','PlaceId: '..game.PlaceId,'GameId: '..game.GameId}
local function add(s) table.insert(rows,s) end
local function attrs(o)
    local keys={}
    for k in pairs(o:GetAttributes()) do table.insert(keys,k) end
    table.sort(keys)
    for i,k in ipairs(keys) do
        if i>24 then add('  ... atributos adicionais'); break end
        local v=o:GetAttribute(k)
        add('  @'..k..' = '..tostring(v):sub(1,180))
    end
end
local function tree(o,depth,budget)
    if budget.n>=budget.max then return end
    budget.n+=1
    add(o.ClassName..' | '..o:GetFullName())
    attrs(o)
    if o:IsA('ValueBase') then add('  Value = '..tostring(o.Value):sub(1,180)) end
    if o:IsA('BasePart') then add('  Position = '..tostring(o.Position)) end
    if o:IsA('Model') then add('  PrimaryPart = '..tostring(o.PrimaryPart)) end
    if o:IsA('Humanoid') then add('  Health = '..tostring(o.Health)) end
    if o:IsA('ProximityPrompt') then
        add('  ActionText='..o.ActionText..' ObjectText='..o.ObjectText..' Hold='..o.HoldDuration)
    end
    if depth<=0 then return end
    local children=o:GetChildren()
    add('  Filhos = '..#children)
    for i,child in ipairs(children) do
        if i>8 then add('  ... demais filhos omitidos'); break end
        tree(child,depth-1,budget)
    end
end
local function section(title,o,depth,limit)
    add('\n--- '..title..' ---')
    if not o then add('Ausente'); return end
    tree(o,depth,{n=0,max=limit or 32})
end
print('ZYON: diagnóstico corrigido, 20 segundos. Entre no mapa e aproxime-se de loot, carro ou corpo, se disponíveis.')
section('JOGADOR LOCAL',p,0)
local camera=workspace.CurrentCamera
add('CameraSubject = '..tostring(camera and camera.CameraSubject))
section('PERSONAGEM LOCAL',p.Character,2,30)
local ga=workspace:FindFirstChild('game_assets')
if ga then
    add('\nGAME_ASSETS: todas as pastas')
    for _,o in ipairs(ga:GetChildren()) do add(o.ClassName..' | '..o.Name..' | filhos='..#o:GetChildren()) end
end
section('CHARDATAS — amostra',workspace:FindFirstChild('CharDatas'),2,35)
local function snapshots(label)
    add('\n=== '..label..' ===')
    local assets=workspace:FindFirstChild('game_assets')
    section('RAGDOLLS',assets and assets:FindFirstChild('ragdolls'),3,35)
    section('ITEM_SPAWNS',assets and assets:FindFirstChild('item_spawns'),3,35)
    for _,name in ipairs({'GroundWeapons','GroundAttachments','ThrownItems'}) do
        section(name,workspace:FindFirstChild(name),3,20)
    end
    add('\nMODELOS NA RAIZ: atributos, sem cenário estático')
    local count=0
    for _,o in ipairs(workspace:GetChildren()) do
        if o:IsA('Model') and o.Name~='SpawnBox' and o.Name~='LoadBox' then
            count+=1
            if count>16 then add('Limite de modelos atingido.'); break end
            section('Modelo',o,1,9)
        end
    end
end
snapshots('INÍCIO')
local events={}
local promptConnection=game:GetService('ProximityPromptService').PromptTriggered:Connect(function(prompt,who)
    if who and who~=p then return end
    if #events<20 then table.insert(events,prompt:GetFullName()..' | '..prompt.ObjectText..' | '..prompt.ActionText) end
end)
task.wait(20)
promptConnection:Disconnect()
snapshots('FINAL')
section('PERSONAGEM AO FINAL',p.Character,2,30)
add('\nINTERAÇÕES OBSERVADAS')
for _,event in ipairs(events) do add(event) end
if #events==0 then add('Nenhum ProximityPrompt acionado foi observado; pode haver um sistema próprio de interação.') end
add('\nNão classifica Body como cadáver nem item_spawn como item coletável. Nenhum valor alterado ou remoto acionado.')
local report=table.concat(rows,'\n')
print(report)
local copied=false
if type(setclipboard)=='function' then copied=pcall(setclipboard,report) end
print(copied and 'Relatório copiado. Cole no chat.' or 'Copie o relatório no console.')
