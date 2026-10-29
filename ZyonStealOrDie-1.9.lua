-- Zyon Steal Or Die 1.9 | Based on client structure reported on 2026-10-29.
-- Local EnergyUntil effect; no remote calls, downloaded libraries, or game-module patches.
if game.PlaceId ~= 119925538689885 then error('Zyon: abra Steal Or Die.') end
local Players = game:GetService('Players')
local Input = game:GetService('UserInputService')
local player = Players.LocalPlayer
local env = (type(getgenv) == 'function' and getgenv()) or _G
if env.ZyonStealOrDie then pcall(env.ZyonStealOrDie.Unload) end
local app = {Alive = true, Connections = {}, Marks = {}}
env.ZyonStealOrDie = app
local flags = {Monsters = false, Survivors = false, Items = false, Energy = false, Speed = false, Instant = false, GrabRange = false, GrabDistance = 16, Value = 24, Filter = '', Rarity = 'Todas'}
-- HUD palette; these colors do not claim to be the game's official palette.
local rarityColors = {
    common=Color3.fromRGB(235,238,245),
    uncommon=Color3.fromRGB(100,230,150),
    rare=Color3.fromRGB(90,175,255),
    epic=Color3.fromRGB(190,125,255),
    legendary=Color3.fromRGB(255,205,85),
    mythic=Color3.fromRGB(255,115,215),
}
local function rarityKey(item)
    local value=item:GetAttribute('Rarity')
    return type(value)=='string' and value:match('^%s*(.-)%s*$'):lower() or ''
end
local function itemColor(item)
    return rarityColors[rarityKey(item)] or Color3.fromRGB(165,173,188)
end
local function rarityMatches(item)
    local key=rarityKey(item)
    return flags.Rarity=='Todas'
        or (flags.Rarity=='Desconhecida' and not rarityColors[key])
        or key==flags.Rarity:lower()
