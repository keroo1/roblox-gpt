-- Zyon Aftermath 1.0. World markers based on user-provided structure reports.
-- No remote calls or third-party libraries. Character-dependent features await mapping.
if game.GameId~=5286749994 then error('Abra o Aftermath antes de executar.') end
local Players=game:GetService('Players')
local Input=game:GetService('UserInputService')
local Run=game:GetService('RunService')
local p=Players.LocalPlayer
local env=type(getgenv)=='function' and getgenv() or _G
if env.ZyonAftermath then pcall(env.ZyonAftermath.Unload) end
local app={Alive=true,Connections={},Marks={},Objects={}}
env.ZyonAftermath=app
local cfg={Vehicles=true,Graves=true,Events=false,Distance=8000,Filter=''}
local accent=Color3.fromRGB(161,137,255)
local function make(class,props,parent)
    local o=Instance.new(class)
    for k,v in pairs(props) do o[k]=v end
    o.Parent=parent
    return o
end
local function connect(signal,fn)
    table.insert(app.Connections,signal:Connect(fn))
end
local gui=make('ScreenGui',{Name='ZyonAftermath',Enabled=true,ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=500,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},nil)
local ok=false
if type(gethui)=='function' then ok=pcall(function() gui.Parent=gethui(); assert(gui.Parent) end) end
if not ok then ok=pcall(function() gui.Parent=game:GetService('CoreGui') end) end
if not ok then gui.Parent=p:WaitForChild('PlayerGui') end
local panel=make('ScrollingFrame',{Size=UDim2.fromOffset(390,610),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=Color3.fromRGB(18,20,29),BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,780),ScrollBarThickness=4},gui)
make('UICorner',{CornerRadius=UDim.new(0,12)},panel)
make('UIStroke',{Color=accent,Transparency=.4},panel)
local function label(text,y,h)
    return make('TextLabel',{Text=text,Position=UDim2.fromOffset(18,y),Size=UDim2.new(1,-36,0,h),BackgroundTransparency=1,TextColor3=Color3.fromRGB(224,226,238),TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},panel)
end
local function button(text,y,fn)
    local b=make('TextButton',{Text=text,Position=UDim2.fromOffset(18,y),Size=UDim2.new(1,-36,0,36),BackgroundColor3=Color3.fromRGB(37,38,54),TextColor3=Color3.new(1,1,1),TextSize=13,Font=Enum.Font.GothamMedium,BorderSizePixel=0},panel)
    make('UICorner',{CornerRadius=UDim.new(0,7)},b)
    connect(b.Activated,fn)
    return b
end
local function toggle(key,title,y)
    local b
    local function paint() b.Text=title..(cfg[key] and '  /  ON' or '  /  OFF'); b.TextColor3=cfg[key] and accent or Color3.new(1,1,1) end
    b=button('',y,function() cfg[key]=not cfg[key]; paint() end)
    paint()
end
label('ZYON / AFTERMATH',16,28).Font=Enum.Font.GothamBold
label('1.0 · RightCtrl / Insert · marcadores do mundo',48,28)
toggle('Vehicles','ESP veículos',90)
label('Tipo, distância, combustível, bateria e vida disponíveis.',132,36)
toggle('Graves','ESP restos de jogadores · PlayerGrave',178)
label('Marca PlayerGrave. Dono e loot ainda não identificados.',220,36)
toggle('Events','ESP helicóptero e posição do airdrop',266)
label('Distância máxima da câmera (studs):',312,26)
local range=make('TextBox',{Text='8000',ClearTextOnFocus=false,Position=UDim2.fromOffset(18,344),Size=UDim2.new(1,-36,0,30),BackgroundColor3=Color3.fromRGB(37,38,54),TextColor3=Color3.new(1,1,1),TextSize=14,Font=Enum.Font.Gotham},panel)
connect(range.FocusLost,function()
    local n=tonumber(range.Text)
    if n and n==n and math.abs(n)<math.huge then cfg.Distance=math.clamp(n,50,25000) end
    range.Text=tostring(cfg.Distance)
end)
local filter=make('TextBox',{Text='',PlaceholderText='Filtrar marcadores pelo nome',ClearTextOnFocus=false,Position=UDim2.fromOffset(18,386),Size=UDim2.new(1,-36,0,30),BackgroundColor3=Color3.fromRGB(37,38,54),TextColor3=Color3.new(1,1,1),TextSize=13,Font=Enum.Font.Gotham},panel)
connect(filter:GetPropertyChangedSignal('Text'),function() cfg.Filter=filter.Text:lower() end)
local status=label('Buscando objetos carregados...',430,50)
label('Jogadores, aimbot, itens, auto loot e movimento: aguardam identificação do sistema personalizado do jogo.',488,66)
local diagStatus=label('Diagnóstico: aproxime-se de loot ou jogador e use o botão abaixo.',562,46)
local function category(o)
    if not o:IsA('Model') then return nil end
    if type(o:GetAttribute('VehicleType'))=='string' then return 'Vehicles' end
    if o.Name=='PlayerGrave' then return 'Graves' end
    if o.Name=='HeliModel' and o:FindFirstChild('Root') then return 'Events' end
    if o.Name=='Container' and typeof(o:GetAttribute('GroundCFrame'))=='CFrame' then return 'Events' end
