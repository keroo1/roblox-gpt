-- Zyon Steal Or Die 1.1 | Based on client structure reported on 2026-10-29.
-- No remote calls, downloaded libraries, stamina spoofing, or game-module patches.
if game.PlaceId ~= 119925538689885 then error('Zyon: abra Steal Or Die.') end
local Players = game:GetService('Players')
local Input = game:GetService('UserInputService')
local player = Players.LocalPlayer
local env = (type(getgenv) == 'function' and getgenv()) or _G
if env.ZyonStealOrDie then pcall(env.ZyonStealOrDie.Unload) end
local app = {Alive = true, Connections = {}, Marks = {}}
env.ZyonStealOrDie = app
local flags = {Monsters = false, Items = false, Speed = false, Instant = false, Value = 24, Filter = ''}
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
local gui = make('ScreenGui', {Name='ZyonStealOrDie', ResetOnSpawn=false, DisplayOrder=80}, player:WaitForChild('PlayerGui'))
local overlay = make('Folder', {Name='Markers'}, gui)
local panel = make('Frame', {Size=UDim2.fromOffset(350,530), Position=UDim2.new(0.5,-175,0.5,-265), BackgroundColor3=Color3.fromRGB(19,20,29), BorderSizePixel=0}, gui)
make('UICorner', {CornerRadius=UDim.new(0,12)}, panel)
make('UIStroke', {Color=purple, Transparency=0.45}, panel)
local function text(content,y,height)
    return make('TextLabel', {Text=content, Position=UDim2.fromOffset(18,y), Size=UDim2.new(1,-36,0,height), BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=13, TextWrapped=true, TextColor3=Color3.fromRGB(223,224,237), TextXAlignment=Enum.TextXAlignment.Left}, panel)
end
text('ZYON  /  STEAL OR DIE',14,27).Font=Enum.Font.GothamBold
text('1.1  ·  RightCtrl / Insert para abrir e fechar',43,24)
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
local function releasePrompt(prompt,original)
    pcall(function()
        if prompt.Parent and prompt.HoldDuration==0 then prompt.HoldDuration=original end
    end)
    promptOriginals[prompt]=nil
end
local function restorePrompts()
    for prompt,original in pairs(promptOriginals) do releasePrompt(prompt,original) end
end
local function applyPrompt(prompt)
    if app.Alive and flags.Instant and prompt:IsA('ProximityPrompt') and inLoot(prompt) then
        if promptOriginals[prompt]==nil then
            promptOriginals[prompt]=prompt.HoldDuration
            prompt.HoldDuration=0
        end
    end
end
local function syncPrompts()
    for prompt,original in pairs(promptOriginals) do
        if not flags.Instant or not prompt.Parent or not inLoot(prompt) then releasePrompt(prompt,original) end
    end
    if not flags.Instant then return end
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
local status=text('Pronto. Ative os marcadores desejados.',431,44)
toggle('Monsters','ESP monstros',82)
text('Nome, tipo e distância; usa o atributo IsEntity.',119,27)
toggle('Items','ESP itens',151)
local filter=make('TextBox',{Text='',PlaceholderText='Filtrar itens pelo nome (opcional)',ClearTextOnFocus=false,Position=UDim2.fromOffset(18,193),Size=UDim2.new(1,-36,0,30),BackgroundColor3=Color3.fromRGB(30,31,43),TextColor3=Color3.new(1,1,1),PlaceholderColor3=Color3.fromRGB(157,158,177),Font=Enum.Font.Gotham,TextSize=12,BorderSizePixel=0},panel)
connect(filter:GetPropertyChangedSignal('Text'),function() flags.Filter=filter.Text:lower() end)
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
toggle('Speed','Velocidade local',236,setSpeed)
text('Valor (8–80):',279,28)
local speed=make('TextBox',{Text='24',ClearTextOnFocus=false,Position=UDim2.fromOffset(230,279),Size=UDim2.fromOffset(100,28),BackgroundColor3=Color3.fromRGB(38,37,53),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=14,BorderSizePixel=0},panel)
connect(speed.FocusLost,function()
    local n=tonumber(speed.Text)
    if n and n==n and math.abs(n)<math.huge then flags.Value=math.clamp(n,8,80) end
    speed.Text=tostring(flags.Value)
    setSpeed()
end)
toggle('Instant','Interação instantânea · itens',317,syncPrompts)
text('Remove a espera de segurar; coleta continua manual.',354,27)
text('Estamina infinita: indisponível nesta versão.\nO saldo real ainda não foi identificado.',387,40)
function app.Unload()
    if not app.Alive then return end
    app.Alive=false
    restorePrompts()
    restoreSpeed()
    for _,c in ipairs(app.Connections) do c:Disconnect() end
    gui:Destroy()
    if env.ZyonStealOrDie==app then env.ZyonStealOrDie=nil end