end
local purple = Color3.fromRGB(168, 139, 250)
local function make(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function connect(signal, fn)
    table.insert(app.Connections, signal:Connect(fn))
end
local gui = make('ScreenGui', {Name='ZyonStealOrDie', ResetOnSpawn=false, Enabled=true, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=500}, nil)
local attached=false
if type(gethui)=='function' then
    attached=pcall(function()
        local container=gethui()
        assert(typeof(container)=='Instance','Container de interface indisponível')
        gui.Parent=container
    end)
end
if not attached then attached=pcall(function() gui.Parent=game:GetService('CoreGui') end) end
if not attached then gui.Parent=player:WaitForChild('PlayerGui') end
app.Gui=gui
local overlay = make('Folder', {Name='Markers'}, gui)
local panel = make('ScrollingFrame', {CanvasSize=UDim2.fromOffset(0,1024), ScrollBarThickness=4, ScrollingDirection=Enum.ScrollingDirection.Y, Name='MainWindow', Visible=true, AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.fromOffset(350,618), Position=UDim2.fromScale(0.5,0.5), BackgroundColor3=Color3.fromRGB(19,20,29), BorderSizePixel=0}, gui)
local function fitPanel()
    local camera=workspace.CurrentCamera
    if not camera then return end
    local viewport=camera.ViewportSize
    if viewport.X<=0 or viewport.Y<=0 then return end
    panel.Size=UDim2.fromOffset(math.min(350,math.max(100,viewport.X-24)),math.min(618,math.max(100,viewport.Y-40)))
end
fitPanel()
app.Panel=panel
make('UICorner', {CornerRadius=UDim.new(0,12)}, panel)
make('UIStroke', {Color=purple, Transparency=0.45}, panel)
local function text(content,y,height)
    return make('TextLabel', {Text=content, Position=UDim2.fromOffset(18,y), Size=UDim2.new(1,-36,0,height), BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=13, TextWrapped=true, TextColor3=Color3.fromRGB(223,224,237), TextXAlignment=Enum.TextXAlignment.Left}, panel)
end
text('ZYON  /  STEAL OR DIE',14,27).Font=Enum.Font.GothamBold
text('1.9  ·  RightCtrl / Insert para abrir e fechar',43,24)
local function action(title,y,fn)
    local b=make('TextButton',{Text=title,Position=UDim2.fromOffset(18,y),Size=UDim2.new(1,-36,0,34),BackgroundColor3=Color3.fromRGB(38,37,53),TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamMedium,TextSize=13,BorderSizePixel=0},panel)
    make('UICorner',{CornerRadius=UDim.new(0,7)},b)
    connect(b.Activated,fn)
    return b
end
local function toggle(key,title,y,callback)
    local b
    b=action(title..'  ·  OFF',y,function()
        flags[key]=not flags[key]
        b.Text=title..(flags[key] and '  ·  ON' or '  ·  OFF')
        b.TextColor3=flags[key] and purple or Color3.new(1,1,1)
        if callback then callback() end
    end)
    return b
end
-- Only loot prompts are changed. The player still triggers the normal interaction.
local promptOriginals = {}
local function inLoot(prompt)
    for _,name in ipairs({'MyLoot','LootItems'}) do
        local root=workspace:FindFirstChild(name)
        if root and prompt:IsDescendantOf(root) then return true end
    end
    return false
end
local function restoreProperty(prompt,property,entry)
    pcall(function()
        if prompt.Parent and prompt[property]==entry.applied then prompt[property]=entry.original end
    end)
end
local function releasePrompt(prompt)
    for property,entry in pairs(promptOriginals[prompt] or {}) do restoreProperty(prompt,property,entry) end
    promptOriginals[prompt]=nil
end
local function restorePrompts()
    for prompt in pairs(promptOriginals) do releasePrompt(prompt) end
end
local function applyPrompt(prompt)
    if not app.Alive or not prompt:IsA('ProximityPrompt') or not inLoot(prompt) then return end
    local entries=promptOriginals[prompt] or {}
    local function apply(property,enabled,value)
        local entry=entries[property]
        if not enabled then
            if entry then restoreProperty(prompt,property,entry); entries[property]=nil end
        elseif not entry then
            entries[property]={original=prompt[property],applied=value}
            prompt[property]=value
        elseif entry.applied~=value and prompt[property]==entry.applied then
            prompt[property]=value
            entry.applied=value
        end
    end
    apply('HoldDuration',flags.Instant,0)
    apply('MaxActivationDistance',flags.GrabRange,flags.GrabDistance)
    promptOriginals[prompt]=next(entries) and entries or nil
end
local function syncPrompts()
    for prompt in pairs(promptOriginals) do
        if not prompt.Parent or not inLoot(prompt) then releasePrompt(prompt) else applyPrompt(prompt) end
    end
    if not flags.Instant and not flags.GrabRange then return end
    for _,name in ipairs({'MyLoot','LootItems'}) do
        local root=workspace:FindFirstChild(name)
        if root then
            for _,object in ipairs(root:GetDescendants()) do applyPrompt(object) end
        end
    end
end
connect(workspace.DescendantAdded,function(object)
    if object:IsA('ProximityPrompt') then
        task.defer(function() if app.Alive then applyPrompt(object) end end)
    end
end)
local status=text('Pronto. Ative os marcadores desejados.',920,44)
toggle('Monsters','ESP monstros',82)
text('Nome, tipo e distância; usa o atributo IsEntity.',119,27)
toggle('Survivors','ESP sobreviventes · como monstro',151)
toggle('Items','ESP itens',195)
local filter=make('TextBox',{Text='',PlaceholderText='Filtrar itens pelo nome (opcional)',ClearTextOnFocus=false,Position=UDim2.fromOffset(18,237),Size=UDim2.new(1,-36,0,30),BackgroundColor3=Color3.fromRGB(30,31,43),TextColor3=Color3.new(1,1,1),PlaceholderColor3=Color3.fromRGB(157,158,177),Font=Enum.Font.Gotham,TextSize=12,BorderSizePixel=0},panel)
connect(filter:GetPropertyChangedSignal('Text'),function() flags.Filter=filter.Text:lower() end)
local rarityChoices={'Todas','Common','Uncommon','Rare','Epic','Legendary','Mythic','Desconhecida'}
local rarityIndex=1
local rarityButton
rarityButton=action('Raridade: Todas  >',278,function()
    rarityIndex=rarityIndex % #rarityChoices + 1
    flags.Rarity=rarityChoices[rarityIndex]
    rarityButton.Text='Raridade: '..flags.Rarity..'  >'
    rarityButton.TextColor3=rarityColors[flags.Rarity:lower()] or purple
end)
local ownedHum, oldSpeed, appliedSpeed
local function restoreSpeed()
    if ownedHum and ownedHum.Parent and ownedHum.WalkSpeed==appliedSpeed then ownedHum.WalkSpeed=oldSpeed end
    ownedHum,oldSpeed,appliedSpeed=nil,nil,nil
end
local function setSpeed()
    restoreSpeed()
    local hum=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
    if flags.Speed and hum and hum.Health>0 then
        ownedHum,oldSpeed,appliedSpeed=hum,hum.WalkSpeed,flags.Value
        hum.WalkSpeed=appliedSpeed
    end
end
local speedToggle=toggle('Speed','Velocidade local',324,setSpeed)
text('Valor (8–80):',367,28)
local speed=make('TextBox',{Text='24',ClearTextOnFocus=false,Position=UDim2.fromOffset(230,367),Size=UDim2.fromOffset(100,28),BackgroundColor3=Color3.fromRGB(38,37,53),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=14,BorderSizePixel=0},panel)
connect(speed.FocusLost,function()
    local n=tonumber(speed.Text)
    if n and n==n and math.abs(n)<math.huge then flags.Value=math.clamp(n,8,80) end
    speed.Text=tostring(flags.Value)
    setSpeed()
end)
toggle('Instant','Interação instantânea · itens',405,syncPrompts)
text('Remove a espera de segurar; coleta continua manual.',442,27)
toggle('GrabRange','Aumentar alcance de coleta',475,syncPrompts)
text('Distância (4–30 studs):',519,28)
local rangeBox=make('TextBox',{Text='16',ClearTextOnFocus=false,Position=UDim2.fromOffset(230,519),Size=UDim2.fromOffset(100,28),BackgroundColor3=Color3.fromRGB(38,37,53),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=14,BorderSizePixel=0},panel)
connect(rangeBox.FocusLost,function()
    local n=tonumber(rangeBox.Text)
    if n and n==n and math.abs(n)<math.huge then flags.GrabDistance=math.clamp(n,4,30) end
    rangeBox.Text=tostring(flags.GrabDistance)
    syncPrompts()
end)
action('Restaurar velocidade',560,function()
    flags.Speed=false
    restoreSpeed()
    speedToggle.Text='Velocidade local  ·  OFF'
    speedToggle.TextColor3=Color3.new(1,1,1)
end)
-- A seven-second EnergyUntil change was tested by the user. Renewal is experimental.
local energyOriginal,energyApplied,energyCharacter
local energyButton
local energyInfo=text('Energético desligado. Efeito local de 7 segundos.',834,76)
local function stopEnergy(message)
    flags.Energy=false
    if energyApplied and player:GetAttribute('EnergyUntil')==energyApplied then
        player:SetAttribute('EnergyUntil',energyOriginal)
    end
    energyOriginal,energyApplied,energyCharacter=nil,nil,nil
    if energyButton then
        energyButton.Text='Energético contínuo  ·  OFF'
        energyButton.TextColor3=Color3.new(1,1,1)
    end
    if message then energyInfo.Text=message end
end
local function energyTick(manual)
    local char=player.Character
    local hum=char and char:FindFirstChildOfClass('Humanoid')
    if not hum or hum.Health<=0 or (energyCharacter and energyCharacter~=char) then
        if energyApplied or flags.Energy or manual then stopEnergy('Energético pausado: personagem indisponível.') end
        return
    end
    local originalValue=player:GetAttribute('EnergyUntil')
    if energyApplied and originalValue~=energyApplied then
        stopEnergy('O jogo alterou o efeito. Renovação pausada; valor do jogo preservado.')
        return
    end
    if originalValue~=nil and (type(originalValue)~='number' or originalValue~=originalValue or math.abs(originalValue)==math.huge) then
        if flags.Energy or manual then stopEnergy('EnergyUntil tem um formato incompatível. Efeito não aplicado.') end
        return
    end
    -- Missing attributes may be initialized locally on explicit activation.
    -- Preserve nil so disabling removes only the attribute created by this hub.
    local value=originalValue or 0
    local now=workspace:GetServerTimeNow()
    if manual or flags.Energy then
        -- Preserve an existing effect instead of shortening it.
        if value-now<=(flags.Energy and 2 or 0) then
            if not energyApplied then energyOriginal=originalValue; energyCharacter=char end
            energyApplied=now+7
            player:SetAttribute('EnergyUntil',energyApplied)
            value=energyApplied
        end
        energyInfo.Text=string.format('%s · %.1f s restantes\nModo contínuo experimental; depende do cliente.',flags.Energy and 'Renovação ligada' or 'Energético temporário',math.max(0,value-now))
    elseif energyApplied then
        if value<=now then stopEnergy('Energético encerrado; valor anterior restaurado.')
        else energyInfo.Text=string.format('Energético temporário · %.1f s restantes',value-now) end
    end
end
action('Usar energético · 7 segundos',604,function() energyTick(true) end)
local function toggleEnergy()
    flags.Energy=not flags.Energy
    energyButton.Text='Energético contínuo'..(flags.Energy and '  ·  ON' or '  ·  OFF')
    energyButton.TextColor3=flags.Energy and purple or Color3.new(1,1,1)
    if flags.Energy then energyTick(false) else stopEnergy('Energético contínuo desligado.') end
end
energyButton=action('Energético contínuo  ·  OFF',648,toggleEnergy)
local energyKeys={Once=Enum.KeyCode.H}
local keyButtons={}
local captureKey=nil
local keyHelp=text('Clique no atalho e pressione uma tecla. Esc cancela; Backspace remove. Válido nesta execução.',780,44)
local function refreshKeyButtons()
    for name,button in pairs(keyButtons) do
        local title=name=='Once' and 'Atalho · usar energético' or 'Atalho · modo contínuo'
        button.Text=title..': '..(captureKey==name and 'pressione uma tecla...' or (energyKeys[name] and energyKeys[name].Name or 'Nenhum'))
    end
end
local function bindButton(name,y)
    keyButtons[name]=action('',y,function()
        captureKey=name
        refreshKeyButtons()
    end)
end
bindButton('Once',692)
bindButton('Continuous',736)
refreshKeyButtons()

function app.Unload()
    if not app.Alive then return end
    app.Alive=false
    stopEnergy()
    restorePrompts()
    restoreSpeed()
    for _,c in ipairs(app.Connections) do c:Disconnect() end
    gui:Destroy()
    if env.ZyonStealOrDie==app then env.ZyonStealOrDie=nil end
end
action('Descarregar hub',974,app.Unload)
local reopen=make('TextButton',{Text='Z',Size=UDim2.fromOffset(42,42),Position=UDim2.new(0,12,0.5,-21),BackgroundColor3=Color3.fromRGB(38,37,53),TextColor3=purple,Font=Enum.Font.GothamBold,TextSize=20},gui)
make('UICorner',{CornerRadius=UDim.new(0,10)},reopen)
function app.Show()
    if not app.Alive then return end
    gui.Enabled=true
    panel.Visible=true
    panel.Position=UDim2.fromScale(0.5,0.5)
    fitPanel()
end
local function switch()
    captureKey=nil
    refreshKeyButtons()
    if not gui.Enabled or not panel.Visible then app.Show() else panel.Visible=false end
end
connect(reopen.Activated,switch)
connect(Input.InputBegan,function(input,processed)
    if not app.Alive or Input:GetFocusedTextBox() then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    local key=input.KeyCode
    if captureKey then
        if key==Enum.KeyCode.Escape then
            captureKey=nil
        elseif key==Enum.KeyCode.Backspace then
            energyKeys[captureKey]=nil
            captureKey=nil
        elseif key==Enum.KeyCode.RightControl or key==Enum.KeyCode.Insert or key==Enum.KeyCode.Unknown then
            keyHelp.Text='Tecla reservada para o menu. Escolha outra; Esc cancela.'
        elseif energyKeys[captureKey=='Once' and 'Continuous' or 'Once']==key then
            keyHelp.Text='Essa tecla já está no outro atalho. Escolha outra; Esc cancela.'
        else
            energyKeys[captureKey]=key
            captureKey=nil
        end
        refreshKeyButtons()
        if not captureKey then keyHelp.Text='Atalhos atualizados. Esc cancela a edição; Backspace remove. Válido nesta execução.' end
        return
    end
    if processed then return end
    if key==Enum.KeyCode.RightControl or key==Enum.KeyCode.Insert then switch()
    elseif key==energyKeys.Once then energyTick(true)
    elseif key==energyKeys.Continuous then toggleEnergy() end
end)
connect(player.CharacterAdded,function(char)
    stopEnergy('Energético desligado após renascer.')
    restoreSpeed()
    task.spawn(function()
        local hum=char:WaitForChild('Humanoid',10)
        if app.Alive and hum and player.Character==char then setSpeed() end
    end)
end)
local function partOf(object)
    if object:IsA('BasePart') then return object end
    return object:FindFirstChild('HumanoidRootPart') or object:FindFirstChildWhichIsA('BasePart',true)
end
local function itemCaption(item)
    local rarity=item:GetAttribute('Rarity')
    if type(rarity)~='string' or rarity=='' then rarity='Raridade desconhecida' end
    local function valid(value)
        return type(value)=='number' and value==value and math.abs(value)<math.huge and value>=0
    end
    local value=item:GetAttribute('Value')
    local prefix='Valor: '
    if not valid(value) then
        value=item:GetAttribute('BaseValue')
        prefix='Valor base: '
    end
    local price=valid(value) and (prefix..tostring(value)) or 'Valor indisponível'
    return item.Name..'\n'..rarity..' · '..price
end
local function mark(object,caption,color,monster,seen,origin)
    local part=partOf(object)
    if not part then return false end
    seen[object]=true
    local m=app.Marks[object]
    if not m then
        local board=make('BillboardGui',{Name='ZyonMarker',Adornee=part,AlwaysOnTop=true,Size=UDim2.fromOffset(240,monster and 44 or 66),StudsOffsetWorldSpace=Vector3.new(0,3,0)},overlay)
        local label=make('TextLabel',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=color,TextStrokeTransparency=0.35,TextWrapped=true},board)
        m={Board=board,Label=label}
        if monster then m.Highlight=make('Highlight',{Adornee=object,FillColor=color,OutlineColor=color,FillTransparency=0.7,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},board) end
        app.Marks[object]=m
    end
    m.Board.Adornee=part
    m.Label.TextColor3=color
    if m.Highlight then m.Highlight.FillColor=color; m.Highlight.OutlineColor=color end
    m.Label.Text=caption..(origin and string.format('\n%d studs',(part.Position-origin).Magnitude) or '')
    return true