end
local function addObject(o)
    if o:IsA('Model') then
        local key=category(o)
        if key then app.Objects[o]=key end
    end
end
local function removeMark(o)
    local m=app.Marks[o]
    if m then m:Destroy(); app.Marks[o]=nil end
end
local function finite(v) return type(v)=='number' and v==v and math.abs(v)<math.huge end
local function ratio(states,name)
    local v=states and states:GetAttribute(name)
    local max=states and states:GetAttribute('Max'..name)
    if not finite(v) then return nil end
    return name..': '..math.floor(v)..(finite(max) and max>0 and ('/'..math.floor(max)) or '')
end
local function point(o)
    local part=o.PrimaryPart or o:FindFirstChildWhichIsA('BasePart',true)
    if part then return part.Position end
    local cf=o:GetAttribute('GroundCFrame')
    return typeof(cf)=='CFrame' and cf.Position or nil
end
local function caption(o,key)
    if key=='Graves' then return 'Restos de jogador · PlayerGrave',Color3.fromRGB(255,180,95) end
    if key=='Vehicles' then
        local states=o:FindFirstChild('States')
        local parts={tostring(o:GetAttribute('VehicleType'))}
        for _,name in ipairs({'Fuel','Battery','Health'}) do local s=ratio(states,name); if s then table.insert(parts,s) end end
        return table.concat(parts,' · '),Color3.fromRGB(95,205,255)
    end
    return o.Name=='HeliModel' and 'Helicóptero' or 'Airdrop · posição de pouso',Color3.fromRGB(204,150,255)
end
local function refresh()
    local cam=workspace.CurrentCamera
    if not cam then return end
    local viewport=cam.ViewportSize
    panel.Size=UDim2.fromOffset(math.min(390,math.max(180,viewport.X-24)),math.min(610,math.max(180,viewport.Y-32)))
    local count={Vehicles=0,Graves=0,Events=0}
    for o,key in pairs(app.Objects) do
        if not o:IsDescendantOf(workspace) then removeMark(o); app.Objects[o]=nil
        else
            count[key]+=1
            local pos=point(o)
            local title,color=caption(o,key)
            local distance=pos and (pos-cam.CFrame.Position).Magnitude or math.huge
            if cfg[key] and pos and distance<=cfg.Distance and title:lower():find(cfg.Filter,1,true) then
                local screen,visible=cam:WorldToViewportPoint(pos)
                local m=app.Marks[o]
                if not m then
                    m=make('TextLabel',{Name='Marker',AnchorPoint=Vector2.new(.5,1),Size=UDim2.fromOffset(300,56),BackgroundColor3=Color3.fromRGB(15,17,24),BackgroundTransparency=.3,BorderSizePixel=0,TextSize=12,Font=Enum.Font.GothamMedium,TextWrapped=true,TextStrokeTransparency=.55,ZIndex=2},gui)
                    make('UICorner',{CornerRadius=UDim.new(0,5)},m)
                    app.Marks[o]=m
                end
                m.Visible=visible and screen.Z>0
                m.Position=UDim2.fromOffset(screen.X,screen.Y)
                m.TextColor3=color
                m.Text=title..string.format('\n%d studs · câmera',distance)
            else removeMark(o) end
        end
    end
    status.Text=string.format('Carros: %d · PlayerGrave: %d · Eventos: %d\nSomente objetos presentes no cliente.',count.Vehicles,count.Graves,count.Events)