end
action('Descarregar hub',480,app.Unload)
local reopen=make('TextButton',{Text='Z',Size=UDim2.fromOffset(42,42),Position=UDim2.new(0,12,0.5,-21),BackgroundColor3=Color3.fromRGB(38,37,53),TextColor3=purple,Font=Enum.Font.GothamBold,TextSize=20},gui)
make('UICorner',{CornerRadius=UDim.new(0,10)},reopen)
local function switch() panel.Visible=not panel.Visible end
connect(reopen.Activated,switch)
connect(Input.InputBegan,function(input)
    if not Input:GetFocusedTextBox() and (input.KeyCode==Enum.KeyCode.RightControl or input.KeyCode==Enum.KeyCode.Insert) then switch() end
end)
connect(player.CharacterAdded,function(char)
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
local function mark(object,caption,color,monster,seen,origin)
    local part=partOf(object)
    if not part then return false end
    seen[object]=true
    local m=app.Marks[object]
    if not m then
        local board=make('BillboardGui',{Name='ZyonMarker',Adornee=part,AlwaysOnTop=true,Size=UDim2.fromOffset(190,44),StudsOffsetWorldSpace=Vector3.new(0,3,0)},overlay)
        local label=make('TextLabel',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=color,TextStrokeTransparency=0.35,TextWrapped=true},board)
        m={Board=board,Label=label}
        if monster then m.Highlight=make('Highlight',{Adornee=object,FillColor=color,OutlineColor=color,FillTransparency=0.7,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},board) end
        app.Marks[object]=m
    end
    m.Board.Adornee=part
    m.Label.Text=caption..(origin and string.format('\n%d studs',(part.Position-origin).Magnitude) or '')
    return true
end
local function refresh()
    syncPrompts()
    local seen={}
    local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
    local origin=root and root.Position
    local monsters,items=0,0
    if flags.Monsters then
        for _,p in ipairs(Players:GetPlayers()) do
            local char=p.Character
            local hum=char and char:FindFirstChildOfClass('Humanoid')
            if p~=player and p:GetAttribute('IsEntity')==true and char and hum and hum.Health>0 then
                local kind=p:GetAttribute('EntityKind') or char:GetAttribute('EntityKind') or 'Entidade'
                if mark(char,p.DisplayName..' · '..tostring(kind),Color3.fromRGB(255,103,119),true,seen,origin) then monsters+=1 end
            end
        end
    end
    if flags.Items then
        for _,name in ipairs({'MyLoot','LootItems'}) do
            local folder=workspace:FindFirstChild(name)
            if folder then
                for _,item in ipairs(folder:GetChildren()) do
                    if not seen[item] and (flags.Filter=='' or item.Name:lower():find(flags.Filter,1,true)) then
                        if mark(item,item.Name,Color3.fromRGB(116,224,185),false,seen,origin) then items+=1 end
                    end
                end
            end
        end
    end
    for object,m in pairs(app.Marks) do
        if not seen[object] then m.Board:Destroy(); app.Marks[object]=nil end
    end
    local corrected=ownedHum and ownedHum.Parent and ownedHum.WalkSpeed~=appliedSpeed
    status.Text=string.format('Monstros: %d  ·  Itens: %d\n%s',monsters,items,corrected and 'O jogo alterou a velocidade aplicada.' or 'Marcadores dos objetos carregados no cliente.')
end
task.spawn(function()
    while app.Alive do
        local ok,err=pcall(refresh)
        if not ok then status.Text='Erro de leitura; consulte o console.'; warn('[Zyon] '..tostring(err)) end
        task.wait(0.5)
    end
end)
return app