end
local function isEntity(p)
    local char=p.Character
    return p:GetAttribute('IsEntity')==true or (char~=nil and char:GetAttribute('IsEntity')==true)
end
local function refresh()
    fitPanel()
    energyTick(false)
    syncPrompts()
    local seen={}
    local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
    local origin=root and root.Position
    local monsters,items,survivors=0,0,0
    if flags.Monsters then
        for _,p in ipairs(Players:GetPlayers()) do
            local char=p.Character
            local hum=char and char:FindFirstChildOfClass('Humanoid')
            if p~=player and isEntity(p) and char and hum and hum.Health>0 then
                local kind=p:GetAttribute('EntityKind') or char:GetAttribute('EntityKind') or 'Entidade'
                if mark(char,p.DisplayName..' · '..tostring(kind),Color3.fromRGB(255,103,119),true,seen,origin) then monsters+=1 end
            end
        end
    end
    -- No round-membership attribute has been verified: lobby characters may appear.
    local localHum=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
    local survivorActive=flags.Survivors and isEntity(player) and localHum and localHum.Health>0
    if survivorActive then
        for _,p in ipairs(Players:GetPlayers()) do
            local char=p.Character
            local hum=char and char:FindFirstChildOfClass('Humanoid')
            if p~=player and not isEntity(p) and char and hum and hum.Health>0 then
                if mark(char,p.DisplayName..' · Sobrevivente',Color3.fromRGB(70,220,255),true,seen,origin) then
                    survivors+=1
                end
            end
        end
    end
    if flags.Items then
        for _,name in ipairs({'MyLoot','LootItems'}) do
            local folder=workspace:FindFirstChild(name)
            if folder then
                for _,item in ipairs(folder:GetChildren()) do
                    if not seen[item] and rarityMatches(item) and (flags.Filter=='' or item.Name:lower():find(flags.Filter,1,true)) then
                        if mark(item,itemCaption(item),itemColor(item),false,seen,origin) then items+=1 end
                    end
                end
            end
        end
    end
    for object,m in pairs(app.Marks) do
        if not seen[object] then m.Board:Destroy(); app.Marks[object]=nil end
    end
    local corrected=ownedHum and ownedHum.Parent and ownedHum.WalkSpeed~=appliedSpeed
    status.Text=string.format('Monstros: %d · Sobreviventes: %d · Itens: %d\n%s',monsters,survivors,items,corrected and 'O jogo alterou a velocidade aplicada.' or (flags.Survivors and not survivorActive and 'ESP sobreviventes: aguardando você ser monstro vivo.' or 'ESP de jogadores pode incluir quem está no lobby.'))
end
task.spawn(function()
    while app.Alive do
        local ok,err=pcall(refresh)
        if not ok then status.Text='Erro de leitura; consulte o console.'; warn('[Zyon] '..tostring(err)) end
        task.wait(0.5)
    end
end)
app.Show()
return app