end
-- Bounded read-only report: include all names/attributes on selected samples.
local function diagnostic()
    local rows={'ZYON / AFTERMATH — MAPEAMENTO 1.2','GameId='..game.GameId}
    local function write(s) table.insert(rows,s) end
    local function node(o,depth,budget)
        if budget.n>=budget.max then return end
        budget.n+=1
        write(o.ClassName..' | '..o:GetFullName())
        for k,v in pairs(o:GetAttributes()) do write('  @'..k..' = '..tostring(v):sub(1,180)) end
        if o:IsA('ObjectValue') then write('  Value='..(o.Value and o.Value:GetFullName() or 'nil'))
        elseif o:IsA('ValueBase') then write('  Value='..tostring(o.Value):sub(1,180)) end
        if depth>0 then for _,child in ipairs(o:GetChildren()) do node(child,depth-1,budget) end end
    end
    local function section(title,o,depth,max)
        write('\n--- '..title..' ---')
        if o then node(o,depth,{n=0,max=max}) else write('Ausente') end
    end
    section('JOGADOR LOCAL',p,0,1)
    local assets=workspace:FindFirstChild('game_assets')
    local entities=assets and assets:FindFirstChild('Entities')
    section('ENTITIES',entities,3,160)
    local cd=workspace:FindFirstChild('CharDatas')
    section('CHARDATAS',cd,2,110)
    local n=0
    for _,other in ipairs(Players:GetPlayers()) do
        if other~=p and n<3 then section('OUTRO JOGADOR',other,1,25); n+=1 end
    end
    for _,o in ipairs(workspace:GetChildren()) do
        if o.Name=='Default' then section('DEFAULT / LOOT OU GRAVE',o,4,45) end
    end
    section('DINÂMICOS',workspace:FindFirstChild('world_assets') and workspace.world_assets:FindFirstChild('DynamicObjects'),3,90)
    local report=table.concat(rows,'\n')
    print(report)
    local copied=false
    if type(setclipboard)=='function' then copied=pcall(setclipboard,report) end
    diagStatus.Text=copied and 'Relatório copiado. Cole no chat.' or 'Relatório disponível no console.'
end
button('Copiar diagnóstico de jogadores e loot',616,function()
    local success,err=pcall(diagnostic)
    if not success then diagStatus.Text='Falha: '..tostring(err) end
end)
function app.Unload()
    if not app.Alive then return end
    app.Alive=false
    for _,c in ipairs(app.Connections) do c:Disconnect() end
    gui:Destroy()
    if env.ZyonAftermath==app then env.ZyonAftermath=nil end
end
button('Descarregar hub',716,app.Unload)
local reopen=make('TextButton',{Text='Z',Size=UDim2.fromOffset(42,42),Position=UDim2.new(0,12,.5,-21),BackgroundColor3=Color3.fromRGB(37,38,54),TextColor3=accent,Font=Enum.Font.GothamBold,TextSize=20},gui)
panel.ZIndex=10
for _,o in ipairs(panel:GetDescendants()) do if o:IsA('GuiObject') then o.ZIndex=11 end end
reopen.ZIndex=12
local function togglePanel() panel.Visible=not panel.Visible end
connect(reopen.Activated,togglePanel)
connect(Input.InputBegan,function(input,processed)
    if not processed and not Input:GetFocusedTextBox() and (input.KeyCode==Enum.KeyCode.RightControl or input.KeyCode==Enum.KeyCode.Insert) then togglePanel() end
end)
connect(workspace.DescendantAdded,function(o)
    if o:IsA('Model') then task.defer(function() if app.Alive then addObject(o) end end) end
end)
task.spawn(function()
    for i,o in ipairs(workspace:GetDescendants()) do
        if not app.Alive then return end
        addObject(o)
        if i%500==0 then task.wait() end
    end
    while app.Alive do
        -- Root models may receive attributes after parenting.
        for _,o in ipairs(workspace:GetChildren()) do addObject(o) end
        task.wait(2)
    end
end)
local elapsed=0
connect(Run.RenderStepped,function(dt)
    elapsed+=dt
    if elapsed<.05 then return end
    elapsed=0
    local success,err=pcall(refresh)
    if not success then status.Text='Falha nos marcadores: '..tostring(err) end
end)
return app
