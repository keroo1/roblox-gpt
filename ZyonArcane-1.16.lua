-- Luau | ZyonArcane.lua | Arcane Lineage / Xeno | 1.16
-- Original HUD/controller implementation; protocol and destination reference:
-- https://github.com/anwarlopoo/Freemium/blob/main/games/arcane_lineage.lua
-- Reference SHA256: d3291b8c9fcd004a36c1e8d6ff00bf415ecede6ac210473d91a93dadc87db8ab
-- No external code downloads. Game modules supply the seeded QTE rules.
local arcane_help = {
	["Mouse livre fora do hub"] = "Desligado por padrão para respeitar o Shift Lock e a câmera do jogo. Ligue apenas se quiser forçar o mouse solto com o painel fechado. O painel aberto libera o cursor temporariamente e restaura o estado anterior ao fechar.",
	["Noclip manual"] = "Desativa colisões do personagem enquanto ligado. Pode atravessar paredes e pisos; prefira o modo automático para viagens. Ao desligar, restaura cada parte ao valor anterior.",
	["Noclip nos deslocamentos"] = "Usa Tween sem colisões em viagens e coleta, mesmo com Caminhar selecionado. Restaura ao chegar ou cancelar, salvo com Noclip manual ligado. Alterar esta opção cancela o percurso atual.",
	["Auto Fight · ativar combate"] = "Liga ataque no seu turno, Auto Dodge e QTE de armas. Ajuste a prioridade de habilidades. O jogo precisa iniciar o combate e aceitar cada ação.",
	["NPC / boss do farm"] = "Escolha o inimigo. O farm só aceita revanche após identificá-lo na equipe inimiga. Outros nomes observados em combate também entram na lista.",
	["Drop desejado"] = "Escolha um exemplo de drop do inimigo. A lista é uma referência da comunidade, pode estar desatualizada e não é completa. Não altera a chance de drop.",
	["Outro item · nome exato"] = "Opcional: substitui o drop escolhido pelo nome informado. A confirmação exige uma Tool com esse nome na mochila ou no personagem; outros inventários não são interpretados.",
	["Novas unidades desejadas"] = "Quantas unidades adicionais precisam aparecer como Tools, comparadas ao início da sessão. Itens que você já tinha não completam a meta.",
	["Farm até obter item"] = "Liga combate e QTEs e monitora o item. Inicie o primeiro encontro manualmente. Revanches só são aceitas para o alvo identificado; para ao confirmar a meta ou atingir limites.",
	["Repetir revanche do alvo"] = "Aceita a oferta RefightBoss apenas quando o ID corresponde a um combate reconhecido com o alvo. Não invoca bosses nem ignora condições de entrada.",
	["Espera antes da revanche"] = "Aguarda esse tempo para o inventário atualizar antes de repetir. A meta e os limites são conferidos novamente antes da resposta ao servidor.",
	["Limite de combates · 0 sem limite"] = "Interrompe após esta quantidade de combates encerrados com o alvo. Um encerramento não confirma vitória. Zero remove esse limite.",
	["Tempo máximo · 0 sem limite"] = "Duração máxima da sessão de farm de drops, em minutos. Zero deixa a sessão sem limite de tempo.",
	["Parar abaixo de HP"] = "Interrompe as novas ações do farm ao atingir essa porcentagem de vida. Não foge do combate nem impede dano do servidor.",
	["Atualizar leitura do inventário"] = "Mostra quantas Tools do nome escolhido estão na mochila e equipadas. Durante o farm, também verifica a meta. Não confirma itens guardados em outro sistema.",
	["Ir até a entrada do alvo"] = "Vai à coordenada cadastrada da entrada de Yar'thul ou Thorian. O encontro inicial continua manual. Alvos sem coordenada geram um aviso.",
	["Parar farm de drops"] = "Encerra a sessão e cancela revanches pendentes. Restaura os interruptores de combate que o farm ligou, quando ainda estão no valor aplicado.",
	["Auto Farm Yar'thul"] = "Seleciona Yar'thul, liga o farm e a revanche e vai à entrada quando fora de combate. Escolha antes o drop desejado; comece o primeiro combate manualmente.",
	["Auto Leveling / XP"] = "Patrulha o ponto salvo e luta nos encontros. Só essência para na meta. Leveling com Aretim tenta meditar, abrir o diálogo e concluir atributos, verificando as respostas.",
	["Modo de progressão"] = "Só essência encerra na meta. Leveling com Aretim continua até meditação e atributos, exigindo firesignal e fireproximityprompt no executor.",
	["Ciclos de leveling"] = "Número de ciclos com atributos concluídos e consumo de essência confirmado. Um ciclo pode subir vários níveis; não é um contador de níveis.",
	["Tempo máximo de leveling"] = "Encerra a sessão após esse tempo total, incluindo encontros, viagens e espera por interfaces. Evita uma patrulha indefinida sem progresso.",
	["Parar leveling abaixo de HP"] = "Interrompe a automação ao atingir essa porcentagem de vida. Não foge de um combate já iniciado nem impede novos ataques do servidor.",
	["Distribuição de atributos"] = "Manual pausa com a tela de atributos aberta. Escolher um atributo distribui todos os pontos disponíveis nele, um por vez, e verifica a redução do saldo.",
	["Parar leveling"] = "Interrompe o percurso e o ciclo de leveling. Restaura os interruptores de combate ativados por esta sessão; não desfaz pontos já gastos.",
	["Coletar quais itens"] = "Todos considera qualquer tipo de item. Selecionados coleta somente os nomes marcados na lista. A seleção vazia não coleta nada nesse modo.",
	["Itens para coletar"] = "Marque vários tipos de itens para o modo Selecionados. A lista reúne os itens coletáveis encontrados no mapa carregado e mantém os nomes descobertos nesta sessão.",
	["Atualizar lista de itens"] = "Reexamina SpawnedItems. Novos tipos também aparecem automaticamente. Itens que o jogo ainda não carregou no cliente não podem ser identificados.",
	["Selecionar todos os itens"] = "Marca todos os tipos conhecidos e muda para Selecionados. Tipos descobertos depois precisam ser marcados; use Todos para aceitar também os futuros.",
	["Limpar seleção de itens"] = "Desmarca todos os nomes e ativa Selecionados. A coleta fica sem alvos até você marcar algum item ou voltar ao modo Todos.",
	["Buscar em todo mapa carregado"] = "Ignora o limite de alcance e busca em todos os itens carregados em SpawnedItems. Desligue para respeitar Alcance de busca. Pausa durante o combate.",
	["Auto Dodge"] = "Acompanha a linha branca da barra Stop e envia Space na faixa amarela. Minimize o hub e feche o chat durante o QTE. O diagnóstico mostra a detecção e o envio da entrada.",
	["Anti-Steal"] = "Responde ao Stop da barra apenas amarela, como o Steal mostrado pelo jogo. Não inicia a habilidade Steal. Minimize o painel durante o QTE.",
	["Antecipação Dodge"] = "Compensa o atraso de entrada. Padrão: 15 ms de antecipação adicional. Reduza se parar antes do centro; aumente um pouco se parar depois.",
	["Antecipação Anti-Steal"] = "Antecipação adicional para a barra amarela do Steal. Padrão: 15 ms; ajuste ao atraso do seu cliente.",
	["Auto QTE de armas"] = "Resolve QTEs de armas compatíveis. Se um tipo não puder ser resolvido, a função original do jogo continua responsável por ele.",
	["Auto Thorian QTE"] = "Ativa a resolução específica do QTE de Thorian. Depende de o módulo ou callback correspondente ser encontrado.",
	["Espera extra"] = "Adiciona espera aos QTEs de armas. O Auto Dodge visual usa a posição da barra e não aplica esta espera.",
	["Reexaminar integrações"] = "Procura novamente os módulos e callbacks de QTE e drops. Use depois que a interface de combate aparecer ou mudar.",
	["Buscar callbacks via getgc"] = "Faz uma busca opcional e limitada por funções de QTE nas tabelas do cliente. Depende do suporte do executor; veja o resultado no diagnóstico.",
	["Atacar no próprio turno"] = "Escolhe um inimigo da equipe retornada pelo jogo e envia uma ação por turno. Respeita a prioridade de habilidades e a energia disponível.",
	["Ataque preferido"] = "Habilidade usada depois da lista de prioridade. Atualize as habilidades com a tela de combate aberta. Strike é o ataque de reserva.",
	["Prioridade · nomes separados por vírgula"] = "Digite os nomes exatos em ordem, como Fire, Strike. O primeiro ataque disponível é escolhido; habilidades desconhecidas são ignoradas.",
	["Intervalo mínimo"] = "Tempo mínimo entre tentativas de ataque. Reduzir esse valor não cria turnos extras nem remove cooldowns do jogo.",
	["Atualizar habilidades"] = "Lê as habilidades presentes na interface do jogo e atualiza a seleção. Use ao aprender uma habilidade ou mudar de arma.",
	["Aceitar disputa de drops"] = "Aceita automaticamente participar da disputa de um item oferecido pelo jogo. Participar não garante ganhar o item.",
	["Aceitar revanche de boss"] = "Responde Accept quando o jogo oferece uma revanche de boss. Pode iniciar outro combate sem um clique manual.",
	["Auto coletar itens"] = "Busca itens em SpawnedItems, vai até o alvo e tenta clicar no detector. Exige fireclickdetector e pausa durante o combate.",
	["Alcance de busca"] = "Distância máxima, em studs, para procurar um item a partir do personagem. Um alcance maior pode gerar percursos mais longos.",
	["Filtrar por parte do nome"] = "Filtro adicional: o nome também precisa conter este texto, mesmo se estiver marcado na lista. Deixe vazio para usar somente a seleção por tipo.",
	["Repetir tentativa após"] = "Espera mínima antes de tentar o mesmo item novamente. Aumente se um item que não pode ser coletado estiver prendendo o farm.",
	["Método"] = "Caminhar usa rotas e MoveTo. Tween desloca o personagem em linha direta. Os dois modos podem ser interrompidos ao entrar em combate.",
	["Velocidade de deslocamento"] = "Ajusta de 10 a 500 studs/s as próximas viagens em Tween, inclusive coleta, bosses e leveling com Noclip automático. Pode digitar o valor. Não altera Caminhar; nesse modo use WalkSpeed.",
	["Cancelar deslocamento"] = "Interrompe o percurso atual e restaura as colisões alteradas. A coleta automática pode escolher outra rota depois; desligue-a para parar tudo.",
	["Patrulhar ponto de encontro"] = "Anda de um lado para o outro perto do ponto salvo para buscar encontros. Defina o ponto primeiro. Pausa no combate e para na meta de essência.",
	["Meta de essência"] = "Quantidade de essência que faz a patrulha parar. O valor é lido do HUD. Atingir a meta não compra classe nem faz reset do personagem.",
	["Raio de patrulha"] = "Distância lateral percorrida a partir do ponto salvo. Use um raio que caiba na área de encontro escolhida.",
	["Usar minha posição como encontro"] = "Salva sua posição atual para a patrulha de essência. Vá até uma área de encontro antes de clicar; o ponto dura só nesta sessão.",
	["Destino"] = "Seleciona uma posição da lista de cidades, bosses, treinadores e serviços. As coordenadas vieram da referência e podem mudar no jogo.",
	["Ir ao destino"] = "Inicia o percurso para o destino selecionado usando o método de movimento atual. Não inicia diálogos nem compra itens ao chegar.",
	["Cancelar percurso"] = "Interrompe a viagem em andamento e restaura as colisões alteradas. Não desliga as outras automações.",
	["NPC"] = "Seleciona um NPC encontrado no mapa carregado pelo seu cliente. Um NPC distante ou ainda não carregado pode não aparecer.",
	["Atualizar NPCs"] = "Reexamina a pasta de NPCs e atualiza a lista. Use se o NPC desejado acabou de carregar ou desaparecer.",
	["Ir ao NPC"] = "Vai até o NPC selecionado usando sua posição atual. Não aciona diálogos ou serviços automaticamente.",
	["ESP de itens"] = "Mostra o nome dos itens carregados no mundo. O marcador ajuda a localizar o item, mas não confirma que ele já foi coletado.",
	["ESP de jogadores"] = "Mostra marcadores com o nome dos outros jogadores carregados no seu cliente. Não seleciona alvos de combate.",
	["ESP de mercadores"] = "Mostra marcadores dos mercadores encontrados nas pastas conhecidas do mapa. Nem todo NPC é tratado como mercador.",
	["Mostrar distância"] = "Adiciona a distância em studs aos marcadores ESP. A distância é medida a partir do seu personagem.",
	["Distância máxima"] = "Oculta marcadores ESP além deste alcance. Reduza para deixar a tela menos cheia.",
	["Fullbright"] = "Ajusta iluminação, horário e sombras apenas no seu cliente para melhorar a visibilidade. Os valores anteriores são restaurados ao desligar.",
	["Alterar velocidade"] = "Ativa o valor de WalkSpeed abaixo. Ao desligar, restaura a velocidade anterior. O servidor pode corrigir mudanças locais.",
	["WalkSpeed"] = "Velocidade de caminhada desejada. Só é aplicada com Alterar velocidade ligado; também afeta o deslocamento pelo modo Caminhar.",
	["Alterar salto"] = "Ativa a potência de salto configurada abaixo. Ao desligar, restaura a potência e a altura anteriores.",
	["JumpPower"] = "Potência do salto. Se o personagem usar altura em vez de potência, o script calcula a altura equivalente com a gravidade atual.",
	["Salto infinito"] = "Permite pedir outro salto no ar. Funciona com o painel fechado, fora de combate e sem uma caixa de texto selecionada.",
	["Salvar configuração"] = "Salva os valores atuais em ZyonArcane-config.json, na pasta interna do executor. Uma configuração anterior com esse nome é substituída.",
	["Carregar configuração"] = "Aplica o perfil salvo, inclusive os interruptores ligados. Algumas automações podem começar imediatamente após carregar.",
	["Copiar diagnóstico"] = "Copia o estado das integrações e os erros capturados. Também tenta salvar um arquivo no executor para ajudar a investigar falhas.",
	["Parar automações"] = "Desliga as automações e os efeitos configurados, cancela o movimento e mantém o painel aberto para ajustes.",
	["Unload"] = "Encerra a sessão, restaura as alterações controladas pelo script e remove o HUD e o cursor. Execute o arquivo novamente para voltar.",
}

local function create_arcane_help(ui, make, label, button, round, border, gui, input, colors)
	local panel = make(
		"Frame",
		{
			Name = "FunctionHelp",
			Size = UDim2.fromOffset(360, 160),
			BackgroundColor3 = colors.panel,
			BorderSizePixel = 0,
			Visible = false,
			Active = true,
			ZIndex = 100,
		},
		gui
	)
	round(panel, 9)
	border(panel)
	local heading = label(panel, "", 14)
	heading.Name = "HelpTitle"
	heading.Position = UDim2.fromOffset(14, 10)
	heading.Size = UDim2.new(1, -28, 0, 36)
	heading.TextWrapped = true
	heading.TextTruncate = Enum.TextTruncate.None
	heading.Font = Enum.Font.BuilderSansBold
	heading.TextColor3 = colors.accent
	heading.ZIndex = 101
	local body = label(panel, "", 13)
	body.Name = "HelpBody"
	body.Position = UDim2.fromOffset(14, 52)
	body.Size = UDim2.new(1, -28, 1, -64)
	body.TextWrapped = true
	body.TextTruncate = Enum.TextTruncate.None
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.ZIndex = 101
	local active, pinned
	ui.HelpButtons = {}
	ui.HelpDescriptions = {}
	ui.HelpTooltip = panel
	local function hide()
		panel.Visible = false
		active = nil
		pinned = false
	end
	local function position()
		if not active then
			return
		end
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local viewport = camera.ViewportSize
		local width = math.max(120, math.min(360, viewport.X - 24))
		panel.Size = UDim2.fromOffset(width, 160)
		local point = active.AbsolutePosition
		local size = active.AbsoluteSize
		local x = math.clamp(point.X + size.X + 10, 8, math.max(8, viewport.X - width - 8))
		local y = math.clamp(point.Y, 8, math.max(8, viewport.Y - 160 - 8))
		panel.Position = UDim2.fromOffset(x, y)
	end
	local function show(icon, text, sticky)
		active = icon
		pinned = sticky
		heading.Text = text
		body.Text = arcane_help[text]
		position()
		panel.Visible = true
	end
	local function attach(row, text)
		local description = arcane_help[text]
		if not description then
			return
		end
		local icon = button(row, "?")
		icon.Name = "HelpIcon"
		icon.Size = UDim2.fromOffset(18, 18)
		icon.Position = UDim2.new(1, -18, 0, 4)
		icon.TextSize = 13
		icon.TextColor3 = colors.accent
		icon.BackgroundColor3 = colors.raised
		round(icon, 9)
		ui.HelpButtons[text] = icon
		ui.HelpDescriptions[text] = description
		ui:Connect(icon.MouseEnter, function()
			if not pinned then
				show(icon, text, false)
			end
		end)
		ui:Connect(icon.MouseLeave, function()
			if active == icon and not pinned then
				hide()
			end
		end)
		ui:Connect(icon.Activated, function()
			if active == icon and pinned then
				hide()
			else
				show(icon, text, true)
			end
		end)
	end
	local function contains(object, x, y)
		local p, s = object.AbsolutePosition, object.AbsoluteSize
		return x >= p.X and x <= p.X + s.X and y >= p.Y and y <= p.Y + s.Y
	end
	ui:Connect(input.InputBegan, function(event)
		if not panel.Visible then
			return
		end
		if event.KeyCode == Enum.KeyCode.Escape then
			hide()
			return
		end
		if
			event.UserInputType == Enum.UserInputType.MouseButton1
			or event.UserInputType == Enum.UserInputType.Touch
		then
			local point = event.Position or input:GetMouseLocation()
			if not contains(panel, point.X, point.Y) and not (active and contains(active, point.X, point.Y)) then
				hide()
			end
		end
	end)
	return attach, hide, position
end

-- Zyon HUD: local UI, no downloaded libraries.
local function create_hud()
	local players = game:GetService("Players")
	local input = game:GetService("UserInputService")
	local run = game:GetService("RunService")
	local ui = { Options = {}, Connections = {}, Open = true, Unloaded = false, Errors = {}, ModuleStatus = {} }
	local colors = {
		bg = Color3.fromRGB(18, 21, 24),
		panel = Color3.fromRGB(26, 30, 34),
		raised = Color3.fromRGB(36, 41, 46),
		line = Color3.fromRGB(58, 64, 69),
		text = Color3.fromRGB(236, 239, 248),
		muted = Color3.fromRGB(177, 185, 197),
		accent = Color3.fromRGB(222, 176, 105),
		danger = Color3.fromRGB(255, 112, 133),
	}
	local function make(class, props, parent)
		local obj = Instance.new(class)
		for key, value in pairs(props or {}) do
			obj[key] = value
		end
		obj.Parent = parent
		return obj
	end
	local function round(obj, radius)
		make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, obj)
	end
	local function border(obj)
		make("UIStroke", { Color = colors.line, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, obj)
	end
	local function label(parent, text, size)
		return make(
			"TextLabel",
			{
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = colors.text,
				Font = Enum.Font.BuilderSans,
				TextSize = size or 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, 0, 0, 22),
			},
			parent
		)
	end
	local function button(parent, text)
		local obj = make(
			"TextButton",
			{
				BackgroundColor3 = colors.raised,
				BorderSizePixel = 0,
				AutoButtonColor = true,
				Text = text,
				TextColor3 = colors.text,
				TextSize = 13,
				Font = Enum.Font.BuilderSansMedium,
				Size = UDim2.new(1, 0, 0, 32),
			},
			parent
		)
		round(obj, 7)
		return obj
	end
	function ui:Connect(signal, callback)
		local conn = signal:Connect(callback)
		table.insert(self.Connections, conn)
		return conn
	end
	function ui:RecordError(area, err)
		local entry = self.Errors[area] or { count = 0 }
		entry.count += 1
		entry.message = tostring(err)
		self.Errors[area] = entry
		if entry.count == 1 then
			warn("[Zyon / " .. area .. "] " .. entry.message)
		end
	end
	function ui:Run(area, callback, ...)
		if self.Unloaded then
			return false
		end
		local result = table.pack(pcall(callback, ...))
		if not result[1] then
			self:RecordError(area, result[2])
		end
		return table.unpack(result, 1, result.n)
	end
	local gui = make(
		"ScreenGui",
		{
			Name = "ZyonArcane",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 80,
		}
	)
	local parent_ok = false
	if type(gethui) == "function" then
		parent_ok = pcall(function()
			local container = gethui()
			assert(container, "gethui retornou nil")
			gui.Parent = container
		end)
	end
	if not parent_ok then
		parent_ok = pcall(function()
			gui.Parent = game:GetService("CoreGui")
		end)
	end
	if not parent_ok then
		gui.Parent = players.LocalPlayer:WaitForChild("PlayerGui")
	end
	ui.ScreenGui = gui
	local attach_help, hide_help, position_help =
		create_arcane_help(ui, make, label, button, round, border, gui, input, colors)
	local shell = make(
		"Frame",
		{
			Name = "Window",
			Size = UDim2.fromOffset(840, 580),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = colors.bg,
			BorderSizePixel = 0,
			Active = true,
			ZIndex = 10,
		},
		gui
	)
	round(shell, 12)
	border(shell)
	local scale = make("UIScale", { Scale = 1 }, shell)
	local function resize()
		local camera = workspace.CurrentCamera
		if camera then
			scale.Scale =
				math.clamp(math.min((camera.ViewportSize.X - 24) / 840, (camera.ViewportSize.Y - 32) / 580), 0.45, 1)
		end
	end
	resize()
	local titlebar = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64), Active = true }, shell)
	local brand = label(titlebar, "ZYON", 20)
	brand.Font = Enum.Font.BuilderSansBold
	brand.Position = UDim2.fromOffset(22, 12)
	brand.Size = UDim2.fromOffset(145, 25)
	local sub = label(titlebar, "ARCANE LINEAGE / 1.16", 13)
	sub.TextColor3 = colors.muted
	sub.Position = UDim2.fromOffset(23, 37)
	sub.Size = UDim2.fromOffset(170, 18)
	local current = label(titlebar, "Combate", 17)
	current.Position = UDim2.fromOffset(205, 22)
	current.Size = UDim2.fromOffset(235, 24)
	local search = make(
		"TextBox",
		{
			Size = UDim2.fromOffset(210, 32),
			Position = UDim2.new(1, -310, 0, 18),
			BackgroundColor3 = colors.panel,
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "Buscar nesta aba...",
			PlaceholderColor3 = colors.muted,
			TextColor3 = colors.text,
			TextSize = 13,
			Font = Enum.Font.BuilderSans,
			ClearTextOnFocus = false,
		},
		titlebar
	)
	round(search, 7)
	local discord_button = button(titlebar, "☁ Discord")
	discord_button.Name = "DiscordInvite"
	discord_button.Position = UDim2.fromOffset(444, 18)
	discord_button.Size = UDim2.fromOffset(78, 30)
	discord_button.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	discord_button.TextColor3 = Color3.new(1, 1, 1)
	discord_button.TextSize = 11
	discord_button.Font = Enum.Font.BuilderSansBold
	local discord_invite = "https://discord.gg/bfeukVAeca"
	local function try_open_url(opener)
		if type(opener) ~= "function" then
			return false
		end
		return pcall(opener, discord_invite)
	end
	ui:Connect(discord_button.Activated, function()
		if try_open_url(openurl) or try_open_url(open_url) or try_open_url(openUrl) then
			ui:Notify({ Title = "Discord", Content = "Abrindo o convite do servidor." })
		elseif type(setclipboard) == "function" and pcall(setclipboard, discord_invite) then
			ui:Notify({ Title = "Discord", Content = "Convite copiado. Cole no navegador ou no Discord." })
		else
			ui:Notify({ Title = "Discord", Content = discord_invite, Duration = 8 })
		end
	end)
	local minimize = button(titlebar, "—")
	minimize.Position = UDim2.new(1, -86, 0, 18)
	minimize.Size = UDim2.fromOffset(30, 30)
	local close = button(titlebar, "×")
	close.Position = UDim2.new(1, -47, 0, 18)
	close.Size = UDim2.fromOffset(30, 30)
	-- Independent, unscaled layer: the pointer always renders above the window and its popups.
	local cursor_gui = make(
		"ScreenGui",
		{
			Name = "ZyonCursorOverlay",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ScreenInsets = Enum.ScreenInsets.None,
			ClipToDeviceSafeArea = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 2147483647,
		},
		gui.Parent
	)
	local cursor = make(
		"Frame",
		{
			Name = "Pointer",
			Size = UDim2.fromOffset(21, 29),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = false,
			Visible = false,
			ZIndex = 1,
		},
		cursor_gui
	)
	ui.CursorGui = cursor_gui
	ui.CursorRoot = cursor
	-- Draw the arrow with native UI strips, so no cursor image download is required.
	local polygon = { { 0, 0 }, { 0, 22 }, { 5, 17 }, { 10, 28 }, { 15, 25 }, { 10, 16 }, { 20, 16 } }
	local function inside(x, y)
		local hit = false
		local previous = #polygon
		for index, point in ipairs(polygon) do
			local other = polygon[previous]
			if
				(point[2] > y) ~= (other[2] > y)
				and x < (other[1] - point[1]) * (y - point[2]) / (other[2] - point[2]) + point[1]
			then
				hit = not hit
			end
			previous = index
		end
		return hit
	end
	for y = 0, 28 do
		local left, right, inner_left, inner_right
		for x = 0, 20 do
			if inside(x + 0.5, y + 0.5) then
				left = left or x
				right = x
				if
					inside(x - 0.5, y + 0.5)
					and inside(x + 1.5, y + 0.5)
					and inside(x + 0.5, y - 0.5)
					and inside(x + 0.5, y + 1.5)
				then
					inner_left = inner_left or x
					inner_right = x
				end
			end
		end
		if left then
			make(
				"Frame",
				{
					BackgroundColor3 = Color3.fromRGB(20, 16, 32),
					BorderSizePixel = 0,
					Active = false,
					Position = UDim2.fromOffset(left, y),
					Size = UDim2.fromOffset(right - left + 1, 1),
					ZIndex = 1,
				},
				cursor
			)
		end
		if inner_left then
			make(
				"Frame",
				{
					BackgroundColor3 = Color3.fromRGB(248, 246, 255),
					BorderSizePixel = 0,
					Active = false,
					Position = UDim2.fromOffset(inner_left, y),
					Size = UDim2.fromOffset(inner_right - inner_left + 1, 1),
					ZIndex = 2,
				},
				cursor
			)
		end
	end
	local cursor_binding = "ZyonArcaneCursor"
	local cursor_active = false
	local free_mouse = false
	local cursor_stopped = false
	local dialogue_active = false
	local dialogue_root
	local dialogue_nodes = {}
	local dialogue_connections = {}
	local next_dialogue_check = 0
	ui.DialogueActive = false
	local owns_cursor = false
	local saved_behavior, saved_icon
	local function capture_cursor()
		if not owns_cursor then
			saved_behavior = input.MouseBehavior
			saved_icon = input.MouseIconEnabled
			owns_cursor = true
		end
	end
	local function release_cursor()
		if owns_cursor then
			input.MouseBehavior = saved_behavior
			input.MouseIconEnabled = saved_icon
			owns_cursor = false
		end
		cursor.Visible = false
	end
	local function update_cursor()
		if cursor_stopped or ui.Unloaded then return end
		if dialogue_active then
			capture_cursor()
			minimize.Modal = false
			input.MouseBehavior = Enum.MouseBehavior.Default
			input.MouseIconEnabled = true
			cursor.Visible = false
		elseif cursor_active and ui.Open then
			capture_cursor()
			input.MouseBehavior = Enum.MouseBehavior.Default
			input.MouseIconEnabled = false
			local location = input:GetMouseLocation()
			cursor.Position = UDim2.fromOffset(location.X, location.Y)
			cursor.Visible = input.MouseEnabled
		elseif free_mouse and not input:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			-- Explicit opt-in only: the game owns the mouse when this setting is off.
			capture_cursor()
			input.MouseBehavior = Enum.MouseBehavior.Default
			input.MouseIconEnabled = true
			cursor.Visible = false
		else
			release_cursor()
		end
	end
	local function refresh_cursor_binding()
		run:UnbindFromRenderStep(cursor_binding)
		if not cursor_stopped and (cursor_active or free_mouse or dialogue_active) then
			run:BindToRenderStep(cursor_binding, Enum.RenderPriority.Last.Value + 1, update_cursor)
		end
	end
	local function set_cursor_enabled(enabled)
		if cursor_stopped then return end
		cursor_active = enabled == true
		minimize.Modal = cursor_active
		if not cursor_active then release_cursor() end
		refresh_cursor_binding()
		update_cursor()
	end
	function ui:SetFreeMouse(enabled)
		free_mouse = enabled == true
		if not self.Open then release_cursor() end
		refresh_cursor_binding()
		update_cursor()
	end
	local function is_dialogue_visible(object)
		if not object or not object.Parent then return false end
		local node = object
		while node and node ~= players.LocalPlayer do
			if node:IsA("GuiObject") and not node.Visible then return false end
			if node:IsA("ScreenGui") and not node.Enabled then return false end
			node = node.Parent
		end
		return true
	end
	local function cache_dialogue(root)
		if root == dialogue_root then return end
		for _, connection in ipairs(dialogue_connections) do connection:Disconnect() end
		dialogue_connections, dialogue_nodes, dialogue_root = {}, {}, root
		if not root then return end
		local function add(object)
			if object:IsA("TextLabel") or object:IsA("GuiButton") then dialogue_nodes[object] = true end
		end
		for _, object in ipairs(root:GetDescendants()) do add(object) end
		table.insert(dialogue_connections, ui:Connect(root.DescendantAdded, add))
		table.insert(dialogue_connections, ui:Connect(root.DescendantRemoving, function(object) dialogue_nodes[object] = nil end))
	end
	local function poll_dialogue()
		local player_gui = players.LocalPlayer:FindFirstChild("PlayerGui")
		local root
		if player_gui then
			for _, name in ipairs({"NPCDialogue", "NPCDialog", "Dialogue", "DialogueGui"}) do
				local candidate = player_gui:FindFirstChild(name)
				if candidate and (candidate:IsA("ScreenGui") or candidate:IsA("GuiObject")) then root = candidate; break end
			end
		end
		cache_dialogue(root)
		local active = false
		if dialogue_root and is_dialogue_visible(dialogue_root) then
			for object in pairs(dialogue_nodes) do
				if is_dialogue_visible(object) and object.AbsoluteSize.X > 0 and object.AbsoluteSize.Y > 0 then
					if object:IsA("GuiButton") or object.Text:match("%S") then active = true; break end
				end
			end
		end
		ui.DialogueActive = active
		ui.ModuleStatus.Dialogue = active and ("aberto: " .. dialogue_root.Name .. "; mouse nativo livre") or "fechado"
		if active ~= dialogue_active then
			dialogue_active = active
			if active and ui.Open and ui.CreateWindow then ui:CreateWindow():SetOpen(false) end
			if not active then release_cursor() end
			refresh_cursor_binding()
			update_cursor()
		end
	end
	ui:Connect(run.Heartbeat, function()
		if cursor_stopped then return end
		local now = os.clock()
		if now < next_dialogue_check then return end
		next_dialogue_check = now + 0.1
		ui:Run("diálogo e cursor", poll_dialogue)
	end)
	local function shutdown_cursor()
		cursor_stopped = true
		cursor_active = false
		minimize.Modal = false
		for _, connection in ipairs(dialogue_connections) do connection:Disconnect() end
		dialogue_connections, dialogue_nodes = {}, {}
		run:UnbindFromRenderStep(cursor_binding)
		release_cursor()
	end
	set_cursor_enabled(true)
	local nav = make(
		"Frame",
		{ BackgroundTransparency = 1, Size = UDim2.new(0, 174, 1, -128), Position = UDim2.fromOffset(14, 76) },
		shell
	)
	make("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, nav)
	local footer = label(shell, "RightCtrl · abrir/fechar   |   Painel pronto; integração em análise", 10)
	footer.TextColor3 = colors.muted
	footer.Position = UDim2.new(0, 22, 1, -29)
	footer.Size = UDim2.new(1, -44, 0, 20)
	ui.Footer = footer
	local toast = label(gui, "", 13)
	toast.AnchorPoint = Vector2.new(0.5, 1)
	toast.Position = UDim2.new(0.5, 0, 1, -24)
	toast.Size = UDim2.fromOffset(590, 58)
	toast.BackgroundTransparency = 0
	toast.BackgroundColor3 = colors.raised
	toast.TextWrapped = true
	toast.TextTruncate = Enum.TextTruncate.None
	toast.TextXAlignment = Enum.TextXAlignment.Center
	toast.Visible = false
	toast.ZIndex = 40
	round(toast)
	local toast_id = 0
	function ui:Notify(info)
		if self.Unloaded then
			return
		end
		toast_id += 1
		local id = toast_id
		toast.Text = tostring(info.Title or "Zyon") .. "  ·  " .. tostring(info.Content or "")
		toast.Visible = true
		task.delay(info.Duration or 4, function()
			if not self.Unloaded and toast_id == id then
				toast.Visible = false
			end
		end)
	end
	local floating = button(gui, "Z")
	floating.Size = UDim2.fromOffset(42, 42)
	floating.Position = UDim2.new(0, 16, 0.5, -21)
	floating.ZIndex = 30
	border(floating)
	local tabs = {}
	local active_tab
	local active_drag
	local drag_begin
	local drag_position
	local moving_slider = nil
	ui:Connect(titlebar.InputBegan, function(event)
		if
			event.UserInputType == Enum.UserInputType.MouseButton1
			or event.UserInputType == Enum.UserInputType.Touch
		then
			active_drag = event
			drag_begin = event.Position
			drag_position = shell.Position
		end
	end)
	ui:Connect(input.InputChanged, function(event)
		if
			moving_slider and (event.UserInputType == Enum.UserInputType.MouseMovement or event == moving_slider.touch)
		then
			moving_slider.move(event.Position.X)
		elseif active_drag and (event.UserInputType == Enum.UserInputType.MouseMovement or event == active_drag) then
			local delta = event.Position - drag_begin
			local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
			local half = 420 * scale.Scale
			local x = math.clamp(
				viewport.X * drag_position.X.Scale + drag_position.X.Offset + delta.X,
				half,
				math.max(half, viewport.X - half)
			)
			local y = math.clamp(
				viewport.Y * drag_position.Y.Scale + drag_position.Y.Offset + delta.Y,
				290 * scale.Scale,
				math.max(290 * scale.Scale, viewport.Y - 290 * scale.Scale)
			)
			shell.Position = UDim2.fromOffset(x, y)
		end
	end)
	ui:Connect(input.InputEnded, function(event)
		if
			event.UserInputType == Enum.UserInputType.MouseButton1
			or event.UserInputType == Enum.UserInputType.Touch
		then
			active_drag = nil
			moving_slider = nil
		end
	end)
	local window = {}
	function window:SetOpen(value)
		if value == true and ui.DialogueActive then
			ui:Notify({Content="Finalize o diálogo do NPC para abrir o hub."})
			return
		end
		ui.Open = value == true
		shell.Visible = ui.Open
		if not ui.Open then
			hide_help()
		end
		set_cursor_enabled(ui.Open)
	end
	function window:Toggle()
		self:SetOpen(not ui.Open)
	end
	ui:Connect(minimize.Activated, function()
		window:SetOpen(false)
	end)
	ui:Connect(floating.Activated, function()
		window:Toggle()
	end)
	ui:Connect(close.Activated, function()
		ui:Unload()
	end)
	ui:Connect(input.InputBegan, function(event)
		-- Dedicated HUD keys remain usable when a modal or textbox consumes the input.
		if ui.Unloaded then
			return
		end
		if event.KeyCode == Enum.KeyCode.RightControl or event.KeyCode == Enum.KeyCode.Insert then
			window:Toggle()
		end
	end)
	local translations = {
		["Drops"] = "Bosses e drops",
		["Items"] = "Coleta",
		["Soul"] = "Essência",
		["Travel"] = "Viagens",
		["Character"] = "Personagem",
		["Settings"] = "Configurações",
		["Combat"] = "Combate",
		["Quests"] = "Quests e roteiro",
		["School & Clubs"] = "Escola e clubes",
		["World & Loot"] = "Itens e mundo",
		["Teleports"] = "Teletransportes",
		["Movement"] = "Movimento",
		["Visuals"] = "Visuais",
		["Codes & Config"] = "Configurações",
		["Defense & Parry"] = "Defesa e parry",
		["Offense & Finisher"] = "Ataques e finalização",
		["Class Exams & Quizzes"] = "Provas e perguntas",
		["Club QTEs & Music"] = "Clubes e música",
		["Class Mini-Games"] = "Minigames",
		["Pickup Aura & Spawns"] = "Coleta e avisos",
		["Item Teleport"] = "Ir até item",
		["School & Locations"] = "Locais da escola",
		["Players Teleport"] = "Jogadores",
		["Speed & Mobility"] = "Mobilidade",
		["Flight"] = "Voo",
		["Player ESP"] = "ESP de jogadores",
		["World & Environment"] = "Ambiente",
		["Promo Codes"] = "Códigos",
		["Presets & Session"] = "Perfis e sessão",
	}
	function ui:CreateWindow()
		return window
	end
	local function apply_filter()
		hide_help()
		local query = search.Text:lower()
		for _, tab in ipairs(tabs) do
			for _, group in ipairs(tab.groups) do
				local found = false
				for _, row in ipairs(group.rows) do
					row.frame.Visible = query == "" or row.search:find(query, 1, true) ~= nil
					found = found or row.frame.Visible
				end
				group.frame.Visible = found
			end
		end
	end
	ui:Connect(search:GetPropertyChangedSignal("Text"), apply_filter)
	function window:AddTab(name)
		local tab = { groups = {} }
		local tab_button = button(nav, translations[name] or name)
		tab_button.Size = UDim2.new(1, 0, 0, 39)
		tab_button.LayoutOrder = #tabs
		tab_button.TextXAlignment = Enum.TextXAlignment.Left
		make("UIPadding", { PaddingLeft = UDim.new(0, 14) }, tab_button)
		local page = make(
			"ScrollingFrame",
			{
				Size = UDim2.new(1, -214, 1, -112),
				Position = UDim2.fromOffset(200, 72),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = colors.accent,
				Visible = false,
			},
			shell
		)
		local columns = {}
		for index, side in ipairs({ "Left", "Right" }) do
			local col = make(
				"Frame",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, -9, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Position = UDim2.new((index - 1) * 0.5, index == 2 and 5 or 0, 0, 0),
				},
				page
			)
			make("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, col)
			make("UIPadding", { PaddingBottom = UDim.new(0, 14) }, col)
			columns[side] = col
		end
		tab.page = page
		tab.button = tab_button
		table.insert(tabs, tab)
		local function select()
			hide_help()
			for _, other in ipairs(tabs) do
				other.page.Visible = other == tab
				other.button.BackgroundColor3 = other == tab and colors.raised or colors.bg
				other.button.TextColor3 = other == tab and colors.accent or colors.muted
			end
			active_tab = tab
			current.Text = translations[name] or name
			search.Text = ""
		end
		ui:Connect(tab_button.Activated, select)
		if not active_tab then
			select()
		end
		function tab:AddGroup(title, side)
			local group = { rows = {} }
			local card = make(
				"Frame",
				{
					BackgroundColor3 = colors.panel,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = #tab.groups,
				},
				columns[side or "Left"]
			)
			round(card, 9)
			border(card)
			make(
				"UIPadding",
				{
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
					PaddingTop = UDim.new(0, 12),
					PaddingBottom = UDim.new(0, 12),
				},
				card
			)
			make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, card)
			local heading = label(card, translations[title] or title, 14)
			heading.Font = Enum.Font.BuilderSansBold
			heading.LayoutOrder = -1
			group.frame = card
			table.insert(tab.groups, group)
			local function row(text, height)
				local frame = make(
					"Frame",
					{ BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height), LayoutOrder = #group.rows },
					card
				)
				table.insert(group.rows, { frame = frame, search = (text .. " " .. title):lower() })
				attach_help(frame, text)
				local content = make(
					"Frame",
					{ Name = "ControlContent", BackgroundTransparency = 1, Size = UDim2.new(1, -25, 1, 0) },
					frame
				)
				return content
			end
			local function register(key, options, control)
				control.Callback = options.Callback
				control.Key = key
				if key then
					ui.Options[key] = control
				end
				return control
			end
			function group:AddToggle(key, options)
				local frame = row(options.Text or key, 44)
				local caption = label(frame, options.Text or key, 13)
				caption.Size = UDim2.new(1, -48, 1, 0)
				caption.TextWrapped = true
				caption.TextTruncate = Enum.TextTruncate.None
				local switch = button(frame, "")
				switch.Size = UDim2.fromOffset(34, 19)
				switch.Position = UDim2.new(1, -34, 0.5, -9)
				local dot = make(
					"Frame",
					{ Size = UDim2.fromOffset(13, 13), BackgroundColor3 = colors.text, BorderSizePixel = 0 },
					switch
				)
				round(dot, 20)
				local control = register(key, options, { Kind = "toggle" })
				function control:SetValue(value, silent)
					self.Value = value == true
					switch.BackgroundColor3 = self.Value and colors.accent or colors.line
					dot.Position = UDim2.fromOffset(self.Value and 18 or 3, 3)
					if not silent and self.Callback then
						ui:Run(key or "toggle", self.Callback, self.Value)
					end
				end
				ui:Connect(switch.Activated, function()
					control:SetValue(not control.Value)
				end)
				control:SetValue(options.Default, true)
				return control
			end
			function group:AddSlider(key, options)
				local frame = row(options.Text or key, 76)
				local caption = label(frame, options.Text or key, 13)
				caption.Size = UDim2.new(1, 0, 0, 34)
				caption.TextWrapped = true
				caption.TextTruncate = Enum.TextTruncate.None
				local value = make(
					"TextBox",
					{
						BackgroundColor3 = colors.raised,
						BorderSizePixel = 0,
						Size = UDim2.fromOffset(77, 25),
						Position = UDim2.new(1, -77, 0, 42),
						TextColor3 = colors.text,
						TextSize = 13,
						Font = Enum.Font.BuilderSansMedium,
						ClearTextOnFocus = false,
					},
					frame
				)
				round(value, 4)
				local track = button(frame, "")
				track.Size = UDim2.new(1, -90, 0, 18)
				track.Position = UDim2.fromOffset(0, 46)
				track.BackgroundTransparency = 1
				local rail = make(
					"Frame",
					{
						BackgroundColor3 = colors.line,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 3),
						Position = UDim2.fromOffset(0, 7),
					},
					track
				)
				round(rail, 3)
				local fill = make(
					"Frame",
					{ BackgroundColor3 = colors.accent, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) },
					rail
				)
				round(fill, 3)
				local dot = make(
					"Frame",
					{
						BackgroundColor3 = colors.text,
						BorderSizePixel = 0,
						Size = UDim2.fromOffset(10, 10),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0, 0.5),
					},
					rail
				)
				round(dot, 10)
				local control = register(key, options, { Kind = "slider", Min = options.Min, Max = options.Max })
				function control:SetValue(v, silent)
					v = tonumber(v) or options.Default
					if v ~= v or math.abs(v) == math.huge then
						v = options.Default
					end
					local power = 10 ^ (options.Rounding or 0)
					self.Value = math.clamp(math.floor(v * power + 0.5) / power, self.Min, self.Max)
					local alpha = (self.Value - self.Min) / (self.Max - self.Min)
					fill.Size = UDim2.fromScale(alpha, 1)
					dot.Position = UDim2.fromScale(alpha, 0.5)
					value.Text = tostring(self.Value) .. (options.Suffix or "")
					if not silent and self.Callback then
						ui:Run(key, self.Callback, self.Value)
					end
				end
				local function move(x)
					control:SetValue(
						options.Min
							+ math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
								* (options.Max - options.Min)
					)
				end
				ui:Connect(track.InputBegan, function(event)
					if
						event.UserInputType == Enum.UserInputType.MouseButton1
						or event.UserInputType == Enum.UserInputType.Touch
					then
						moving_slider = { move = move, touch = event }
						move(event.Position.X)
					end
				end)
				ui:Connect(value.FocusLost, function()
					control:SetValue(value.Text:match("[-+]?%d*%.?%d+"))
				end)
				control:SetValue(options.Default, true)
				return control
			end
			function group:AddDropdown(key, options)
				local frame = row(options.Text or key, 61)
				local caption = label(frame, options.Text or key, 13)
				local choose = button(frame, "")
				choose.Position = UDim2.fromOffset(0, 26)
				choose.Size = UDim2.new(1, 0, 0, 32)
				choose.TextSize = 13
				choose.TextTruncate = Enum.TextTruncate.AtEnd
				local control = register(key, options, { Kind = "dropdown", Values = options.Values or {} })
				local popup
				function control:SetValue(value, silent)
					if options.Multi then
						local selected = {}
						if type(value) == "table" then
							for _, name in ipairs(value) do
								if
									type(name) == "string"
									and table.find(self.Values, name)
									and not table.find(selected, name)
								then
									table.insert(selected, name)
								end
							end
						end
						self.Value = selected
						choose.Text = #selected == 0 and "Nenhum selecionado  ▾"
							or tostring(#selected) .. " itens selecionados  ▾"
						for name, obj in pairs(self.MultiButtons or {}) do
							obj.Text = (table.find(selected, name) and "[✓] " or "[ ] ") .. name
						end
						if not silent and self.Callback then
							ui:Run(key or "dropdown", self.Callback, selected)
						end
						return
					end
					if not table.find(self.Values, value) then
						value = self.Values[1]
					end
					self.Value = value
					choose.Text = tostring(value or "Nenhum") .. "  ▾"
					if not silent and self.Callback then
						ui:Run(key or "dropdown", self.Callback, value)
					end
				end
				function control:SetValues(values)
					self.Values = values or {}
					self:SetValue(self.Value)
					if popup then
						popup:Destroy()
						popup = nil
					end
				end
				ui:Connect(choose.Activated, function()
					if popup then
						popup:Destroy()
						popup = nil
						return
					end
					popup = make(
						"Frame",
						{
							Size = UDim2.fromOffset(350, 330),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							BackgroundColor3 = colors.panel,
							BorderSizePixel = 0,
							ZIndex = 20,
						},
						shell
					)
					round(popup)
					border(popup)
					local dismiss = button(popup, "Fechar seleção")
					dismiss.Position = UDim2.fromOffset(10, 10)
					dismiss.Size = UDim2.new(1, -20, 0, 30)
					dismiss.ZIndex = 21
					ui:Connect(dismiss.Activated, function()
						if popup then
							popup:Destroy()
							popup = nil
						end
					end)
					local list = make(
						"ScrollingFrame",
						{
							Position = UDim2.fromOffset(10, 50),
							Size = UDim2.new(1, -20, 1, -60),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							CanvasSize = UDim2.new(),
							ScrollBarThickness = 3,
							ZIndex = 21,
						},
						popup
					)
					make("UIListLayout", { Padding = UDim.new(0, 5) }, list)
					control.MultiButtons = {}
					for _, value in ipairs(control.Values) do
						local option = button(list, tostring(value))
						option.Size = UDim2.new(1, -8, 0, 30)
						option.ZIndex = 22
						if options.Multi then
							control.MultiButtons[value] = option
							option.Text = (table.find(control.Value, value) and "[✓] " or "[ ] ") .. tostring(value)
						end
						ui:Connect(option.Activated, function()
							if options.Multi then
								local selected = table.clone(control.Value)
								local index = table.find(selected, value)
								if index then
									table.remove(selected, index)
								else
									table.insert(selected, value)
								end
								control:SetValue(selected)
							else
								control:SetValue(value)
								if popup then
									popup:Destroy()
									popup = nil
								end
							end
						end)
					end
				end)
				control:SetValue(options.Default, true)
				return control
			end
			function group:AddLabel(text, options)
				local frame = row(text, (options and options.Height) or 80)
				local caption = label(frame, text, 13)
				caption.Size = UDim2.fromScale(1, 1)
				caption.TextWrapped = true
				caption.TextTruncate = Enum.TextTruncate.None
				caption.TextYAlignment = Enum.TextYAlignment.Top
				return {
					SetText = function(_, value)
						caption.Text = tostring(value)
					end,
				}
			end
			function group:AddTextbox(key, options)
				local frame = row(options.Text or key, 65)
				local caption = label(frame, options.Text or key, 13)
				caption.Size = UDim2.new(1, 0, 0, 28)
				caption.TextWrapped = true
				local box = make(
					"TextBox",
					{
						Position = UDim2.fromOffset(0, 31),
						Size = UDim2.new(1, 0, 0, 30),
						BackgroundColor3 = colors.raised,
						BorderSizePixel = 0,
						ClearTextOnFocus = false,
						TextColor3 = colors.text,
						PlaceholderText = "Opcional",
						TextSize = 13,
						Font = Enum.Font.BuilderSansMedium,
					},
					frame
				)
				round(box, 5)
				local control = register(key, options, { Kind = "textbox" })
				function control:SetValue(value, silent)
					self.Value = tostring(value or ""):gsub("[%c]", " "):sub(1, 180)
					box.Text = self.Value
					if not silent and self.Callback then
						ui:Run(key, self.Callback, self.Value)
					end
				end
				ui:Connect(box.FocusLost, function()
					control:SetValue(box.Text)
				end)
				control:SetValue(options.Default, true)
				return control
			end
			function group:AddButton(text, options)
				local frame = row(text, 44)
				local obj = button(frame, text)
				obj.TextSize = 13
				obj.Size = UDim2.fromScale(1, 1)
				obj.TextWrapped = true
				if options.Danger then
					obj.TextColor3 = colors.danger
				end
				local busy = false
				ui:Connect(obj.Activated, function()
					if busy then
						return
					end
					busy = true
					ui:Run(text, options.Callback or function() end)
					busy = false
					if ui.Sync then
						ui.Sync()
					end
				end)
				return obj
			end
			return group
		end
		return tab
	end
	function ui:Diagnostics()
		local lines = {
			"ZYON ARCANE / 1.16",
			"PlaceId: " .. tostring(game.PlaceId),
			"GameId: " .. tostring(game.GameId),
			"Validação em jogo: pendente de teste local",
		}
		for _, name in ipairs({ "getgc", "getcallbackvalue", "fireclickdetector", "writefile", "readfile" }) do
			local available = self.Capabilities and self.Capabilities[name]
			table.insert(lines, name .. ": " .. (available and "disponível" or "indisponível"))
		end
		local names = {}
		for name in pairs(self.ModuleStatus) do
			table.insert(names, name)
		end
		table.sort(names)
		for _, name in ipairs(names) do
			table.insert(lines, "Módulo " .. name .. ": " .. self.ModuleStatus[name])
		end
		for area, entry in pairs(self.Errors) do
			table.insert(lines, "Erro " .. area .. " (" .. entry.count .. "): " .. entry.message)
		end
		local report = table.concat(lines, "\n")
		if type(setclipboard) == "function" then
			pcall(setclipboard, report)
		end
		if type(writefile) == "function" then
			pcall(writefile, "ZyonArcane-diagnostico.txt", report)
		end
		print(report)
		self:Notify({
			Title = "Diagnóstico",
			Content = "Relatório enviado ao console e, quando disponível, à área de transferência/arquivo.",
		})
		return report
	end
	function ui:Unload()
		if self.Unloaded then
			return
		end
		hide_help()
		shutdown_cursor()
		if self.OnUnload then
			local ok, err = pcall(self.OnUnload)
			if not ok then
				warn("[Zyon unload] " .. tostring(err))
			end
		end
		self.Unloaded = true
		for _, conn in ipairs(self.Connections) do
			conn:Disconnect()
		end
		cursor_gui:Destroy()
		gui:Destroy()
	end
	local frame_count = 0
	local elapsed = 0
	ui:Connect(run.RenderStepped, function(dt)
		position_help()
		frame_count += 1
		elapsed += dt
		if elapsed >= 1 then
			resize()
			local errors = 0
			for _ in pairs(ui.Errors) do
				errors += 1
			end
			footer.Text = string.format(
				"RightCtrl · painel   /   %d FPS   /   %s   /   %d alertas",
				math.floor(frame_count / elapsed),
				ui.Status or "carregando módulos",
				errors
			)
			elapsed = 0
			frame_count = 0
		end
	end)
	return ui
end

local destinations = {
	["Cities"] = {
		["Caldera City"] = Vector3["new"](5377.2, 657.9, -4443.4),
		["The Old Ruins"] = Vector3["new"](2939.0, 626.7, -4025.5),
		["Westwood Heart"] = Vector3["new"](8303.8, 600.4, -4379.0),
		["Tundra Gate"] = Vector3["new"](5021.7, 747.8, -6384.4),
		["Deep Forest"] = Vector3["new"](4253.1, 653.8, -3369.2),
		["Desert Outskirts"] = Vector3["new"](2079.6, 382.7, -2903.1),
	},
	["Bosses"] = {
		["Yar'thul (Door Entrance)"] = Vector3["new"](40.5, 581.6, -4113.5),
		["Seraphon (Sky Entrance)"] = Vector3["new"](710.5, 3449.1, -5678.1),
		["Thorian (Rotten Arena)"] = Vector3["new"](8330.7, 615.5, -694.5),
	},
	["Trainers"] = {
		["Leoran (Swordsman / Warrior)"] = Vector3["new"](4995.5, 754.4, -6194.1),
		["Thorin (Slayer)"] = Vector3["new"](4253.1, 653.8, -3369.2),
		["Kayrein (Berserker)"] = Vector3["new"](11342.1, 1500.1, -3656.7),
		["Dernon (Paladin)"] = Vector3["new"](2813.0, 615.7, -3866.6),
		["Aberon (Rogue / Thief)"] = Vector3["new"](2800.0, 610.7, -4018.2),
		["Orkin (Ranger)"] = Vector3["new"](8546.3, 822.7, -5544.1),
		["Relan (Armored Lancer)"] = Vector3["new"](5322.2, 749.4, -6324.2),
		["Fernain (Spear Master)"] = Vector3["new"](2296.1, 663.3, -4392.7),
		["Gren (Mage / Elementalist)"] = Vector3["new"](5170.9, 660.5, -4996.0),
		["June (Wizard)"] = Vector3["new"](4903.8, 624.7, -4423.1),
		["Geron (Brawler)"] = Vector3["new"](4448.3, 652.1, -3359.3),
		["Doran (Martial Artist)"] = Vector3["new"](5627.8, 703.8, -4336.9),
		["Ardentis (Saint / Cleric)"] = Vector3["new"](474.5, 581.5, -4816.9),
		["Prelate Fyran (Order / Saint)"] = Vector3["new"](8459.8, 822.4, -5885.1),
		["DeadReaper (Necromancer)"] = Vector3["new"](2623.8, 556.4, -4660.0),
		["Kether (Darkwraith)"] = Vector3["new"](7821.2, 1279.8, 8480.1),
	},
	["Merchants"] = {
		["Traveling Pasmark (Buyables)"] = Vector3["new"](3502.2, 629.2, -4000.5),
		["Merchant 1 (Caldera City)"] = Vector3["new"](5132.9, 658, -4124.2),
		["Merchant (Westwood Heart)"] = Vector3["new"](8473.8, 823.6, -5906.5),
		["Torve Schneider (Tundra Gate)"] = Vector3["new"](5021.7, 747.8, -6384.4),
		["Aldis Scholz (Tundra Gate)"] = Vector3["new"](5232.2, 810.7, -6583.7),
		["Corra Hartmann (Tundra Gate)"] = Vector3["new"](5318.2, 812.1, -6627.5),
		["Ysel Bauer (Tundra Gate)"] = Vector3["new"](5317.2, 810.9, -6609.1),
	},
	["Services"] = {
		["Identifier (Caldera)"] = Vector3["new"](5043.8, 670.0, -4232.2),
		["Enchanter (Caldera)"] = Vector3["new"](5045.7, 657.5, -4234.2),
		["Barber (Caldera)"] = Vector3["new"](5122.7, 657.9, -4468.1),
		["Therapist (Caldera)"] = Vector3["new"](5224.5, 657.8, -4339.8),
		["Banker (Caldera)"] = Vector3["new"](5184.7, 657.7, -4266.2),
		["Banker 1 (Westwood)"] = Vector3["new"](8470.3, 823.6, -5824.3),
		["Doctor (Westwood)"] = Vector3["new"](8079.1, 822.4, -5478.8),
		["Doctor 1 (Old Ruins)"] = Vector3["new"](2790.2, 615.7, -3837.2),
		["Doctor 2 (Caldera)"] = Vector3["new"](5035.6, 658.1, -4407.9),
		["Doctor 3 (Westwood)"] = Vector3["new"](8331.4, 822.4, -5521.0),
		["Doctor 4 (Deep Mines)"] = Vector3["new"](2084.0, 382.7, -2946.7),
		["Field Doctor"] = Vector3["new"](215.2, 578.7, -4055.2),
		["Blacksmith 1 (Caldera)"] = Vector3["new"](4921.8, 657.9, -4162.3),
		["Blacksmith (Westwood)"] = Vector3["new"](8465.8, 821.8, -5589.8),
		["Blacksmith 2 (Mines)"] = Vector3["new"](2079.6, 382.7, -2903.1),
		["Apothecarian (Caldera)"] = Vector3["new"](5131.5, 657.8, -4355.9),
		["Apothecarian 1 (Westwood)"] = Vector3["new"](8388.3, 822.9, -5904.8),
		["Clerk (Old Ruins Tavern)"] = Vector3["new"](2786.1, 632.7, -3832.1),
		["Clerk 1 (Westwood Tavern)"] = Vector3["new"](8332.3, 822.3, -5577.4),
		["Clerk 2 (Caldera Tavern)"] = Vector3["new"](5124.1, 657.7, -4307.1),
	},
	["WorldNPCs"] = {
		["The Soulmaster"] = Vector3["new"](-44.9, 574.8, -5467.4),
		["Adelma"] = Vector3["new"](-425.4, 2712.7, -3388.1),
		["Mael"] = Vector3["new"](414.1, 2858.0, -3020.1),
		["Mael 1"] = Vector3["new"](2070.9, 383.3, -2937.8),
		["Nevithas"] = Vector3["new"](71.9, 2765.7, -3266.4),
		["Thanasius"] = Vector3["new"](7680.4, 576.6, -2656.3),
		["Thanasius Mirror"] = Vector3["new"](11007.1, 1587.0, -3700.9),
		["Momma Darkbeast"] = Vector3["new"](8122.6, 581.8, -2138.1),
		["Bone Man"] = Vector3["new"](1397.0, 610.3, -4097.6),
		["Cantia"] = Vector3["new"](2845.8, 624.1, -3222.9),
		["Luther"] = Vector3["new"](3496.5, 632.8, -3983.3),
		["Inette"] = Vector3["new"](6699.0, 568.2, -3461.3),
		["Lorra"] = Vector3["new"](5732.0, 656.5, -3692.4),
		["Ophelia"] = Vector3["new"](4661.7, 651.7, -5236.5),
		["Thuriaz"] = Vector3["new"](2151.2, 519.8, -3394.1),
		["Landrum"] = Vector3["new"](2473.2, 624.7, -3540.3),
		["Tivek"] = Vector3["new"](4473.3, 650.1, -5730.3),
		["Lagolt"] = Vector3["new"](4651.7, 718.7, -5574.9),
		["Arandor"] = Vector3["new"](5840.1, 727.0, -4790.1),
		["Tendra"] = Vector3["new"](-66.3, 574.3, -5503.9),
		["PurgNPC"] = Vector3["new"](-2.8, 580.0, -5499.6),
		["LightPlaceGate"] = Vector3["new"](-889.6, 2668.1, -3022.6),
		["DarkPlaceGate"] = Vector3["new"](7855.0, 1287.9, 7931.0),
		["Cieran"] = Vector3["new"](8421.9, 822.5, -5864.5),
		["Atalar"] = Vector3["new"](5046.6, 658, -4349.6),
		["H.T Louie"] = Vector3["new"](5072.4, 659.0, -4206.0),
		["Pistachio"] = Vector3["new"](4896.3, 656.5, -4153.3),
		["Tarmon"] = Vector3["new"](5141.5, 657.7, -4132.6),
		["Joe"] = Vector3["new"](5284.1, 658, -4329.6),
		["Asskerlot"] = Vector3["new"](5121.1, 658.2, -4274.3),
		["Boots"] = Vector3["new"](4945.6, 658.6, -4121.4),
		["Ysa"] = Vector3["new"](5100.6, 658.2, -4072.0),
		["Vanio"] = Vector3["new"](7572.0, 593.2, -2674.0),
		["Selia"] = Vector3["new"](8116.2, 822.5, -5456.4),
		["Orin"] = Vector3["new"](8043.9, 822.6, -5599.3),
		["Diiz"] = Vector3["new"](8066.4, 831.2, -5648.9),
		["Tae'el"] = Vector3["new"](8407.1, 830.8, -5647.7),
		["El'heith"] = Vector3["new"](10883.0, 1573.4, -3489.5),
		["Ulys"] = Vector3["new"](10847.3, 1589.0, -4091.8),
		["Ryzar Infelio"] = Vector3["new"](2134.9, 382.7, -2922.0),
		["Staarun"] = Vector3["new"](778.3, 233.0, 2053.5),
		["Aderyn"] = Vector3["new"](800.3, 233.0, 2053.5),
		["Moehe Words"] = Vector3["new"](5451.4, 659.8, -4309.0),
	},
}

-- Protocol adapters based on the supplied reference; computations use the game's seeded rules.
local function create_qte_solver(load_rule, pause)
	local solver = {}
	local function checked(value, label)
		assert(type(value) == "number" and value == value and math.abs(value) < 1e7, label .. " inválido")
		return value
	end
	local function normalized(name)
		name = tostring(name):gsub("^New", ""):gsub("QTE$", "")
		if name == "MochiiMagic" then
			name = "Magic"
		end
		return name
	end
	function solver:Build(raw_name, data)
		local name = normalized(raw_name)
		if type(data) ~= "table" then
			return nil, "dados do QTE não são uma tabela"
		end
		local rule = load_rule(name)
		if type(rule) ~= "table" or type(rule.Layout) ~= "function" then
			return nil, "regra indisponível: " .. name
		end
		local layout = data.Layout or rule.Layout(data.Seed, data)
		if type(layout) ~= "table" then
			return nil, "layout indisponível: " .. name
		end
		local inputs = {}
		local elapsed = 0
		local nonce = data.Nonce or data.nonce or data.Key or data.key
		local legacy = table.pack(true)
		if name == "Dodge" then
			if type(rule.Result) ~= "function" then
				return nil, "Dodge.Result indisponível"
			end
			local sweep = checked(layout.Sweep, "Sweep")
			if sweep <= 0 or sweep > 30 then
				return nil, "Sweep fora do limite"
			end
			local sample_count = math.clamp(math.ceil(sweep / 0.005), 400, 6000)
			local step = sweep / sample_count
			local best_first, best_last
			local run_first, run_last
			local function save_run()
				if run_first and (not best_first or run_last - run_first > best_last - best_first) then
					best_first, best_last = run_first, run_last
				end
				run_first, run_last = nil, nil
			end
			for i = 1, sample_count do
				local at = step * i
				local result = rule.Result(layout, at)
				if type(result) == "table" and result[1] == true and result[2] == true then
					run_first = run_first or at
					run_last = at
				else
					save_run()
				end
			end
			save_run()
			if not best_first then
				return nil, "nenhuma janela de dodge encontrada"
			end
			inputs.Stop = (best_first + best_last) / 2
			elapsed = 0.84 + inputs.Stop
			legacy = table.pack(true, true)
		elseif name == "Sword" then
			if type(layout.Durations) ~= "table" or #layout.Durations > 100 then
				return nil, "Durations inválido"
			end
			local position = math.clamp(checked(layout.WindowPosition, "WindowPosition"), 0, 0.95)
			local fraction = 1 - math.sqrt(math.max(0, 1 - (position - 0.01) / 0.95))
			inputs.Stops = {}
			for _, duration in ipairs(layout.Durations) do
				duration = checked(duration, "Duration")
				table.insert(inputs.Stops, math.max(0, fraction * duration))
				elapsed += duration * 0.45
			end
			elapsed += 0.3
		elseif name == "Fist" then
			local amount = math.clamp(math.floor(checked(layout.Amount, "Amount")), 1, 100)
			if type(layout.Arrows) ~= "table" then
				return nil, "Arrows indisponível"
			end
			inputs.Presses = {}
			for index = 1, amount do
				if not layout.Arrows[index] then
					return nil, "direção ausente"
				end
				table.insert(inputs.Presses, { Dir = layout.Arrows[index], At = 0.35 + index * 0.16 })
			end
			elapsed = 0.9 + amount * 0.18
		elseif name == "Magic" then
			local amount = math.clamp(math.floor(checked(layout.Amount, "Amount")), 1, 100)
			inputs.Slots = {}
			for index = 1, amount do
				table.insert(inputs.Slots, { Bag = index, Slot = index, At = 0.4 + index * 0.2 })
			end
			elapsed = 0.9 + amount * 0.22
		elseif name == "Axe" then
			local duration = checked(layout.Duration, "Duration")
			local target = checked(layout.Threshold, "Threshold") + checked(layout.ThresholdSize, "ThresholdSize") * 0.5
			local fill = checked(layout.FillPerPress, "FillPerPress")
			local decay = checked(layout.DecayRate, "DecayRate")
			if duration <= 0 or duration > 40 or fill <= 0 then
				return nil, "parâmetros de Axe fora do limite"
			end
			inputs.Presses = {}
			local level = 0
			for index = 1, math.ceil(duration / 0.05) do
				local at = index * 0.05
				level = math.max(0, level - decay * 0.05)
				if level + fill <= target or level < layout.Threshold then
					level = math.min(1, level + fill)
					table.insert(inputs.Presses, at)
				end
			end
			elapsed = duration + 0.45
		elseif name == "Dagger" then
			if type(layout.Rings) ~= "table" or #layout.Rings > 100 then
				return nil, "Rings inválido"
			end
			local period = checked(layout.RotationPeriod or 1.25, "RotationPeriod")
			if period <= 0 then
				return nil, "RotationPeriod zero"
			end
			inputs.Presses = {}
			for index, ring in ipairs(layout.Rings) do
				local point = ring.Weakpoints and ring.Weakpoints[1]
				if not point then
					return nil, "weakpoint ausente"
				end
				local at = (((360 - checked(point.Angle, "Angle")) * checked(ring.Direction, "Direction")) % 360)
					/ (360 / period)
				table.insert(inputs.Presses, { Ring = index, T = at })
				elapsed = math.max(elapsed, at + 0.5)
			end
			elapsed = math.max(elapsed, 1.4)
		elseif name == "Spear" then
			local amount = math.clamp(math.floor(checked(layout.Count, "Count")), 1, 100)
			inputs.Resolved = {}
			for index = 1, amount do
				local spawn = layout.Spawns and layout.Spawns[index]
				if type(spawn) ~= "number" then
					return nil, "spawn ausente"
				end
				table.insert(inputs.Resolved, { Index = index, Hit = true, At = spawn + 0.25, Start = spawn + 0.05 })
				elapsed = math.max(elapsed, spawn + 0.6)
			end
			elapsed = math.max(elapsed, tonumber(layout.Deadline) or 0)
		elseif name == "Thorian" then
			if type(layout.Eyes) ~= "table" then
				return nil, "Eyes ausente"
			end
			local blessed, cursed = {}, {}
			for index, eye in ipairs(layout.Eyes) do
				if eye.Kind == "Blessed" then
					table.insert(blessed, index)
				elseif eye.Kind == "Cursed" then
					table.insert(cursed, index)
				end
			end
			local amount = math.min(#blessed, #cursed, tonumber(layout.ScoreTarget) or 10)
			if amount <= 0 then
				return nil, "nenhum par válido de Thorian"
			end
			inputs.Events = {}
			for index = 1, amount do
				local at = 0.5 + index * 0.35
				table.insert(
					inputs.Events,
					{ Type = "Cure", Blessed = blessed[index], Cursed = cursed[index], Grab = at - 0.15, At = at }
				)
			end
			elapsed = 1 + amount * 0.35
		elseif name == "Hammer" or name == "Yarthul" then
			if type(rule.NewSim) ~= "function" then
				return nil, "NewSim indisponível"
			end
			local sim = rule.NewSim(layout)
			local limit = tonumber(name == "Hammer" and layout.MaxStep or layout.EndStep)
			if not limit or limit < 1 or limit > 20000 then
				return nil, "limite de simulação inválido"
			end
			inputs.Events = {}
			local steps = 0
			while not sim.Finished and sim.Step < limit do
				steps += 1
				if steps > 20000 then
					return nil, "simulação não convergiu"
				end
				local before = sim.Step
				if name == "Hammer" then
					local zone = sim.Zones and sim.Zones[sim.Current]
					if not zone then
						return nil, "zona do Hammer ausente"
					end
					local should_hold = sim.Blue < zone.Position + zone.Width * 0.5
					if should_hold ~= sim.Holding then
						local code = should_hold and "H" or "h"
						table.insert(inputs.Events, { Step = sim.Step + 1, Code = code })
						sim:Apply(code)
					end
				else
					table.insert(inputs.Events, { Step = sim.Step + 1, Code = "L" })
					sim:Apply("L")
				end
				sim:Advance()
				if sim.Step <= before then
					return nil, "simulação não avançou"
				end
				if steps % 200 == 0 then
					pause(0)
				end
			end
			elapsed = name == "Hammer" and limit * (tonumber(rule.STEP) or 0.016) * 0.85 + 0.4
				or (tonumber(layout.Duration) or limit * (tonumber(rule.STEP) or 0.016)) + 0.45
			if name == "Yarthul" then
				legacy = table.pack(true, 0)
			end
		else
			return nil, "tipo sem solver implementado: " .. name
		end
		elapsed = math.clamp(elapsed, 0.3, 180)
		return { name = name, duration = elapsed, returns = nonce and table.pack({ Nonce = nonce, Inputs = inputs })
			or legacy }
	end
	return solver
end

-- Read the live QTE geometry; let the game's own Space handler submit the result.
local function create_visual_dodge(app, flags, player)
	local run = game:GetService("RunService")
	local input = game:GetService("UserInputService")
	local manager = { stopped = false, state = nil, next_scan = 0, held = false,
		texts = {}, screens = {}, owners = {}, cache_connections = {}, generation = 0 }
	local vim
	pcall(function() vim = game:GetService("VirtualInputManager") end)
	local function visible(object)
		if not object or not object.Parent then return false end
		local node = object
		while node and node ~= player do
			if node:IsA("GuiObject") and not node.Visible then return false end
			if node:IsA("ScreenGui") and not node.Enabled then return false end
			node = node.Parent
		end
		return true
	end
	local function rect(object)
		local p, s = object.AbsolutePosition, object.AbsoluteSize
		return { x = p.X, y = p.Y, w = s.X, h = s.Y, cx = p.X + s.X / 2, cy = p.Y + s.Y / 2 }
	end
	local function color(object)
		if (object:IsA("ImageLabel") or object:IsA("ImageButton")) and object.ImageTransparency < 0.2 and object.Image ~= "" then
			return object.ImageColor3
		end
		if object.BackgroundTransparency < 0.2 then return object.BackgroundColor3 end
		return nil
	end
	local function aligned(a, b)
		return math.abs(a.cy - b.cy) <= math.min(a.h, b.h) * 0.25
			and b.h >= a.h * 0.65 and b.h <= a.h * 1.5
	end
	local function disconnect_cache()
		manager.generation = manager.generation + 1
		for _, connection in ipairs(manager.cache_connections) do connection:Disconnect() end
		manager.cache_connections = {}
		manager.texts, manager.screens, manager.owners = {}, {}, {}
		manager.gui, manager.indexed, manager.state = nil, false, nil
	end
	local function index_object(object)
		if not object:IsA("GuiObject") or object:IsDescendantOf(app.ScreenGui) then return end
		if object:IsA("TextButton") or object:IsA("TextLabel") then manager.texts[object] = true end
		local screen = object:FindFirstAncestorWhichIsA("ScreenGui")
		if screen then
			local objects = manager.screens[screen]
			if not objects then objects = {}; manager.screens[screen] = objects end
			objects[object], manager.owners[object] = true, screen
		end
	end
	local function bind_gui(gui)
		if manager.gui == gui then return end
		disconnect_cache()
		manager.gui = gui
		if not gui then return end
		local generation = manager.generation
		table.insert(manager.cache_connections, app:Connect(gui.DescendantAdded, function(object)
			if manager.stopped or manager.generation ~= generation then return end
			index_object(object)
		end))
		table.insert(manager.cache_connections, app:Connect(gui.DescendantRemoving, function(object)
			if manager.generation ~= generation then return end
			local screen = manager.owners[object]
			if screen and manager.screens[screen] then manager.screens[screen][object] = nil end
			manager.texts[object], manager.owners[object] = nil, nil
			if object:IsA("ScreenGui") then manager.screens[object] = nil end
		end))
		-- Build once outside RenderStepped and yield between chunks. Later changes use events.
		task.spawn(function()
			app:Run("indice dodge", function()
				local objects = gui:GetDescendants()
				for i, object in ipairs(objects) do
					if manager.stopped or manager.generation ~= generation then return end
					if object:IsDescendantOf(gui) then index_object(object) end
					if i % 200 == 0 then task.wait() end
				end
				if manager.generation == generation then manager.indexed = true end
			end)
		end)
	end
	local function discover()
		local gui = player:FindFirstChild("PlayerGui")
		bind_gui(gui)
		if not gui then return nil, "PlayerGui indisponível" end
		local stops = {}
		-- Idle work only reads cached text; no geometry, colors, or ancestry for other widgets.
		for object in pairs(manager.texts) do
			local text = object.Text
			if #text <= 12 and text:match("^%s*(.-)%s*$"):lower() == "stop" and visible(object) then
				local button = object:IsA("GuiButton") and object or object:FindFirstAncestorWhichIsA("GuiButton")
				if button then table.insert(stops, button) end
			end
		end
		if #stops == 0 then return nil, manager.indexed and "aguardando botão Stop (cache ativo)" or "indexando interface em etapas" end
		local last_yellow, last_white = 0, 0
		for _, stop in ipairs(stops) do
			local screen = stop:FindFirstAncestorWhichIsA("ScreenGui")
			local stop_rect = rect(stop)
			local yellow, red, white = {}, {}, {}
			-- Inspect only the screen with the active Stop, and only while the QTE is open.
			for object in pairs(manager.screens[screen] or {}) do
				local c = color(object)
				local kind = c and (c.R > 0.8 and c.G > 0.7 and c.B < 0.35 and "yellow"
					or c.R > 0.75 and c.G < 0.4 and c.B < 0.4 and "red"
					or c.R > 0.85 and c.G > 0.85 and c.B > 0.85 and "white")
				if kind then
					local r = rect(object)
					if r.h >= 8 and r.h <= 150 and r.w >= 1 and r.y < stop_rect.y
						and stop_rect.y - r.y < 350 and visible(object) then
						if kind == "yellow" and r.w < 300 then table.insert(yellow, object)
						elseif kind == "red" then table.insert(red, object)
						elseif kind == "white" and r.w <= 16 and r.h > r.w * 2 then table.insert(white, object) end
					end
				end
			end
			last_yellow, last_white = #yellow, #white
			for _, target in ipairs(yellow) do
				local tr = rect(target)
				if screen and target:IsDescendantOf(screen) and tr.y < stop_rect.y and stop_rect.y - tr.y < 350 then
					local bar = target.Parent
					while bar and bar ~= screen do
						if bar:IsA("GuiObject") then
							local br = rect(bar)
							if br.w >= math.max(180, tr.w * 4) and br.h >= tr.h and br.h <= tr.h * 3 then break end
						end
						bar = bar.Parent
					end
					if bar and bar ~= screen then
						local has_red = false
						for _, zone in ipairs(red) do
							local rr = rect(zone)
							if zone:IsDescendantOf(bar) and aligned(tr, rr)
								and rr.x <= tr.x + tr.w + 4 and rr.x + rr.w >= tr.x - 4 then has_red = true; break end
						end
						local kind = has_red and "AutoDodge" or "AntiSteal"
						if flags[kind] then
							local markers = {}
							for _, marker in ipairs(white) do
								if marker:IsDescendantOf(bar) and aligned(tr, rect(marker)) then
									table.insert(markers, marker)
								end
							end
							if #markers > 0 then
								return { kind=kind, stop = stop, target = target, marker = markers[1], markers = markers, positions = {}, bar = bar, fired = false }
							end
						end
					end
				end
			end
		end
		return nil, "Stop encontrado; barra não identificada (amarelo=" .. last_yellow .. ", branco=" .. last_white .. ")"
	end
	local function release()
		if manager.held and vim then
			local ok, err = pcall(function() vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
			if not ok then app:RecordError("soltar Space", err) end
		end
		manager.held = false
	end
	local function activate(state)
		local ok, err = false, "VirtualInputManager indisponível"
		if vim then
			ok, err = pcall(function() vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
			if ok then
				manager.held = true
				return true, "Space enviado na faixa amarela; resultado depende do jogo"
			end
		end
		if type(firesignal) == "function" then
			ok, err = pcall(firesignal, state.stop.MouseButton1Click)
			if ok then return true, "clique Stop enviado; resultado depende do jogo" end
		end
		app:RecordError("entrada " .. (state.kind == "AntiSteal" and "Anti-Steal" or "Auto Dodge"), err)
		return false, "executor não conseguiu enviar Space nem clicar no Stop"
	end
	local function tick()
		-- Release on the next frame, also when disabled, dead, or the GUI vanished.
		release()
		if app.DialogueActive then
			manager.state, manager.next_scan = nil, 0
			app.ModuleStatus.AutoDodge = "pausado durante diálogo"
			app.ModuleStatus.AntiSteal = "pausado durante diálogo"
			return
		end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if manager.stopped or app.Unloaded or not (flags.AutoDodge or flags.AntiSteal) or not humanoid or humanoid.Health <= 0 then
			manager.state = nil
			manager.next_scan = 0
			app.ModuleStatus.AutoDodge = "desligado ou personagem indisponível"
			app.ModuleStatus.AntiSteal = "desligado ou personagem indisponível"
			return
		end
		if manager.character ~= character then
			manager.character, manager.state, manager.next_scan = character, nil, 0
		end
		local current_gui = player:FindFirstChild("PlayerGui")
		if current_gui ~= manager.gui then bind_gui(current_gui) end
		local now = os.clock()
		local state = manager.state
		if state and (not flags[state.kind] or not visible(state.stop) or not visible(state.target) or not visible(state.marker)) then
			manager.state, state, manager.next_scan = nil, nil, 0
		end
		if not state then
			if now < manager.next_scan then return end
			manager.next_scan = now + 0.15
			local reason
			state, reason = discover()
			manager.state = state
			if not state then
				if flags.AutoDodge then app.ModuleStatus.AutoDodge = reason end
				if flags.AntiSteal then app.ModuleStatus.AntiSteal = reason end
				return
			end
			app.ModuleStatus[state.kind] = "barra localizada: " .. state.marker:GetFullName()
		end
		local movement, moving_marker = 0, state.marker
		for _, candidate in ipairs(state.markers) do
			if visible(candidate) then
				local x = candidate.AbsolutePosition.X + candidate.AbsoluteSize.X / 2
				local last = state.positions[candidate]
				if last and math.abs(x - last) > movement then
					movement, moving_marker = math.abs(x - last), candidate
				end
				state.positions[candidate] = x
			end
		end
		if moving_marker ~= state.marker then
			state.marker, state.x, state.time = moving_marker, nil, nil
		end
		local mp, ms = state.marker.AbsolutePosition, state.marker.AbsoluteSize
		local tp, ts = state.target.AbsolutePosition, state.target.AbsoluteSize
		local x, target_x = mp.X + ms.X / 2, tp.X + ts.X / 2
		local bar_width = state.bar.AbsoluteSize.X
		local previous, previous_time = state.x, state.time
		state.x, state.time = x, now
		if not previous or not previous_time then return end
		local delta, dt = x - previous, now - previous_time
		if state.fired and state.direction and delta * state.direction < 0 and math.abs(delta) > math.max(20, bar_width * 0.12) then
			state.fired = false
			return
		end
		if math.abs(delta) > bar_width * 0.5 then state.fired = false; return end
		if state.fired or dt <= 0 or dt > 0.1 or math.abs(delta) < 0.05 then return end
		state.direction = delta > 0 and 1 or -1
		if input:GetFocusedTextBox() or app.Open then
			app.ModuleStatus[state.kind] = "feche o hub e a caixa de texto para enviar Space"
			return
		end
		local lead_ms = state.kind == "AntiSteal" and flags.StealLeadMs or flags.DodgeLeadMs
		local lead = math.max(0, math.min(80, tonumber(lead_ms) or 15)) / 1000
		local horizon = dt * 0.5 + lead
		local projected = x + delta / dt * horizon
		local margin = math.min(ts.X * 0.2, math.max(1, ms.X / 2))
		local inside = projected >= tp.X + margin and projected <= tp.X + ts.X - margin
		local crossing = delta > 0 and x <= target_x and projected >= target_x
			or delta < 0 and x >= target_x and projected <= target_x
		local near = math.abs(x - target_x) <= math.max(1, math.abs(delta) * 0.5)
		if inside and (crossing or near) then
			-- One attempt per sweep; never claim a successful dodge from pcall alone.
			state.fired = true
			local _, status = activate(state)
			app.ModuleStatus[state.kind] = status
		elseif not state.fired and now >= (manager.next_status or 0) then
			manager.next_status = now + 0.5
			app.ModuleStatus[state.kind] = string.format("linha %.1f / alvo %.1f · antecipação %d ms", x, target_x, math.floor(lead*1000))
		end
	end
	app:Connect(run.RenderStepped, function()
		if manager.stopped then return end
		if not (flags.AutoDodge or flags.AntiSteal) and not manager.held then
			manager.state, manager.next_scan = nil, 0
			return
		end
		if not manager.state and not manager.held and os.clock() < manager.next_scan then return end
		app:Run("dodge visual", tick)
	end)
	function manager:Stop()
		self.stopped = true
		release()
		self.state = nil
		disconnect_cache()
	end
	return manager
end


local function create_arcane_integration(app, flags, player)
	local storage = game:GetService("ReplicatedStorage")
	local integration =
		{ Restorations = {}, Aliases = {}, Rules = {}, ProfileRequested = false, Installed = 0, Stopped = false }
	local qte_names = {
		DodgeQTE = true,
		SwordQTE = true,
		FistQTE = true,
		MagicQTE = true,
		AxeQTE = true,
		DaggerQTE = true,
		HammerQTE = true,
		SpearQTE = true,
		NewThorianQTE = true,
		ThorianQTE = true,
		YarthulQTE = true,
	}
	local function rule_loader(name)
		if integration.Rules[name] then
			return integration.Rules[name]
		end
		local library = storage:FindFirstChild("Libraries")
		local folder = library and library:FindFirstChild("QTERules")
		local module = folder and folder:FindFirstChild(name)
		if not module then
			return nil
		end
		local ok, result = pcall(require, module)
		if not ok then
			app:RecordError("regra " .. name, result)
			return nil
		end
		integration.Rules[name] = result
		return result
	end
	local solver = create_qte_solver(rule_loader, function(seconds)
		task.wait(seconds)
	end)
	local function enabled(name)
		if integration.Stopped or app.Unloaded then
			return false
		end
		if name:find("Dodge", 1, true) then
			return flags.AutoDodge
		end
		if name:find("Thorian", 1, true) then
			return flags.AutoThorian or flags.AutoQTE
		end
		return flags.AutoQTE
	end
	local function wrap(name, original)
		return function(data, ...)
			if enabled(name) then
				local start = os.clock()
				local ok, result, reason = pcall(solver.Build, solver, name, data)
				if ok and result then
					local deadline = start + result.duration + (flags.QTEDelay or 0)
					while os.clock() < deadline do
						if not enabled(name) then
							return original(data, ...)
						end
						task.wait(math.min(0.1, math.max(0, deadline - os.clock())))
					end
					if enabled(name) then
						return table.unpack(result.returns, 1, result.returns.n)
					end
				else
					app:RecordError("QTE " .. name, ok and reason or result)
				end
			end
			return original(data, ...)
		end
	end
	local function patch_table(tbl, key, name)
		if name == "DodgeQTE" then return end -- Live GUI input owns dodge.
		if type(tbl) ~= "table" or type(tbl[key]) ~= "function" then
			return
		end
		for _, entry in ipairs(integration.Restorations) do
			if entry.target == tbl and entry.key == key and tbl[key] == entry.wrapper then
				return
			end
		end
		local original = tbl[key]
		local wrapper = wrap(name, original)
		local ok, err = pcall(function()
			tbl[key] = wrapper
		end)
		if ok then
			table.insert(
				integration.Restorations,
				{ target = tbl, key = key, original = original, wrapper = wrapper, kind = "table" }
			)
			integration.Installed += 1
		else
			app:RecordError("adaptar " .. name, err)
		end
	end
	local function read_callback(remote)
		if type(getcallbackvalue) == "function" then
			local ok, value = pcall(getcallbackvalue, remote, "OnClientInvoke")
			if ok then
				return true, value
			end
		end
		local ok, value = pcall(function()
			return remote.OnClientInvoke
		end)
		return ok, value
	end
	local function patch_remote(remote, name, drop)
		if name == "DodgeQTE" and not drop then return end -- Keep the original game handler.
		local readable, original = read_callback(remote)
		if not readable or type(original) ~= "function" then
			app.ModuleStatus[remote.Name] = "callback não legível; adaptação por módulos disponível"
			return
		end
		for _, entry in ipairs(integration.Restorations) do
			if entry.target == remote and original == entry.wrapper then
				return
			end
		end
		local wrapper
		if drop then
			wrapper = function(...)
				if not integration.Stopped and app.OnDropOffer then
					app:Run("oferta de drop", app.OnDropOffer, ...)
				end
				if not integration.Stopped and flags.AutoAcceptDrop then
					task.wait(0.3)
					return true
				end
				return original(...)
			end
		else
			wrapper = wrap(name, original)
		end
		local ok, err = pcall(function()
			remote.OnClientInvoke = wrapper
		end)
		if ok then
			table.insert(
				integration.Restorations,
				{ target = remote, original = original, wrapper = wrapper, kind = "remote" }
			)
			integration.Installed += 1
			app.ModuleStatus[remote.Name] = "callback adaptado com restauração"
		else
			app:RecordError("callback " .. remote.Name, err)
		end
	end
	local function canonical(name)
		if qte_names[name] then
			return name
		end
		for key, value in pairs(integration.Aliases) do
			if value == name and qte_names[key] then
				return key
			end
		end
		return nil
	end
	function integration:Discover()
		if self.Stopped then
			return
		end
		local remotes = storage:FindFirstChild("Remotes")
		local fight = remotes and remotes:FindFirstChild("Fight")
		local info = remotes and remotes:FindFirstChild("Information")
		if fight then
			for _, remote in ipairs(fight:GetChildren()) do
				if remote:IsA("RemoteFunction") then
					local name = canonical(remote.Name)
					if name then
						patch_remote(remote, name, false)
					end
				end
			end
		end
		local drops = info and info:FindFirstChild("ItemDrop")
		if drops and drops:IsA("RemoteFunction") then
			patch_remote(drops, "ItemDrop", true)
		end
		if info and not self.ProfileRequested then
			local remote = info:FindFirstChild("UIProfile")
			if remote and remote:IsA("RemoteFunction") then
				self.ProfileRequested = true
				task.spawn(function()
					local ok, result = pcall(function()
						return remote:InvokeServer()
					end)
					if self.Stopped then
						return
					end
					if ok and type(result) == "table" then
						self.Aliases = result
						app.ModuleStatus.UIProfile = "carregado"
						self:Discover()
					else
						app.ModuleStatus.UIProfile = "indisponível"
					end
				end)
			end
		end
		local gui = player:FindFirstChild("PlayerGui")
		local combat = gui and gui:FindFirstChild("Combat")
		if combat then
			local containers = { combat }
			for _, child in ipairs(combat:GetChildren()) do
				if child:IsA("LocalScript") or child:IsA("Folder") then
					table.insert(containers, child)
				end
			end
			local count = 0
			for _, container in ipairs(containers) do
				for _, module in ipairs(container:GetChildren()) do
					local name = canonical(module.Name)
					if name and module:IsA("ModuleScript") then
						local ok, result = pcall(require, module)
						if ok then
							patch_table(result, "Run", name)
						else
							app:RecordError("módulo " .. module.Name, result)
						end
					end
					count += 1
					if count % 25 == 0 then
						task.wait()
					end
					if count >= 200 then
						break
					end
				end
				if count >= 200 then
					break
				end
			end
		end
		app.ModuleStatus.QTE = "adaptações instaladas: " .. self.Installed
	end
	function integration:ScanGC()
		if type(getgc) ~= "function" then
			app:Notify({ Content = "getgc indisponível." })
			return
		end
		local ok, objects = pcall(getgc, true)
		if not ok then
			app:RecordError("scan QTE", objects)
			return
		end
		local start = os.clock()
		for index, obj in ipairs(objects) do
			if self.Stopped or index > 16000 or os.clock() - start > 2 then
				break
			end
			if type(obj) == "table" then
				for name in pairs(qte_names) do
					if type(rawget(obj, name)) == "function" then
						patch_table(obj, name, name)
					end
				end
				for name, alias in pairs(self.Aliases) do
					if qte_names[name] and type(alias) == "string" and type(rawget(obj, alias)) == "function" then
						patch_table(obj, alias, name)
					end
				end
			end
			if index % 80 == 0 then
				task.wait()
			end
		end
		app.ModuleStatus.QTE = "adaptações instaladas: " .. self.Installed
		app:Notify({ Content = "Busca encerrada: " .. self.Installed .. " adaptações QTE na sessão." })
	end
	function integration:Stop()
		self.Stopped = true
		for index = #self.Restorations, 1, -1 do
			local entry = self.Restorations[index]
			local ok, err = pcall(function()
				if entry.kind == "table" then
					if entry.target[entry.key] == entry.wrapper then
						entry.target[entry.key] = entry.original
					end
				elseif entry.target.Parent then
					local readable, current = read_callback(entry.target)
					if readable and current == entry.wrapper then
						entry.target.OnClientInvoke = entry.original
					end
				end
			end)
			if not ok then
				app:RecordError("restaurar QTE", err)
			end
		end
		table.clear(self.Restorations)
	end
	return integration
end

-- Community catalog: examples, not an exhaustive loot table or drop-rate promise.
-- Sources and known inventory limitations are listed in LEIA-ME-ARCANE.md.
local function create_drop_farm(app, flags, window, dep)
	local catalog = {
		["King Slime"] = {
			items = { "Slime Buckler", "Gelat Band" },
			note = "Miniboss. Pode oferecer itens diferentes; não há garantia de revanche. Inicie o encontro manualmente.",
		},
		["Yar'thul"] = {
			items = {
				"Dragontooth Blade",
				"Dragonbone Gauntlets",
				"Dragonbone Spear",
				"Dragonflame Shield",
				"Ring of the Dragon",
				"Reality Watch",
				"Shifting Hourglass",
				"Memory Fragment",
				"Soul Dust",
				"Phoenix Tear",
				"Lineage Shard",
			},
			destination = "Yar'thul (Door Entrance)",
			note = "Boss de Mount Thul. Equipamentos e artefatos são possibilidades distintas. Alguns drops usam sorteio do grupo.",
		},
		["Thorian"] = {
			items = {
				"Blightrock Dagger",
				"Blightrock Staff",
				"Blightrock Cestus",
				"Memory Fragment",
				"Soul Dust",
				"Phoenix Tear",
				"Lineage Shard",
			},
			destination = "Thorian (Rotten Arena)",
			note = "Boss da área de Cess. Oferece armas Blight e outros drops. Repetir o mesmo tipo de dano pode curá-lo: ajuste suas habilidades manualmente.",
		},
	}
	local manager = {
		Active = false,
		Generation = 0,
		Records = {},
		Battles = 0,
		Offers = 0,
		Repeats = 0,
		Received = 0,
		Status = "Escolha o inimigo e o item. Inicie o primeiro combate manualmente.",
	}
	local function normalize(value)
		return tostring(value or ""):lower():gsub("[^%w]", "")
	end
	local function enemy_key(name)
		local key = normalize(name)
		if key == "yarthul" or key == "yarthultheblazingdragon" then
			return "Yar'thul"
		end
		if key == "thorian" or key == "thoriantherotten" then
			return "Thorian"
		end
		if key == "kingslime" then
			return "King Slime"
		end
		return tostring(name)
	end
	local function count_tools(name)
		local total = 0
		local backpack = dep.player:FindFirstChildOfClass("Backpack")
		if not backpack then
			return nil
		end
		for _, container in pairs({ backpack, dep.player.Character }) do
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") and normalize(item.Name) == normalize(name) then
					total += 1
				end
			end
		end
		return total
	end
	local tab = window:AddTab("Drops")
	local target_card = dep.group(tab, "Inimigo e recompensa")
	local info_card = dep.group(tab, "Drops e acompanhamento", "Right")
	local names = {}
	for name in pairs(catalog) do
		table.insert(names, name)
	end
	table.sort(names)
	local target = dep.select_value(target_card, "DropEnemy", "NPC / boss do farm", names, "Yar'thul")
	local item = dep.select_value(target_card, "DropItem", "Drop desejado", catalog[flags.DropEnemy].items)
	dep.textbox(target_card, "DropCustomItem", "Outro item · nome exato", "")
	dep.slider(target_card, "DropGoal", "Novas unidades desejadas", 1, 20, 1, 0)
	local enabled = dep.toggle(target_card, "DropFarmEnabled", "Farm até obter item", false)
	local overview = info_card:AddLabel("", { Height = 225 })
	local status = info_card:AddLabel("", { Height = 145 })
	local limits = dep.group(tab, "Repetição e limites")
	dep.speed_slider(limits, "BossTravelSpeed")
	dep.toggle(limits, "DropRepeat", "Repetir revanche do alvo", true)
	dep.slider(limits, "DropWait", "Espera antes da revanche", 2, 15, 5, 0, " s")
	dep.slider(limits, "DropBattleLimit", "Limite de combates · 0 sem limite", 0, 200, 20, 0)
	dep.slider(limits, "DropTimeLimit", "Tempo máximo · 0 sem limite", 0, 180, 30, 0, " min")
	dep.slider(limits, "DropMinHP", "Parar abaixo de HP", 0, 90, 20, 0, "%")
	local function selected_item()
		local custom = (flags.DropCustomItem or ""):match("^%s*(.-)%s*$")
		return custom ~= "" and custom or flags.DropItem
	end
	local function refresh_text()
		local entry = catalog[flags.DropEnemy]
		overview:SetText(
			"Alvo: "
				.. tostring(flags.DropEnemy)
				.. "\n"
				.. (entry and entry.note or "Sem tabela de drops verificada. Informe o nome exato do item.")
				.. "\nExemplos de drops (referência da comunidade): "
				.. (entry and table.concat(entry.items, ", ") or "não cadastrados")
				.. "\nUma lista de possibilidades não significa receber todos os itens. Chances não são alteradas."
		)
		status:SetText(
			manager.Status
				.. "\nSessão: "
				.. tostring(manager.Target or "—")
				.. " / "
				.. tostring(manager.Item or selected_item() or "—")
				.. "\nNovos no inventário: "
				.. manager.Received
				.. " / "
				.. tostring(manager.Goal or flags.DropGoal)
				.. " · Combates encerrados: "
				.. manager.Battles
				.. "\nOfertas do item: "
				.. manager.Offers
				.. " · Revanches aceitas: "
				.. manager.Repeats
				.. "\nLeitura: Tools na mochila/personagem; equipamentos guardados em outros sistemas não são confirmados."
		)
	end
	local function set_status(value)
		manager.Status = value
		app.ModuleStatus.DropFarm = value
		refresh_text()
	end
	function manager:Stop(reason)
		if not self.Active then
			return
		end
		self.Active = false
		self.Generation += 1
		flags.DropFarmEnabled = false
		enabled:SetValue(false, true)
		for key, old in pairs(self.Previous or {}) do
			local control = app.Options[key]
			if control and control.Value == true then
				control:SetValue(old)
			end
		end
		self.Previous = {}
		set_status(reason or "Farm interrompido.")
		dep.notice(self.Status)
	end
	function manager:Start()
		if self.Active then
			return true
		end
		if dep.stop_level then
			dep.stop_level()
		end
		local name = selected_item()
		if type(name) ~= "string" or name == "" then
			enabled:SetValue(false, true)
			flags.DropFarmEnabled = false
			dep.notice("Escolha um item ou informe seu nome exato.")
			return false
		end
		local initial = count_tools(name)
		if initial == nil then
			enabled:SetValue(false, true)
			flags.DropFarmEnabled = false
			dep.notice("Mochila indisponível. Aguarde o personagem carregar.")
			return false
		end
		dep.stop_movement()
		app.Options.EssenceFarm:SetValue(false)
		app.Options.AutoFarmItems:SetValue(false)
		self.Active = true
		self.Generation += 1
		flags.DropFarmEnabled = true
		self.Target = flags.DropEnemy
		self.Item = name
		self.Goal = flags.DropGoal
		self.Baseline = initial
		self.Started = os.clock()
		self.Records = {}
		self.LastRecord = nil
		self.Battles = 0
		self.Offers = 0
		self.Repeats = 0
		self.Received = 0
		self.Previous = {}
		for _, key in ipairs({ "AutoAttack", "AutoDodge", "AutoQTE", "AutoAcceptDrop" }) do
			local control = app.Options[key]
			if control then
				self.Previous[key] = control.Value
				control:SetValue(true)
			end
		end
		set_status("Ativo. Inicie o primeiro combate do alvo; a revanche depende da oferta do jogo.")
		return true
	end
	enabled.Callback = function(value)
		if value then
			manager:Start()
		else
			manager:Stop("Farm interrompido pelo painel.")
		end
	end
	function manager:ObserveTeam(enemies, battle)
		if type(enemies) ~= "table" or not battle then
			return
		end
		local seen = {}
		for _, enemy in ipairs(enemies) do
			if typeof(enemy) == "Instance" and enemy.Parent then
				local name = enemy_key(enemy.Name)
				seen[name] = true
				if not table.find(names, name) then
					table.insert(names, name)
					table.sort(names)
					target:SetValues(names)
				end
			end
		end
		if self.Active then
			local record = self.Records[tostring(battle)] or { ID = tostring(battle), Target = self.Target }
			record.Match = seen[self.Target] == true
			self.Records[record.ID] = record
			self.LastRecord = record
			set_status(
				record.Match and "Em combate com o alvo selecionado."
					or "Outro inimigo em combate; ele não terá revanche automática neste farm."
			)
		end
	end
	function manager:AllowsAttack(enemies, battle)
		self:ObserveTeam(enemies, battle)
		return not self.Active
			or (self.LastRecord and self.LastRecord.ID == tostring(battle) and self.LastRecord.Match == true)
	end
	function manager:EndFight()
		local record = self.LastRecord
		if self.Active and record and record.Match and not record.Ended then
			record.Ended = true
			self.Battles += 1
			set_status("Combate encerrado; aguardando recompensa. Isso não confirma vitória nem drop.")
		end
	end
	function manager:Offer(source, name)
		if not self.Active or type(name) ~= "string" then
			return
		end
		if normalize(name) == normalize(self.Item) then
			self.Offers += 1
			set_status("Item oferecido no sorteio. Aguardando aparecer na mochila; oferta não confirma recebimento.")
		end
	end
	function manager:Tick()
		if not self.Active then
			refresh_text()
			return
		end
		self.Goal = flags.DropGoal
		local char, hum = dep.parts()
		if not char or not hum or hum.Health <= 0 then
			self:Stop("Personagem indisponível ou morto; farm encerrado.")
			return
		end
		if hum.MaxHealth and hum.MaxHealth > 0 and hum.Health / hum.MaxHealth * 100 <= flags.DropMinHP then
			self:Stop("Limite de HP atingido; novas ações do farm interrompidas.")
			return
		end
		local current = count_tools(self.Item)
		if current ~= nil then
			self.Received = math.max(0, current - self.Baseline)
		end
		if self.Received >= self.Goal then
			self:Stop("Meta confirmada: o item apareceu como Tool no inventário. Farm encerrado.")
			return
		end
		if flags.DropTimeLimit > 0 and os.clock() - self.Started >= flags.DropTimeLimit * 60 then
			self:Stop("Tempo máximo atingido.")
			return
		end
		if flags.DropBattleLimit > 0 and self.Battles >= flags.DropBattleLimit then
			self:Stop("Limite de combates encerrados atingido.")
			return
		end
		local battle = dep.fight_id()
		if battle and not self.Records[tostring(battle)] then
			local team = dep.remote("Data", "GetOtherTeam")
			if team then
				local generation = self.Generation
				local enemies = team:InvokeServer(battle)
				if self.Active and self.Generation == generation and dep.fight_id() == battle then
					self:ObserveTeam(enemies, battle)
				end
			end
		end
		refresh_text()
	end
	function manager:Refight(event, details)
		if not self.Active then
			return false
		end
		if type(details) ~= "table" or not details.BattleID then
			return true
		end
		local record = self.Records[tostring(details.BattleID)]
		if not record or not record.Match or record.Pending or record.Accepted then
			return true
		end
		if not record.Ended then
			record.Ended = true
			self.Battles += 1
		end
		if not flags.DropRepeat then
			set_status("Revanche desativada; aguardando um novo combate manual.")
			return true
		end
		record.Pending = true
		local generation = self.Generation
		task.delay(flags.DropWait, function()
			if not self.Active or self.Generation ~= generation then
				return
			end
			app:Run("farm de drops / revanche", function()
				self:Tick()
				if not self.Active or self.Generation ~= generation or not flags.DropRepeat or not event.Parent then
					return
				end
				if dep.fight_id() and tostring(dep.fight_id()) ~= record.ID then
					return
				end
				event:FireServer(details.BattleID, "Accept")
				record.Accepted = true
				self.Repeats += 1
				set_status("Revanche aceita para o alvo; aguardando o jogo iniciar o combate.")
			end)
		end)
		return true
	end
	local function change_target(value)
		if flags.DropEnemy == value then
			refresh_text()
			return
		end
		if manager.Active then
			manager:Stop("Alvo ou item alterado; inicie uma nova sessão de farm.")
		end
		flags.DropEnemy = value
		local entry = catalog[value]
		item:SetValues(entry and entry.items or {})
		flags.DropItem = item.Value
		refresh_text()
	end
	target.Callback = change_target
	item.Callback = function(value)
		if manager.Active then
			manager:Stop("Item alterado; inicie uma nova sessão de farm.")
		end
		flags.DropItem = value
		refresh_text()
	end
	app.Options.DropCustomItem.Callback = function(value)
		if manager.Active then
			manager:Stop("Nome do item alterado; inicie uma nova sessão de farm.")
		end
		flags.DropCustomItem = value
		refresh_text()
	end
	dep.button(target_card, "Atualizar leitura do inventário", function()
		manager:Tick()
		local count = count_tools(selected_item())
		dep.notice("Unidades visíveis como Tool: " .. tostring(count or "mochila indisponível"))
	end)
	dep.button(target_card, "Ir até a entrada do alvo", function()
		local entry = catalog[flags.DropEnemy]
		local position = entry and entry.destination and destinations.Bosses[entry.destination]
		if not position then
			dep.notice("Não há coordenada cadastrada para esse alvo. Entre no encontro manualmente.")
			return
		end
		local ok, reason = dep.travel(position)
		if not ok then
			dep.notice(reason)
		end
	end)
	dep.button(limits, "Parar farm de drops", function()
		manager:Stop("Farm interrompido pelo painel.")
	end)
	dep.button(limits, "Auto Farm Yar'thul", function()
		if manager.Active then
			manager:Stop("Preparando farm do Yar'thul.")
		end
		target:SetValue("Yar'thul")
		flags.DropRepeat = true
		app.Options.DropRepeat:SetValue(true)
		flags.DropCustomItem = ""
		app.Options.DropCustomItem:SetValue("", true)
		enabled:SetValue(true)
		if manager.Active and not dep.in_combat() then
			local ok, reason = dep.travel(destinations.Bosses["Yar'thul (Door Entrance)"])
			if not ok then
				dep.notice(reason)
			end
		end
	end)
	refresh_text()
	return manager
end

-- Bounded leveling state machine. Only existing game prompts/buttons are used.
local function create_level_farm(app, flags, tab, dep)
	local farm =
		{ Active = false, Generation = 0, Cycles = 0, Status = "Defina um ponto de encontro antes de iniciar." }
	local card = dep.group(tab, "Auto Leveling")
	local enabled = dep.toggle(card, "AutoLevelFarm", "Auto Leveling / XP", false)
	dep.select_value(
		card,
		"LevelMode",
		"Modo de progressão",
		{ "Só essência", "Leveling com Aretim" },
		"Leveling com Aretim"
	)
	dep.slider(card, "LevelCycles", "Ciclos de leveling", 1, 50, 1, 0)
	dep.slider(card, "LevelTimeLimit", "Tempo máximo de leveling", 1, 180, 30, 0, " min")
	dep.slider(card, "LevelMinHP", "Parar leveling abaixo de HP", 0, 90, 20, 0, "%")
	dep.select_value(
		card,
		"LevelStat",
		"Distribuição de atributos",
		{ "Manual", "Strength", "Arcane", "Endurance", "Speed", "Luck" },
		"Manual"
	)
	local info = dep.group(tab, "Progresso do leveling", "Right")
	local display = info:AddLabel("", { Height = 175 })
	local positions = { mat = Vector3.new(5106.5, 656.1, -4322.8), aretim = Vector3.new(789.8, 238, 2120.8) }
	local function report(text)
		farm.Status = text
		app.ModuleStatus.LevelFarm = text
		display:SetText(
			text
				.. "\nCiclos confirmados: "
				.. farm.Cycles
				.. " / "
				.. flags.LevelCycles
				.. "\nUsa a meta de essência e o raio de patrulha desta aba.\nPrimeiro ciclo: ponto de encontro → essência → meditação → Aretim → atributos → retorno.\nManual pausa na tela de atributos. Nenhuma classe é comprada e nenhum reset é feito."
		)
	end
	local function phase(name, text)
		farm.Phase = name
		farm.Since = os.clock()
		report(text)
	end
	local function meditate()
		local char = dep.player.Character
		local event = char and dep.find(char, "MeditateHandler", "Meditate")
		if event and event:IsA("RemoteEvent") then
			event:FireServer()
			return true
		end
		return false
	end
	local function press(button)
		if type(firesignal) ~= "function" or not button or not button:IsA("GuiButton") then
			return false
		end
		firesignal(button.MouseButton1Click)
		return true
	end
	local function prompt(object)
		local p = object and object:FindFirstChildWhichIsA("ProximityPrompt", true)
		if not p or p.Enabled == false or type(fireproximityprompt) ~= "function" then
			return false
		end
		fireproximityprompt(p)
		return true
	end
	local function stat_panel()
		local panel = dep.find(dep.player, "PlayerGui", "HUD", "StatAllocateOLD")
		return panel and panel.Visible and panel or nil
	end
	local function points(panel)
		local label = panel and panel:FindFirstChild("StatPoints")
		return label and tonumber(tostring(label.Text):match("%d+")) or nil
	end
	function farm:Stop(reason)
		if not self.Active then
			return
		end
		self.Active = false
		self.Generation += 1
		flags.AutoLevelFarm = false
		enabled:SetValue(false, true)
		dep.stop_movement()
		for key, value in pairs(self.Previous or {}) do
			if app.Options[key].Value == true then
				app.Options[key]:SetValue(value)
			end
		end
		report(reason or "Leveling interrompido.")
		dep.notice(self.Status)
	end
	function farm:Start()
		if self.Active then
			return true
		end
		local _, hum, root = dep.parts()
		local reason
		if not dep.get_marker() then
			reason = "Defina o ponto em Usar minha posição como encontro."
		elseif not hum or not root or hum.Health <= 0 then
			reason = "Aguarde o personagem aparecer."
		elseif dep.essence() == nil then
			reason = "Contador de essência indisponível."
		elseif
			flags.LevelMode == "Leveling com Aretim"
			and (type(firesignal) ~= "function" or type(fireproximityprompt) ~= "function")
		then
			reason =
				"Leveling requer firesignal e fireproximityprompt neste executor. Só essência continua disponível."
		end
		if reason then
			flags.AutoLevelFarm = false
			enabled:SetValue(false, true)
			dep.notice(reason)
			report(reason)
			return false
		end
		if dep.stop_boss then
			dep.stop_boss()
		end
		dep.stop_movement()
		app.Options.EssenceFarm:SetValue(false)
		app.Options.AutoFarmItems:SetValue(false)
		self.Active = true
		self.Generation += 1
		flags.AutoLevelFarm = true
		self.Cycles = 0
		self.Previous = {}
		self.Direction = 1
		self.LastMove = -math.huge
		self.Started = os.clock()
		self.Mode = flags.LevelMode
		self.Stat = flags.LevelStat
		self.Marker = dep.get_marker()
		for _, key in ipairs({ "AutoAttack", "AutoDodge", "AutoQTE" }) do
			self.Previous[key] = app.Options[key].Value
			app.Options[key]:SetValue(true)
		end
		phase("farm", "Buscando encontros no ponto salvo.")
		return true
	end
	enabled.Callback = function(value)
		if value then
			farm:Start()
		else
			farm:Stop("Leveling interrompido pelo painel.")
		end
	end
	local function move(position, next_phase, text)
		phase("travel", text)
		local generation = farm.Generation
		local ok, reason = dep.travel(position, function()
			if farm.Active and farm.Generation == generation then
				phase(next_phase, text)
			end
		end)
		if not ok then
			farm:Stop("Percurso não iniciado: " .. tostring(reason))
		end
	end
	function farm:Tick()
		if not self.Active then
			return
		end
		local generation = self.Generation
		local function current()
			return self.Active and self.Generation == generation
		end
		local _, hum, root = dep.parts()
		if not hum or not root or hum.Health <= 0 then
			self:Stop("Personagem indisponível ou morto.")
			return
		end
		if hum.MaxHealth and hum.MaxHealth > 0 and hum.Health / hum.MaxHealth * 100 <= flags.LevelMinHP then
			self:Stop("Limite de HP do leveling atingido.")
			return
		end
		if os.clock() - self.Started >= flags.LevelTimeLimit * 60 then
			self:Stop("Tempo máximo de leveling atingido.")
			return
		end
		if self.Mode ~= flags.LevelMode or self.Stat ~= flags.LevelStat then
			self:Stop("Modo ou atributo alterado; inicie outra sessão.")
			return
		end
		if dep.in_combat() then
			if self.Phase == "travel" then
				self.ResumeFarm = true
			end
			return
		end
		if self.ResumeFarm then
			self.ResumeFarm = false
			phase("farm", "Combate encerrado; retomando os encontros.")
		end
		local elapsed = os.clock() - self.Since
		if self.Phase == "travel" then
			if elapsed > 180 then
				self:Stop("Percurso demorou demais. Confira o caminho e reinicie.")
			elseif elapsed > 1 and not dep.is_moving() then
				self:Stop("Percurso interrompido; leveling pausado.")
			end
			return
		end
		if self.Phase == "farm" then
			local value = dep.essence()
			if value == nil then
				self:Stop("Leitura de essência perdida.")
				return
			end
			if value >= flags.EssenceGoal then
				if self.Mode == "Só essência" then
					self:Stop("Meta de essência atingida.")
					return
				end
				self.BeforeEssence = value
				move(positions.mat, "meditate", "Indo ao ponto de meditação de Caldera.")
				return
			end
			if dep.is_moving() then
				return
			end
			if (root.Position - self.Marker).Magnitude > 60 then
				move(self.Marker, "farm", "Voltando ao ponto de encontros.")
				return
			end
			if os.clock() - self.LastMove > 3 then
				self.Direction = -self.Direction
				self.LastMove = os.clock()
				hum:MoveTo(self.Marker + Vector3.new(self.Direction * flags.PatrolRadius, 0, 0))
			end
			report("Farm de encontros: " .. value .. " / " .. flags.EssenceGoal .. " de essência.")
		elseif self.Phase == "meditate" then
			if not meditate() then
				local mats = workspace:FindFirstChild("Mats")
				local best, distance = nil, 20
				if mats then
					for _, mat in ipairs(mats:GetChildren()) do
						local part = mat:FindFirstChild("Root")
						if part and (part.Position - root.Position).Magnitude < distance then
							best = mat
							distance = (part.Position - root.Position).Magnitude
						end
					end
				end
				local ok = prompt(best)
				if not current() then
					return
				end
				if not ok then
					self:Stop(
						"Não foi possível acionar a meditação; nenhum evento ou prompt conhecido foi encontrado."
					)
					return
				end
			end
			phase("spirit", "Aguardando a área de Aretim carregar.")
		elseif self.Phase == "spirit" then
			if (root.Position - positions.aretim).Magnitude < 400 then
				move(positions.aretim, "aretim", "Aproximando de Aretim.")
			elseif elapsed > 20 then
				self:Stop("Meditação não confirmou chegada à área de Aretim.")
			end
		elseif self.Phase == "aretim" then
			local npc = dep.find(workspace, "NPCs", "Aretim")
			local ok = prompt(npc)
			if not current() then
				return
			end
			if not ok then
				self:Stop("Aretim ou seu prompt não está carregado.")
				return
			end
			phase("dialogue", "Aguardando a opção de subir de nível em Aretim.")
		elseif self.Phase == "dialogue" then
			local dialogue = dep.find(dep.player, "PlayerGui", "NPCDialogue")
			if dialogue and dialogue.Enabled then
				for _, obj in ipairs(dialogue:GetDescendants()) do
					if obj:IsA("GuiButton") and obj.Visible then
						local label = obj:FindFirstChildWhichIsA("TextLabel", true)
						local text = tostring(
							label and label.Text ~= "" and label.Text or (obj:IsA("TextButton") and obj.Text) or ""
						):lower()
						if text:find("as much", 1, true) and text:find("light", 1, true) then
							local ok = press(obj)
							if not current() then
								return
							end
							if ok then
								phase("stats", "Aguardando a tela de atributos.")
								return
							end
						end
					end
				end
			end
			if elapsed > 12 then
				self:Stop("Opção de leveling de Aretim não encontrada; diálogo não foi concluído.")
			end
		elseif self.Phase == "stats" then
			local panel = stat_panel()
			if panel then
				if self.Stat == "Manual" then
					self:Stop(
						"Tela de atributos aberta. Distribua os pontos manualmente; o personagem permanece em Aretim."
					)
					return
				end
				self.InitialPoints = points(panel)
				self.LastPoints = nil
				self.LastPointTime = os.clock()
				if not self.InitialPoints or self.InitialPoints <= 0 then
					self:Stop("Nenhum ponto novo confirmado na tela de atributos.")
					return
				end
				phase("allocate", "Distribuindo pontos em " .. self.Stat .. "; verificando a redução do saldo.")
			elseif elapsed > 12 then
				self:Stop("A tela de atributos conhecida não abriu. Leveling não confirmado.")
			end
		elseif self.Phase == "allocate" then
			local panel = stat_panel()
			local count = points(panel)
			if not panel or not count then
				self:Stop("Tela de atributos indisponível durante a distribuição.")
				return
			end
			if count == 0 then
				local ok = press(panel:FindFirstChild("Finish"))
				if not current() then
					return
				end
				if not ok then
					self:Stop("Botão para concluir atributos indisponível.")
					return
				end
				phase("verify", "Verificando a conclusão do leveling.")
				return
			end
			if self.LastPoints == count then
				if os.clock() - self.LastPointTime > 6 then
					self:Stop("A distribuição não reduziu o saldo de pontos; interrompido.")
				end
				return
			end
			local amount = panel:FindFirstChild("ToAllocate")
			if amount and amount:IsA("TextBox") then
				amount.Text = "1"
			end
			local ok = press(panel:FindFirstChild(self.Stat .. "Up"))
			if not current() then
				return
			end
			if not ok then
				self:Stop("Botão do atributo escolhido não encontrado.")
				return
			end
			self.LastPoints = count
			self.LastPointTime = os.clock()
		elseif self.Phase == "verify" then
			local value = dep.essence()
			if not stat_panel() and value and value < self.BeforeEssence then
				self.Cycles += 1
				if not meditate() then
					self:Stop("Ciclo concluído; saída da meditação indisponível.")
					return
				end
				phase("exit", "Aguardando sair da meditação.")
			elseif elapsed > 12 then
				self:Stop("A conclusão não foi confirmada pela tela e pelo consumo de essência.")
			end
		elseif self.Phase == "exit" then
			if (root.Position - positions.aretim).Magnitude > 500 then
				if self.Cycles >= flags.LevelCycles then
					self:Stop("Meta de ciclos de leveling concluída.")
				else
					move(self.Marker, "farm", "Retornando ao ponto de encontros.")
				end
			elseif elapsed > 20 then
				self:Stop("A saída da meditação não foi confirmada.")
			end
		end
	end
	dep.button(card, "Parar leveling", function()
		farm:Stop("Leveling interrompido pelo painel.")
	end)
	report(farm.Status)
	return farm
end

-- Community guidance reviewed on 2026-10-22. Suggested bands are routing advice,
-- not claims that a quest has those server-side level requirements.
local function create_quest_catalog()
	local sources = {
		quests = "https://arcane-lineage.fandom.com/wiki/Quests",
		yorn = "https://arcane-lineage.fandom.com/wiki/Yorn",
		start = "https://arcane-lineage.wiki/guides/quests/",
		progress = "https://arcane-lineage.wiki/guides/level-progression/",
		hunter = "https://arcane-lineage.fandom.com/wiki/Thorin",
		lorra = "https://arcane-lineage.fandom.com/wiki/Lorra",
	}
	local entries = {
		{ id="yorn", name="Yorn / Daze", low=1, high=4, alignment="Neutro", city="Caldera City", npcs={"Yorn"},
			location="Caldera; procure Yorn perto do centro.", goal="Derrote 3 Slimes após aceitar e volte a Yorn.", reward="Daze.",
			requirement="Priorize antes da classe. As páginas divergem sobre o limite de nível; confirme com Yorn.", source="yorn" },
		{ id="book", name="H.T. Louie / Encyclopedia", low=1, high=14, alignment="Neutro", city="Caldera City", npcs={"H.T Louie","H.T. Louie","Louie"},
			location="Caldera; H.T. Louie.", goal="Converse sobre a Encyclopedia e siga os pedidos do diálogo.", reward="Acesso à Encyclopedia.",
			requirement="Confirme materiais e condições no NPC.", source="start" },
		{ id="base", name="Marco: classe base", low=5, high=14, alignment="Neutro", city="Caldera City", npcs={},
			location="Treinador da classe escolhida.", goal="Escolha arma e classe; use a aba Viagens para localizar seu treinador.", reward="Habilidades de classe.",
			requirement="Marco comunitário: nível 5; custos variam por treinador.", source="progress" },
		{ id="slimes", name="Guilda: Slime Cleaning", low=1, high=9, alignment="Neutro", city="Caldera City", npcs={"Guild Clerk","GuildClerk","Guild Member"}, repeatable=true,
			location="Quadro de Caldera.", goal="Aceite a tarefa disponível e derrote 8 Slimes.", reward="Ouro e essência.", requirement="Depende da oferta no quadro.", source="quests" },
		{ id="chunks", name="Guilda: Slime Investigation", low=1, high=14, alignment="Neutro", city="Caldera City", npcs={"Guild Clerk","GuildClerk","Guild Member"}, repeatable=true,
			location="Quadro de Caldera.", goal="Entregue 5 Slime Chunks ao atendente.", reward="Ouro, essência e poção.", requirement="Aceite a tarefa no quadro.", source="quests" },
		{ id="hunter", name="Thorin / treinamento de Hunter", low=10, high=40, alignment="Neutro", city="Caldera City", npcs={"Thorin"},
			location="Floresta de The Crossing; Thorin.", goal="Etapas: Mushroom Cap + 250 ouro; Sand Core + 250 ouro; Restless Fragment.", reward="Sneak, Mark e acesso ao bestiário, conforme a etapa.",
			requirement="A página comunitária relata nível 10 para iniciar. Confira a etapa no diálogo.", source="hunter" },
		{ id="drums", name="Horiya / Sand Core", low=10, high=24, alignment="Neutro", city="Caldera City", npcs={"Horiya"},
			location="Caldera; próximo ao banco.", goal="Entregue 1 Sand Core.", reward="Everbeating Drums e ouro.", requirement="Tenha o material antes de viajar.", source="quests" },
		{ id="package", name="Entrega de pacote", low=5, high=24, alignment="Ordeiro", city="Caldera City", npcs={"Poria","Poira","Poirae"},
			location="Caldera; entrega em Old Ruins.", goal="Aceite o pacote e leve ao destinatário indicado.", reward="Ouro e essência; rota ordeira.", requirement="Confirme o destinatário no diálogo.", source="quests" },
		{ id="ingredients", name="Ingredient Help / ordeiro", low=10, high=24, alignment="Ordeiro", city="Westwood Heart", npcs={},
			location="Casa em Westwood Heart.", goal="Entregue 3 Carnastools.", reward="Ouro e essência; rota ordeira.", requirement="Localize o solicitante no local.", source="quests" },
		{ id="crylight_o", name="Crylight Needed / ordeiro", low=15, high=40, alignment="Ordeiro", city="Westwood Heart", npcs={},
			location="Way of Life, Westwood.", goal="Entregue 1 Crylight ao solicitante.", reward="Ouro, essência e consumível; rota ordeira.", requirement="Tenha Crylight.", source="quests" },
		{ id="crylight_c", name="Someone is going to die / caótico", low=15, high=40, alignment="Caótico", city="Westwood Heart", npcs={},
			location="Varanda de uma casa em Westwood.", goal="Entregue 1 Crylight.", reward="Ouro, essência e consumível; rota caótica.", requirement="Esta escolha segue alinhamento caótico.", source="quests" },
		{ id="super", name="Marco: superclasse", low=15, high=24, alignment="Neutro", city="Caldera City", npcs={},
			location="Treinador da sua superclasse; veja Viagens.", goal="Defina a superclasse e confira alinhamento, habilidades anteriores e ouro.", reward="Progressão de classe.",
			requirement="Marco comunitário: nível 15; nível sozinho não basta.", source="progress" },
		{ id="desert", name="Guilda: Bandit Cleaning", low=15, high=29, alignment="Neutro", city="The Old Ruins", npcs={"Guild Clerk","GuildClerk","Guild Member"}, repeatable=true,
			location="Quadro de Old Ruins.", goal="Aceite a tarefa e derrote 8 Desert Bandits.", reward="Ouro e essência.", requirement="Oferta do quadro e equipamento adequado.", source="quests" },
		{ id="canopy", name="Guilda: Fog Cleaning", low=25, high=40, alignment="Neutro", city="Westwood Heart", npcs={"Guild Clerk","GuildClerk","Guild Member"}, repeatable=true,
			location="Quadro de Deeproot Canopy.", goal="Aceite a tarefa e derrote 6 Fog Spirits.", reward="Ouro, essência e consumíveis.", requirement="Oferta do quadro e preparo para a região.", source="quests" },
		{ id="lorra", name="Lorra / portal da Church", low=20, high=40, alignment="Neutro", city="Caldera City", npcs={"Lorra"},
			location="The Crossing, perto da ponte para Deeproot.", goal="Entregue 1 Mushroom Cap, 1 Sand Core e 1 Rot Core.", reward="Acesso ao portal de Illustris.",
			requirement="Tenha os três materiais. Entrar no portal e aderir ao covenant são etapas diferentes.", source="lorra" },
	}
	local by_id = {}
	for _, q in ipairs(entries) do by_id[q.id] = q; q.url = sources[q.source] end
	local bands = {
		{ high=4, text="Início: Yorn, Encyclopedia e tarefas de Caldera.", ids={"yorn","book","slimes","chunks"} },
		{ high=9, text="Níveis 5–9: classe base e tarefas de Caldera.", ids={"base","book","package","slimes","chunks"} },
		{ high=14, text="Níveis 10–14: treinamento, materiais e preparação da superclasse.", ids={"hunter","ingredients","package","drums","book","chunks"} },
		{ high=24, text="Níveis 15–24: superclasse e deserto conforme o seu equipamento.", ids={"super","ingredients","crylight_o","crylight_c","drums","lorra","desert"} },
		{ high=40, text="Níveis 25–40: Deeproot, quests pendentes e progressão da build.", ids={"lorra","crylight_o","crylight_c","hunter","canopy"} },
	}
	local function recommend(level, route, done)
		if not level or level > 40 then return nil, "Este guia cobre sugestões até o nível 40." end
		for _, band in ipairs(bands) do
			if level <= band.high then
				for _, id in ipairs(band.ids) do
					local q = by_id[id]
					if level >= q.low and level <= q.high and not done[id]
						and (q.alignment == "Neutro" or route == "Todas" or q.alignment == route) then return q, band.text end
				end
				return nil, band.text .. " Confira o checklist ou outras quests no catálogo."
			end
		end
	end
	local function parse_level(value)
		local n = tonumber(value)
		return n and n == math.floor(n) and n >= 1 and n <= 1000 and n or nil
	end
	local function text_level(text)
		text = tostring(text or ""):gsub("<[^>]*>", ""):lower()
		return parse_level(text:match("^%s*level%s*:%s*(%d+)%s*$") or text:match("^%s*lvl%.?%s*:?%s*(%d+)%s*$"))
	end
	local function read_level(player, labels)
		local char = player.Character
		local function path(root, ...)
			for _, name in ipairs({...}) do root = root and root:FindFirstChild(name) end
			return root
		end
		for _, root in pairs({char, player}) do
			local n = parse_level(root:GetAttribute("Level"))
			if n then return n, "atributo Level" end
		end
		local paths = {{char,"Status","Level"},{player,"Status","Level"},{player,"leaderstats","Level"},{player,"Level"}}
		for _, p in ipairs(paths) do
			local object = path(p[1], p[2], p[3])
			if object and (object:IsA("IntValue") or object:IsA("NumberValue") or object:IsA("StringValue")) then
				local n = parse_level(object.Value)
				if n then return n, object:GetFullName() end
			end
		end
		local found, label_source
		for object in pairs(labels or {}) do
			if object.Parent then
				local n = text_level(object.Text)
				if n then
					if found and found ~= n then return nil, "mais de um nível na interface; use o nível manual" end
					found, label_source = n, object:GetFullName()
				end
			end
		end
		return found, label_source or "nível automático não localizado"
	end
	return { entries=entries, by_id=by_id, recommend=recommend, read_level=read_level, text_level=text_level }
end

local function create_quest_guide(app, flags, window, dep)
	local logic = create_quest_catalog()
	local guide = { done={}, labels={}, connections={}, generation=0, travel_generation=0, stopped=false }
	local tab = window:AddTab("Quests")
	local card = dep.group(tab, "Orientação por nível")
	local detail_card = dep.group(tab, "Objetivo selecionado", "Right")
	local summary = card:AddLabel("Lendo nível...", {Height=145})
	dep.toggle(card, "QuestAutoLevel", "Usar nível detectado", true)
	dep.slider(card, "QuestManualLevel", "Nível manual / reserva", 1, 100, 1, 0)
	dep.select_value(card, "QuestRoute", "Rota desejada", {"Neutro","Ordeiro","Caótico","Todas"}, "Neutro")
	local names, by_name = {}, {}
	for _, q in ipairs(logic.entries) do table.insert(names,q.name); by_name[q.name]=q end
	local selected_control = dep.select_value(card, "QuestSelection", "Quest ou etapa", names, names[1])
	local details = detail_card:AddLabel("", {Height=420})
	local navigation = dep.group(tab, "Direção e deslocamento")
	dep.toggle(navigation, "QuestWaypoint", "Mostrar marcador da quest", false)
	dep.toggle(navigation, "QuestTalkOnArrival", "Abrir conversa ao chegar", false)
	local location_status = navigation:AddLabel("Escolha uma quest e mostre o marcador.", {Height=85})
	detail_card:AddLabel("Níveis sugeridos são orientação. Aceite e entregue pelo diálogo do jogo. O checklist registra sua confirmação nesta sessão, não o progresso do servidor.", {Height=110})
	local function selected() return by_name[flags.QuestSelection] or logic.entries[1] end
	local function remember_label(object)
		if not object.Parent or not object:IsA("TextLabel") or object:IsDescendantOf(app.ScreenGui) then return end
		if not object:FindFirstAncestorWhichIsA("ScreenGui") then return end
		local name = object.Name:lower()
		if name:find("level",1,true) or name:find("lvl",1,true) or logic.text_level(object.Text) then guide.labels[object]=true end
	end
	local function bind_gui()
		local gui = dep.player:FindFirstChild("PlayerGui")
		if gui == guide.gui then return end
		guide.generation=guide.generation+1
		for _, conn in ipairs(guide.connections) do conn:Disconnect() end
		guide.connections,guide.labels,guide.gui={},{},gui
		if not gui then return end
		local generation=guide.generation
		table.insert(guide.connections,app:Connect(gui.DescendantAdded,function(object)
			task.delay(0.2,function()
				if not guide.stopped and generation==guide.generation then app:Run("nível da quest",remember_label,object) end
			end)
		end))
		table.insert(guide.connections,app:Connect(gui.DescendantRemoving,function(object) guide.labels[object]=nil end))
		task.spawn(function()
			app:Run("índice de nível",function()
				for i,object in ipairs(gui:GetDescendants()) do
					if guide.stopped or generation~=guide.generation then return end
					remember_label(object)
					if i%200==0 then task.wait() end
				end
			end)
		end)
	end
	local function normalize(name) return tostring(name):lower():gsub("[^%w]", "") end
	local function resolve(q)
		local city=destinations.Cities[q.city]
		local folder=workspace:FindFirstChild("NPCs")
		local best,best_distance
		if folder then
			for _,npc in ipairs(folder:GetChildren()) do
				for _,name in ipairs(q.npcs) do
					if normalize(npc.Name)==normalize(name) then
						local part=dep.part_of(npc)
						if part then
							local distance=city and (part.Position-city).Magnitude or 0
							-- Generic guild NPC names must also match the requested region.
							if (not q.repeatable or distance<1200) and (not best_distance or distance<best_distance) then
								best,best_distance=npc,distance
							end
						end
					end
				end
			end
		end
		if best then return dep.part_of(best).Position,best,"NPC carregado: "..best.Name end
		return city,nil,"Referência aproximada da região: "..q.city..". "..q.location
	end
	local function clear_marker()
		if guide.marker then guide.marker:Destroy(); guide.marker=nil; guide.marker_text=nil end
		if guide.anchor then guide.anchor:Destroy(); guide.anchor=nil end
	end
	local function update_marker(q)
		if not flags.QuestWaypoint then clear_marker(); return end
		local position,npc,where=resolve(q)
		if not position then clear_marker(); location_status:SetText("Destino indisponível. "..q.location); return end
		local _,hum,root=dep.parts()
		if not hum or hum.Health<=0 or not root then clear_marker(); return end
		if not guide.anchor then
			local anchor=Instance.new("Part")
			anchor.Name="ZyonQuestWaypoint"; anchor.Anchored=true; anchor.CanCollide=false
			anchor.CanTouch=false; anchor.CanQuery=false; anchor.Transparency=1
			anchor.Size=Vector3.new(0.1,0.1,0.1); anchor.Parent=workspace; guide.anchor=anchor
			local marker=Instance.new("BillboardGui")
			marker.Name="QuestDirection"; marker.Adornee=anchor; marker.AlwaysOnTop=true
			marker.Size=UDim2.fromOffset(270,70); marker.StudsOffsetWorldSpace=Vector3.new(0,4,0)
			marker.Parent=app.ScreenGui; guide.marker=marker
			local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1)
			text.BackgroundTransparency=0.2; text.BackgroundColor3=Color3.fromRGB(28,30,43)
			text.TextColor3=Color3.fromRGB(255,221,105); text.TextSize=13; text.TextWrapped=true
			text.Font=Enum.Font.BuilderSansBold; text.Parent=marker; guide.marker_text=text
		end
		guide.anchor.Position=position
		local distance=math.floor((root.Position-position).Magnitude)
		guide.marker_text.Text="QUEST: "..q.name.."\n"..(npc and "NPC" or "REGIÃO APROXIMADA").." | "..distance.." studs"
		location_status:SetText(where.."\nDistância: "..distance.." studs"..(dep.in_combat() and " · movimento pausado no combate" or ""))
	end
	local function talk(npc)
		if not npc or not npc.Parent or dep.in_combat() then return false end
		local prompt=npc:FindFirstChildWhichIsA("ProximityPrompt",true)
		local _,_,root=dep.parts()
		local part=dep.part_of(npc)
		if not prompt or not prompt.Enabled or not root or not part then return false end
		if (root.Position-part.Position).Magnitude>prompt.MaxActivationDistance then return false end
		if type(fireproximityprompt)~="function" then return false end
		return pcall(fireproximityprompt,prompt)
	end
	function guide:Tick()
		if self.stopped then return end
		bind_gui()
		local level,level_source
		if flags.QuestAutoLevel then level,level_source=logic.read_level(dep.player,self.labels) end
		if not level then
			level=flags.QuestManualLevel
			level_source=flags.QuestAutoLevel and "manual: "..tostring(level_source) or "nível manual"
		end
		local suggestion,band=logic.recommend(level,flags.QuestRoute,self.done)
		self.suggestion=suggestion
		local done_count=0; for _ in pairs(self.done) do done_count=done_count+1 end
		summary:SetText("Nível: "..level.." · "..tostring(level_source).."\n"..tostring(band)
			.."\nSugestão: "..(suggestion and suggestion.name or "consulte o catálogo")
			.."\nChecklist manual: "..done_count.."/"..#logic.entries)
		local q=selected()
		details:SetText(q.name.."\nFaixa sugerida: "..q.low.."–"..q.high.." | "..q.alignment
			.."\n\nObjetivo: "..q.goal.."\n\nLocal: "..q.location.."\n\nCondições: "..q.requirement
			.."\n\nRecompensa: "..q.reward.."\n\n"..(q.repeatable and "Tarefa repetível; depende da oferta do quadro." or "Etapa de progressão.")
			.."\nChecklist: "..(self.done[q.id] and "confirmada por você" or "pendente")
			.."\nFonte comunitária consultada em 22/10/2026; use Copiar fonte.")
		app.ModuleStatus.QuestGuide="Lv "..level.." · "..q.name.." · "..tostring(level_source)
		update_marker(q)
	end
	dep.button(card,"Selecionar sugestão do meu nível",function()
		guide:Tick()
		if guide.suggestion then selected_control:SetValue(guide.suggestion.name); guide:Tick()
		else dep.notice("Nenhuma sugestão pendente para esta faixa e rota. Consulte o catálogo.") end
	end)
	dep.button(detail_card,"Marcar etapa feita (manual)",function()
		guide.done[selected().id]=true; guide:Tick()
	end)
	dep.button(detail_card,"Desmarcar etapa selecionada",function() guide.done[selected().id]=nil; guide:Tick() end)
	dep.button(detail_card,"Limpar checklist desta sessão",function() guide.done={}; guide:Tick() end)
	dep.button(detail_card,"Copiar fonte selecionada",function()
		local url=selected().url
		if type(setclipboard)=="function" and pcall(setclipboard,url) then dep.notice("Fonte copiada.")
		else dep.notice(url) end
	end)
	dep.button(navigation,"Ir ao destino selecionado",function()
		if dep.in_combat() then dep.notice("Aguarde sair do combate."); return end
		if app.DropFarm.Active or app.LevelFarm.Active or flags.AutoFarmItems or flags.EssenceFarm then
			dep.notice("Pause os farms antes de iniciar o percurso da quest."); return
		end
		local q=selected()
		local position,npc,where=resolve(q)
		if not position then dep.notice("Sem destino disponível. "..q.location); return end
		guide.travel_generation=guide.travel_generation+1
		local generation=guide.travel_generation
		local character=dep.player.Character
		local target=position+Vector3.new(0,2,0)
		local ok,reason=dep.travel(target,function()
			if guide.stopped or generation~=guide.travel_generation or dep.player.Character~=character or selected()~=q then return end
			if flags.QuestTalkOnArrival and npc then
				dep.notice(talk(npc) and "Interação enviada. Escolha a opção da quest no jogo." or "Aproxime-se e interaja com o NPC pelo jogo.")
			else dep.notice(npc and "Chegou ao NPC; use o diálogo do jogo." or "Chegou à referência da região; procure o NPC indicado.") end
		end)
		dep.notice(ok and where or tostring(reason))
	end)
	dep.button(navigation,"Cancelar percurso da quest",function()
		guide.travel_generation=guide.travel_generation+1
		dep.stop_movement()
	end)
	function guide:Stop()
		self.stopped=true; self.generation=self.generation+1; self.travel_generation=self.travel_generation+1
		for _,conn in ipairs(self.connections) do conn:Disconnect() end
		self.connections={}; self.labels={}; clear_marker()
	end
	return guide
end

return (function()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	local env = (type(getgenv) == "function" and getgenv()) or _G
	if env.ZyonArcane then
		pcall(function()
			env.ZyonArcane:Unload()
		end)
	end
	local app = create_hud()
	env.ZyonArcane = app
	local players = game:GetService("Players")
	local player = players.LocalPlayer
	local storage = game:GetService("ReplicatedStorage")
	local run = game:GetService("RunService")
	local input = game:GetService("UserInputService")
	local tweens = game:GetService("TweenService")
	local pathfinding = game:GetService("PathfindingService")
	local lighting = game:GetService("Lighting")
	local flags = {}
	app.Flags = flags
	local alive = true
	local window = app:CreateWindow()
	local jobs = {}
	app.Jobs = jobs
	local function group(tab, title, side)
		return tab:AddGroup(title, side or "Left")
	end
	local function toggle(card, key, title, default)
		flags[key] = default == true
		return card:AddToggle(key, {
			Text = title,
			Default = flags[key],
			Callback = function(value)
				flags[key] = value
			end,
		})
	end
	local function slider(card, key, title, min, max, default, rounding, suffix)
		flags[key] = default
		return card:AddSlider(key, {
			Text = title,
			Min = min,
			Max = max,
			Default = default,
			Rounding = rounding or 0,
			Suffix = suffix or "",
			Callback = function(value)
				flags[key] = value
			end,
		})
	end
	local function select_value(card, key, title, values, default)
		flags[key] = default or values[1]
		return card:AddDropdown(key, {
			Text = title,
			Values = values,
			Default = flags[key],
			Callback = function(value)
				flags[key] = value
			end,
		})
	end
	local speed_controls = {}
	local function speed_slider(card, key)
		flags.TweenSpeed = flags.TweenSpeed or 28
		local control = card:AddSlider(key, {
			Text = "Velocidade de deslocamento",
			Min = 10,
			Max = 500,
			Default = flags.TweenSpeed,
			Rounding = 0,
			Suffix = " studs/s",
			Callback = function(value)
				flags.TweenSpeed = value
				for _, other in ipairs(speed_controls) do
					if other.Key ~= key then
						other:SetValue(value, true)
					end
				end
			end,
		})
		table.insert(speed_controls, control)
		return control
	end
	local function textbox(card, key, title, default)
		flags[key] = default or ""
		return card:AddTextbox(key, {
			Text = title,
			Default = flags[key],
			Callback = function(value)
				flags[key] = value
			end,
		})
	end
	local function button(card, text, callback)
		return card:AddButton(text, { Callback = callback })
	end
	local function notice(text)
		app:Notify({ Title = "Zyon / Arcane", Content = text })
	end
	local function connect(signal, callback)
		return app:Connect(signal, function(...)
			if alive then
				callback(...)
			end
		end)
	end
	local function find(root, ...)
		for _, name in ipairs({ ... }) do
			root = root and root:FindFirstChild(name)
		end
		return root
	end
	local function parts()
		local char = player.Character
		return char, char and char:FindFirstChildOfClass("Humanoid"), find(char, "HumanoidRootPart")
	end
	local function part_of(obj)
		if not obj then
			return nil
		end
		if obj:IsA("BasePart") then
			return obj
		end
		return obj:FindFirstChild("ClickPart")
			or obj:FindFirstChild("Handle")
			or obj:FindFirstChild("HumanoidRootPart")
			or obj:FindFirstChildWhichIsA("BasePart", true)
	end
	local function fight_id()
		local value = find(player.Character, "FightInProgress")
		return value and value.Value ~= nil and value.Value ~= "" and value.Value ~= false and value.Value or nil
	end
	local function in_combat()
		if fight_id() then
			return true
		end
		local combat = find(player, "PlayerGui", "Combat")
		if combat and combat.Enabled then
			for _, name in ipairs({ "ActionBG", "Deciding", "Go" }) do
				local child = combat:FindFirstChild(name)
				if child and child.Visible then
					return true
				end
			end
		end
		return false
	end
	local function remote(...)
		return find(storage, "Remotes", ...)
	end
	local visual_dodge = create_visual_dodge(app, flags, player)
	local integration = create_arcane_integration(app, flags, player)
	app.Integration = integration
	local constants
	local function load_constants()
		if constants then
			return constants
		end
		local module = storage:FindFirstChild("Constants")
		if module then
			local ok, value = pcall(require, module)
			if ok and type(value) == "table" then
				constants = value
			end
		end
		return constants
	end
	local known_moves = { Strike = true }
	local skill_control
	local function refresh_skills()
		known_moves = { Strike = true }
		local containers = {
			find(player, "PlayerGui", "Combat", "ActionBG", "AttacksPage", "Attack", "ScrollingFrame"),
			find(player, "PlayerGui", "SkillDisplay", "Main", "Container", "Body", "Container", "Skills"),
		}
		for _, container in pairs(containers) do
			for _, child in ipairs(container:GetChildren()) do
				if
					child:IsA("GuiObject")
					and child.Name ~= "Template"
					and child.Name ~= "Example"
					and not child.Name:find("Layout")
				then
					known_moves[child.Name] = true
				end
			end
		end
		local list = {}
		for name in pairs(known_moves) do
			table.insert(list, name)
		end
		table.sort(list)
		if skill_control then
			skill_control:SetValues(list)
		end
		app.SkillChoices = list
		return list
	end
	local function combat_ui_ready()
		local combat = find(player, "PlayerGui", "Combat")
		local action = combat and combat:FindFirstChild("ActionBG")
		local reason = "pronta"
		if not combat then
			reason = "Combat ausente no PlayerGui"
		elseif not action then
			reason = "Combat.ActionBG ausente"
		else
			local node = action
			while node and node ~= player do
				if node:IsA("ScreenGui") and not node.Enabled then
					reason = node.Name .. ".Enabled=false"
					break
				elseif node:IsA("GuiObject") and not node.Visible then
					reason = node.Name .. ".Visible=false"
					break
				end
				node = node.Parent
			end
		end
		app.ModuleStatus.CombatUI = reason
		return reason == "pronta", action
	end
	local turn = { open = false, serial = 0, submitted = -1, last_sent = -math.huge,
		attempts = 0, gui_visible = false, opened_at = 0 }
	local bound_events = setmetatable({}, { __mode = "k" })
	local drop_farm, level_farm
	local function open_turn()
		if not turn.open then
			turn.open = true
			turn.serial += 1
			turn.attempts = 0
			turn.opened_at = os.clock()
		end
	end
	local function close_turn()
		turn.open = false
	end
	local function bind_combat()
		for _, name in ipairs({ "StartAction", "StartSummonedAction", "EndAction", "EndFight", "RefightBoss" }) do
			local event = remote("Fight", name)
			if event and event:IsA("RemoteEvent") and not bound_events[event] then
				bound_events[event] = true
				if name == "RefightBoss" then
					connect(event.OnClientEvent, function(action, details)
						if action == "OpenGui" and drop_farm and drop_farm:Refight(event, details) then
							return
						end
						if
							flags.AutoRefight
							and action == "OpenGui"
							and type(details) == "table"
							and details.BattleID
						then
							task.delay(0.5, function()
								if alive and flags.AutoRefight and event.Parent then
									app:Run("revanche", function()
										event:FireServer(details.BattleID, "Accept")
									end)
								end
							end)
						end
					end)
				elseif name == "StartAction" or name == "StartSummonedAction" then
					connect(event.OnClientEvent, open_turn)
				else
					connect(event.OnClientEvent, function()
						close_turn()
						if name == "EndFight" and drop_farm then
							drop_farm:EndFight()
						end
					end)
				end
			end
		end
	end
	local function gui_turn()
		local battle = fight_id()
		local visible, action = combat_ui_ready()
		if battle ~= turn.battle or action ~= turn.gui_instance then
			close_turn()
			turn.serial += 1
			turn.battle, turn.gui_instance = battle, action
			turn.submitted, turn.attempts, turn.gui_visible = -1, 0, false
		end
		if visible and not turn.gui_visible then
			open_turn()
			turn.opened_at = os.clock()
		end
		if not visible and turn.gui_visible then close_turn() end
		turn.gui_visible = visible
		return visible
	end
	local function valid_move(name, energy, char)
		if name == "Strike" then
			return true
		end
		if not known_moves[name] then
			return false
		end
		local ui = find(player, "PlayerGui", "Combat", "ActionBG", "AttacksPage", "Attack", "ScrollingFrame", name)
		if ui and (ui.Visible == false or (ui:FindFirstChild("CD") and ui.CD.Visible)) then
			return false
		end
		local data = load_constants()
		local skill = data and data.Skills and data.Skills[name]
		if skill then
			if energy < (tonumber(skill.Cost) or 0) then
				return false
			end
			if type(skill.Requirement) == "table" then
				local weapon = find(char, "WeaponClass")
				if not weapon or not table.find(skill.Requirement, weapon.Value) then
					return false
				end
			end
		end
		return true
	end
	local function attack()
		if app.DialogueActive then
			app.ModuleStatus.AutoAttack = "pausado durante diálogo"
			return
		end
		if not flags.AutoAttack or not fight_id() then
			return
		end
		if not gui_turn() then
			app.ModuleStatus.AutoAttack = "aguardando menu: " .. tostring(app.ModuleStatus.CombatUI)
			return
		end
		if os.clock() - turn.opened_at < 0.65 then
			app.ModuleStatus.AutoAttack = "menu visível; aguardando início do turno"
			return
		end
		if
			not turn.open
			or turn.submitted == turn.serial
			or turn.attempts >= 2
			or os.clock() - turn.last_sent < flags.AttackInterval
		then
			return
		end
		local char = player.Character
		local turn_remote = storage:FindFirstChild("PlayerTurnInput")
		local team_remote = remote("Data", "GetOtherTeam")
		if not turn_remote or not team_remote then
			app.ModuleStatus.AutoAttack = "PlayerTurnInput/GetOtherTeam indisponível"
			return
		end
		local serial = turn.serial
		local battle = fight_id()
		local enemies = team_remote:InvokeServer(battle)
		if not alive or not flags.AutoAttack or fight_id() ~= battle or serial ~= turn.serial
			or app.DialogueActive or not turn.open or not combat_ui_ready() then
			return
		end
		if type(enemies) ~= "table" then
			app.ModuleStatus.AutoAttack = "equipe inimiga não retornada"
			return
		end
		if drop_farm and not drop_farm:AllowsAttack(enemies, battle) then
			app.ModuleStatus.AutoAttack = "farm de boss: inimigo diferente do selecionado"
			return
		end
		local target
		local taunt = find(char, "Effects", "Taunted", "Applier")
		if taunt and typeof(taunt.Value) == "Instance" and table.find(enemies, taunt.Value) then
			target = taunt.Value
		end
		if not target then
			for _, enemy in ipairs(enemies) do
				if typeof(enemy) == "Instance" and enemy.Parent then
					local hum = enemy:FindFirstChildOfClass("Humanoid")
					if not hum or hum.Health > 0 then
						target = enemy
						break
					end
				end
			end
		end
		if not target then
			return
		end
		local energy_value = find(char, "Status", "Energy")
		local energy = energy_value and tonumber(energy_value.Value) or 0
		local priority = {}
		for name in flags.PriorityMoves:gmatch("[^,]+") do
			name = name:match("^%s*(.-)%s*$")
			if name ~= "" then
				table.insert(priority, name)
			end
		end
		table.insert(priority, flags.PreferredMove)
		table.insert(priority, "Strike")
		local chosen = "Strike"
		for _, name in ipairs(priority) do
			if valid_move(name, energy, char) then
				chosen = name
				break
			end
		end
		if turn.attempts > 0 then
			chosen = "Strike"
		end
		local data = load_constants()
		local skill = data and data.Skills and data.Skills[chosen]
		turn.attempts += 1
		turn.last_sent = os.clock()
		local result =
			turn_remote:InvokeServer("Attack", chosen, { Attacking = skill and skill.SelfTarget and char or target })
		if result ~= false then
			turn.submitted = serial
			app.ModuleStatus.AutoAttack = "ação enviada: " .. chosen .. " (retorno não confirma execução)"
		else
			app.ModuleStatus.AutoAttack = "ação recusada; aguardando próxima tentativa"
		end
	end
	local move_generation = 0
	local current_tween
	local moving = false
	local move_noclip = false
	local collision_original = setmetatable({}, { __mode = "k" })
	local function update_noclip()
		local char, hum = parts()
		local enabled = alive and char and hum and hum.Health > 0 and (flags.Noclip or (moving and move_noclip))
		for part, value in pairs(collision_original) do
			if not enabled or not part:IsDescendantOf(char) then
				pcall(function()
					part.CanCollide = value
				end)
				collision_original[part] = nil
			end
		end
		if enabled then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					if collision_original[part] == nil then
						collision_original[part] = part.CanCollide
					end
					part.CanCollide = false
				end
			end
		end
	end
	connect(run.Stepped, update_noclip)
	local function stop_movement()
		move_generation += 1
		moving = false
		move_noclip = false
		local tween = current_tween
		current_tween = nil
		if tween then
			tween:Cancel()
		end
		update_noclip()
		local _, hum, root = parts()
		if hum then
			hum:Move(Vector3.zero)
		end
		if root then
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end
	local function travel(target, callback)
		if app.DialogueActive then return false, "deslocamento pausado durante diálogo" end
		if in_combat() then
			return false, "deslocamento bloqueado durante combate"
		end
		local char, hum, root = parts()
		if not char or not hum or not root or hum.Health <= 0 then
			return false, "personagem indisponível"
		end
		stop_movement()
		moving = true
		move_noclip = flags.TravelNoclip == true
		local generation = move_generation
		update_noclip()
		local function complete(ok)
			if generation ~= move_generation then
				return
			end
			moving = false
			move_noclip = false
			current_tween = nil
			update_noclip()
			if ok and callback and alive then
				app:Run("chegada", callback)
			end
		end
		if flags.TravelNoclip or flags.MovementMode == "Tween" then
			local cf = typeof(target) == "CFrame" and target or CFrame.new(target)
			local duration = math.max(0.15, (cf.Position - root.Position).Magnitude / flags.TweenSpeed)
			local tween = tweens:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = cf })
			current_tween = tween
			local conn
			conn = tween.Completed:Connect(function(state)
				conn:Disconnect()
				complete(state == Enum.PlaybackState.Completed)
			end)
			table.insert(app.Connections, conn)
			tween:Play()
		else
			local position = typeof(target) == "CFrame" and target.Position or target
			task.spawn(function()
				local ok, err = pcall(function()
					local path = pathfinding:CreatePath({
						AgentRadius = 2,
						AgentHeight = 5,
						AgentCanJump = true,
						WaypointSpacing = 5,
					})
					local computed = pcall(function()
						path:ComputeAsync(root.Position, position)
					end)
					local points = computed and path.Status == Enum.PathStatus.Success and path:GetWaypoints()
						or { { Position = position } }
					for index, waypoint in ipairs(points) do
						if
							index > 200
							or not alive
							or generation ~= move_generation
							or in_combat()
							or not root.Parent
						then
							complete(false)
							return
						end
						if waypoint.Action == Enum.PathWaypointAction.Jump then
							hum.Jump = true
						end
						hum:MoveTo(waypoint.Position)
						local deadline = os.clock()
							+ math.clamp(
								(root.Position - waypoint.Position).Magnitude / math.max(1, hum.WalkSpeed) + 2,
								2,
								15
							)
						while (root.Position - waypoint.Position).Magnitude > 4 do
							if not alive or generation ~= move_generation or in_combat() or os.clock() > deadline then
								complete(false)
								return
							end
							task.wait(0.05)
						end
					end
					complete((root.Position - position).Magnitude < 8)
				end)
				if not ok then
					app:RecordError("caminho", err)
					complete(false)
				end
			end)
		end
		return true
	end
	local item_attempts = setmetatable({}, { __mode = "k" })
	local known_items = {}
	local item_control
	local function refresh_items(manual)
		local folder = workspace:FindFirstChild("SpawnedItems")
		local changed = false
		local count = 0
		if folder then
			for _, item in ipairs(folder:GetChildren()) do
				if part_of(item) and item:FindFirstChildWhichIsA("ClickDetector", true) then
					count += 1
					if not known_items[item.Name] then
						known_items[item.Name] = true
						changed = true
					end
				end
			end
		end
		local names = {}
		for name in pairs(known_items) do
			table.insert(names, name)
		end
		table.sort(names)
		if item_control and (changed or manual == true) then
			item_control:SetValues(names)
		end
		app.ModuleStatus.ItemCatalog = tostring(#names) .. " tipos conhecidos / " .. count .. " itens carregados"
		if manual == true then
			notice(
				"Lista atualizada: "
					.. #names
					.. " tipos conhecidos nesta sessão. Itens não carregados pelo jogo ainda não aparecem."
			)
		end
		return names
	end
	local function item_selected(item)
		if flags.ItemSelectionMode == "Selecionados" and not table.find(flags.SelectedItems or {}, item.Name) then
			return false
		end
		local filter = flags.ItemFilter or ""
		return filter == "" or item.Name:lower():find(filter:lower(), 1, true) ~= nil
	end
	local function item_farm()
		if app.DialogueActive or not flags.AutoFarmItems or moving or in_combat() then
			return
		end
		if type(fireclickdetector) ~= "function" then
			app.ModuleStatus.ItemFarm = "fireclickdetector indisponível"
			return
		end
		local _, _, root = parts()
		local folder = workspace:FindFirstChild("SpawnedItems")
		if not root or not folder then
			return
		end
		local best, best_part, best_distance = nil, nil, flags.AllLoadedItems and math.huge or flags.ItemRange
		for _, item in ipairs(folder:GetChildren()) do
			local detector = item:FindFirstChildWhichIsA("ClickDetector", true)
			local detector_part = detector and detector.Parent and detector.Parent:IsA("BasePart") and detector.Parent
			local part = detector_part or part_of(item)
			local selected = item_selected(item)
			if
				part
				and detector
				and selected
				and os.clock() - (item_attempts[item] or -math.huge) > flags.PickupRetry
			then
				local distance = (part.Position - root.Position).Magnitude
				if distance < best_distance then
					best = item
					best_part = part
					best_distance = distance
				end
			end
		end
		if best then
			item_attempts[best] = os.clock()
			travel(best_part.CFrame + Vector3.new(0, 2, 0), function()
				if app.DialogueActive or not flags.AutoFarmItems or in_combat() or best.Parent ~= folder or not item_selected(best) then
					return
				end
				local detector = best:FindFirstChildWhichIsA("ClickDetector", true)
				local detector_part = detector and detector.Parent and detector.Parent:IsA("BasePart") and detector.Parent or part_of(best)
				local _, _, now_root = parts()
				if not detector or not detector_part or not now_root then
					app.ModuleStatus.ItemFarm = "detector do item indisponível: " .. best.Name
					return
				end
				local distance = (detector_part.Position - now_root.Position).Magnitude
				if distance > math.max(8, detector.MaxActivationDistance) then
					app.ModuleStatus.ItemFarm = "fora do alcance do detector: " .. best.Name
					return
				end
				for attempt = 1, 3 do
					if app.DialogueActive or not flags.AutoFarmItems or in_combat() or best.Parent ~= folder then
						break
					end
					local ok, err = pcall(fireclickdetector, detector, distance)
					if not ok then
						app:RecordError("coleta " .. best.Name, err)
						break
					end
					task.wait(0.15)
					if best.Parent ~= folder then
						item_attempts[best] = nil
						app.ModuleStatus.ItemFarm = "coletado: " .. best.Name
						return
					end
				end
				app.ModuleStatus.ItemFarm = "clique enviado; item ainda no mapa: " .. best.Name
			end)
		end
	end
	local overlay_root = Instance.new("Folder")
	overlay_root.Name = "ZyonArcaneESP"
	overlay_root.Parent = app.ScreenGui
	local overlays = {}
	local function overlay(obj, kind, name, part)
		local entry = overlays[obj]
		if not entry then
			local gui = Instance.new("BillboardGui")
			gui.Size = UDim2.fromOffset(215, 42)
			gui.AlwaysOnTop = true
			gui.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
			gui.Adornee = part
			gui.Parent = overlay_root
			local text = Instance.new("TextLabel")
			text.Size = UDim2.fromScale(1, 1)
			text.BackgroundTransparency = 1
			text.Font = Enum.Font.GothamMedium
			text.TextSize = 12
			text.TextStrokeTransparency = 0.25
			text.Parent = gui
			entry = { gui = gui, text = text }
			overlays[obj] = entry
		end
		entry.seen = true
		entry.gui.Adornee = part
		local _, _, root = parts()
		local distance = root and (part.Position - root.Position).Magnitude or math.huge
		entry.gui.Enabled = flags["ESP" .. kind] and distance <= flags.ESPDistance
		entry.text.TextColor3 = kind == "Items" and Color3.fromRGB(129, 231, 175)
			or kind == "Players" and Color3.fromRGB(168, 198, 255)
			or Color3.fromRGB(234, 192, 121)
		entry.text.Text = name .. (flags.ShowDistance and string.format("\n%d studs", distance) or "")
	end
	local function refresh_esp()
		for _, entry in pairs(overlays) do
			entry.seen = false
		end
		if flags.ESPItems then
			local folder = workspace:FindFirstChild("SpawnedItems")
			if folder then
				for _, obj in ipairs(folder:GetChildren()) do
					local part = part_of(obj)
					if part then
						overlay(obj, "Items", obj.Name, part)
					end
				end
			end
		end
		if flags.ESPPlayers then
			for _, other in ipairs(players:GetPlayers()) do
				if other ~= player and other.Character then
					local part = part_of(other.Character)
					if part then
						overlay(other.Character, "Players", other.DisplayName, part)
					end
				end
			end
		end
		if flags.ESPMerchants then
			local candidates =
				{ find(workspace, "Mechanical", "Buyables"), find(workspace, "NPCs", "TundraGate", "Merchants") }
			for _, folder in pairs(candidates) do
				for _, obj in ipairs(folder:GetChildren()) do
					local part = part_of(obj)
					if part then
						overlay(obj, "Merchants", obj.Name, part)
					end
				end
			end
			for _, name in ipairs({ "Merchant", "Merchant1" }) do
				local obj = find(workspace, "NPCs", name)
				local part = part_of(obj)
				if part then
					overlay(obj, "Merchants", name, part)
				end
			end
		end
		for obj, entry in pairs(overlays) do
			if not entry.seen or not obj.Parent then
				entry.gui:Destroy()
				overlays[obj] = nil
			end
		end
	end
	local original_humanoid = setmetatable({}, { __mode = "k" })
	local original_lighting = {}
	local function update_character()
		local _, hum = parts()
		if hum and not app.DialogueActive then
			local before = original_humanoid[hum]
			if (flags.SpeedEnabled or flags.JumpEnabled) and not before then
				before = { WalkSpeed = hum.WalkSpeed, JumpPower = hum.JumpPower, JumpHeight = hum.JumpHeight }
				original_humanoid[hum] = before
			end
			if before then
				hum.WalkSpeed = flags.SpeedEnabled and flags.WalkSpeed or before.WalkSpeed
				if flags.JumpEnabled then
					if hum.UseJumpPower then
						hum.JumpPower = flags.JumpPower
					else
						hum.JumpHeight = flags.JumpPower ^ 2 / (2 * math.max(1, workspace.Gravity))
					end
				else
					hum.JumpPower = before.JumpPower
					hum.JumpHeight = before.JumpHeight
				end
				if not flags.SpeedEnabled and not flags.JumpEnabled then
					original_humanoid[hum] = nil
				end
			end
		end
		for key, value in pairs({ Brightness = 2, ClockTime = 14, GlobalShadows = false }) do
			if flags.Fullbright then
				if original_lighting[key] == nil then
					original_lighting[key] = lighting[key]
				end
				lighting[key] = value
			elseif original_lighting[key] ~= nil then
				lighting[key] = original_lighting[key]
				original_lighting[key] = nil
			end
		end
	end
	connect(input.JumpRequest, function()
		if flags.InfiniteJump and not app.Open and not in_combat() and not input:GetFocusedTextBox() then
			local _, hum = parts()
			if hum and hum.Health > 0 then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)
	local function amount(text)
		if not text then
			return nil
		end
		local cleaned = tostring(text):gsub(",", ""):gsub("%s", "")
		local value = tonumber(cleaned:match("[%d%.]+"))
		if not value then
			return nil
		end
		if cleaned:lower():find("k", 1, true) then
			value *= 1000
		elseif cleaned:lower():find("m", 1, true) then
			value *= 1000000
		end
		return value
	end
	local function essence()
		local label = find(player, "PlayerGui", "HUD", "Holder", "Currency", "Container", "Crystals", "Amount")
			or find(player, "PlayerGui", "HUD", "HolderOLD", "Essence")
		return label and amount(label.Text) or nil
	end
	local soul_marker
	local soul_direction = 1
	local soul_move_at = 0
	local function essence_farm()
		if not flags.EssenceFarm then
			return
		end
		local value = essence()
		if not value then
			app.ModuleStatus.EssenceFarm = "contador de essência indisponível; farm pausado"
			return
		end
		if value >= flags.EssenceGoal then
			app.Options.EssenceFarm:SetValue(false)
			stop_movement()
			notice("Meta de essência atingida. Farm pausado; nenhum reset foi realizado.")
			return
		end
		if not soul_marker then
			app.ModuleStatus.EssenceFarm = "defina primeiro o ponto de encontro"
			return
		end
		if in_combat() or moving then
			return
		end
		local _, hum, root = parts()
		if not root or not hum or hum.Health <= 0 then
			return
		end
		if (root.Position - soul_marker).Magnitude > 60 then
			travel(soul_marker)
			return
		end
		if os.clock() - soul_move_at > 3 then
			soul_move_at = os.clock()
			soul_direction = -soul_direction
			hum:MoveTo(soul_marker + Vector3.new(soul_direction * flags.PatrolRadius, 0, 0))
		end
		app.ModuleStatus.EssenceFarm = "essência " .. value .. " / " .. flags.EssenceGoal
	end
	local combat = window:AddTab("Combat")
	local defense = group(combat, "Defesa e QTE")
	toggle(defense, "AutoDodge", "Auto Dodge", false)
	toggle(defense, "AntiSteal", "Anti-Steal", false)
	slider(defense, "DodgeLeadMs", "Antecipação Dodge", 0, 80, 15, 0, " ms")
	slider(defense, "StealLeadMs", "Antecipação Anti-Steal", 0, 80, 15, 0, " ms")
	toggle(defense, "AutoQTE", "Auto QTE de armas", false)
	toggle(defense, "AutoThorian", "Auto Thorian QTE", false)
	slider(defense, "QTEDelay", "Espera extra", 0, 1, 0, 2, " s")
	button(defense, "Reexaminar integrações", function()
		integration.ProfileRequested = false
		integration:Discover()
		notice("Integrações reexaminadas; consulte o diagnóstico.")
	end)
	button(defense, "Buscar callbacks via getgc", function()
		integration:ScanGC()
	end)
	local attacks = group(combat, "Combate por turnos", "Right")
	toggle(attacks, "AutoAttack", "Atacar no próprio turno", false)
	skill_control = select_value(attacks, "PreferredMove", "Ataque preferido", refresh_skills(), "Strike")
	textbox(attacks, "PriorityMoves", "Prioridade · nomes separados por vírgula", "")
	slider(attacks, "AttackInterval", "Intervalo mínimo", 0.3, 5, 1, 1, " s")
	button(attacks, "Atualizar habilidades", refresh_skills)
	toggle(attacks, "AutoAcceptDrop", "Aceitar disputa de drops", false)
	toggle(attacks, "AutoRefight", "Aceitar revanche de boss", false)
	local farm = window:AddTab("Items")
	local collection = group(farm, "Coleta do mundo")
	local item_toggle = toggle(collection, "AutoFarmItems", "Auto coletar itens", false)
	item_toggle.Callback = function(value)
		if value and type(fireclickdetector) ~= "function" then
			flags.AutoFarmItems = false
			item_toggle:SetValue(false, true)
			notice("Este executor não disponibilizou fireclickdetector; coleta não ativada.")
			return
		end
		flags.AutoFarmItems = value
		if not value then
			stop_movement()
		end
	end
	slider(collection, "ItemRange", "Alcance de busca", 25, 3000, 350, 0, " studs")
	textbox(collection, "ItemFilter", "Filtrar por parte do nome", "")
	slider(collection, "PickupRetry", "Repetir tentativa após", 2, 60, 12, 0, " s")
	local filters = group(farm, "Filtro de itens", "Right")
	select_value(filters, "ItemSelectionMode", "Coletar quais itens", { "Todos", "Selecionados" }, "Todos")
	flags.SelectedItems = {}
	item_control = filters:AddDropdown("SelectedItems", {
		Text = "Itens para coletar",
		Multi = true,
		Values = refresh_items(),
		Default = {},
		Callback = function(value)
			flags.SelectedItems = value
		end,
	})
	button(filters, "Atualizar lista de itens", function()
		refresh_items(true)
	end)
	button(filters, "Selecionar todos os itens", function()
		item_control:SetValue(refresh_items())
		app.Options.ItemSelectionMode:SetValue("Selecionados")
	end)
	button(filters, "Limpar seleção de itens", function()
		item_control:SetValue({})
		app.Options.ItemSelectionMode:SetValue("Selecionados")
	end)
	toggle(filters, "AllLoadedItems", "Buscar em todo mapa carregado", true)
	local motion = group(farm, "Deslocamento", "Right")
	select_value(motion, "MovementMode", "Método", { "Caminhar", "Tween" }, "Caminhar")
	local travel_noclip_toggle = toggle(motion, "TravelNoclip", "Noclip nos deslocamentos", true)
	travel_noclip_toggle.Callback = function(value)
		flags.TravelNoclip = value
		if moving then
			stop_movement()
		end
		update_noclip()
	end
	button(motion, "Cancelar deslocamento", stop_movement)
	local souls = window:AddTab("Soul")
	local soul_card = group(souls, "Farm de essência · preparação")
	local essence_toggle = toggle(soul_card, "EssenceFarm", "Patrulhar ponto de encontro", false)
	essence_toggle.Callback = function(value)
		flags.EssenceFarm = value
		if not value then
			stop_movement()
		end
	end
	slider(soul_card, "EssenceGoal", "Meta de essência", 10, 5000, 110, 0)
	slider(soul_card, "PatrolRadius", "Raio de patrulha", 3, 30, 18, 0, " studs")
	button(soul_card, "Usar minha posição como encontro", function()
		local _, _, root = parts()
		if root then
			soul_marker = root.Position
			notice("Ponto de encontro salvo na sessão.")
		end
	end)
	local soul_info = group(souls, "Acompanhamento", "Right")
	local soul_label = soul_info:AddLabel("Essência: aguardando leitura.", { Height = 70 })
	soul_info:AddLabel(
		"A meta pausa a patrulha. A etapa de reset do personagem não é executada por este farm.",
		{ Height = 65 }
	)
	local dependencies = {
		player = player,
		group = group,
		toggle = toggle,
		slider = slider,
		select_value = select_value,
		textbox = textbox,
		button = button,
		notice = notice,
		parts = parts,
		remote = remote,
		fight_id = fight_id,
		travel = travel,
		find = find,
		part_of = part_of,
		essence = essence,
		in_combat = in_combat,
		is_moving = function()
			return moving
		end,
		stop_movement = stop_movement,
		get_marker = function()
			return soul_marker
		end,
		set_marker = function(value)
			soul_marker = value
		end,
		speed_slider = speed_slider,
	}
	drop_farm = create_drop_farm(app, flags, window, dependencies)
	app.DropFarm = drop_farm
	app.OnDropOffer = function(source, name)
		drop_farm:Offer(source, name)
	end
	level_farm = create_level_farm(app, flags, souls, dependencies)
	app.LevelFarm = level_farm
	local quest_guide = create_quest_guide(app, flags, window, dependencies)
	app.QuestGuide = quest_guide
	dependencies.stop_level = function()
		level_farm:Stop("Outro modo de farm iniciado.")
	end
	dependencies.stop_boss = function()
		drop_farm:Stop("Farm de leveling iniciado.")
	end
	button(attacks, "Auto Fight · ativar combate", function()
		for _, key in ipairs({ "AutoAttack", "AutoDodge", "AntiSteal", "AutoQTE" }) do
			app.Options[key]:SetValue(true)
		end
		notice("Auto Fight ativo: atua quando o jogo inicia seu turno. Não inicia encontros por si só.")
	end)
	local travel_tab = window:AddTab("Travel")
	local destination_list = {}
	local destination_map = {}
	for category, entries in pairs(destinations) do
		for name, position in pairs(entries) do
			local title = category .. " / " .. name
			destination_map[title] = position
			table.insert(destination_list, title)
		end
	end
	table.sort(destination_list)
	local destination_card = group(travel_tab, "Mapa da referência")
	speed_slider(destination_card, "TweenSpeed")
	select_value(destination_card, "Destination", "Destino", destination_list)
	button(destination_card, "Ir ao destino", function()
		local value = destination_map[flags.Destination]
		if value then
			local ok, reason = travel(value)
			if not ok then
				notice(reason)
			end
		end
	end)
	button(destination_card, "Cancelar percurso", stop_movement)
	local npc_card = group(travel_tab, "NPCs atualmente carregados", "Right")
	local npc_map = {}
	local npc_control
	local function refresh_npcs()
		npc_map = {}
		local list = {}
		local folder = workspace:FindFirstChild("NPCs")
		if folder then
			for _, npc in ipairs(folder:GetChildren()) do
				if part_of(npc) then
					npc_map[npc.Name] = npc
					table.insert(list, npc.Name)
				end
			end
		end
		table.sort(list)
		if #list == 0 then
			list = { "Nenhum NPC carregado" }
		end
		if npc_control then
			npc_control:SetValues(list)
		end
		return list
	end
	npc_control = select_value(npc_card, "NPC", "NPC", refresh_npcs())
	button(npc_card, "Atualizar NPCs", refresh_npcs)
	button(npc_card, "Ir ao NPC", function()
		local part = part_of(npc_map[flags.NPC])
		if part then
			local ok, reason = travel(part.CFrame + Vector3.new(0, 3, 0))
			if not ok then
				notice(reason)
			end
		else
			notice("NPC indisponível.")
		end
	end)
	local visual = window:AddTab("Visuals")
	local esp = group(visual, "Marcadores")
	toggle(esp, "ESPItems", "ESP de itens", false)
	toggle(esp, "ESPPlayers", "ESP de jogadores", false)
	toggle(esp, "ESPMerchants", "ESP de mercadores", false)
	toggle(esp, "ShowDistance", "Mostrar distância", true)
	slider(esp, "ESPDistance", "Distância máxima", 50, 6000, 2000, 0, " studs")
	local environment_card = group(visual, "Ambiente", "Right")
	toggle(environment_card, "Fullbright", "Fullbright", false)
	local character_tab = window:AddTab("Character")
	local mobility = group(character_tab, "Movimento local")
	local noclip_toggle = toggle(mobility, "Noclip", "Noclip manual", false)
	noclip_toggle.Callback = function(value)
		flags.Noclip = value
		update_noclip()
	end
	toggle(mobility, "SpeedEnabled", "Alterar velocidade", false)
	slider(mobility, "WalkSpeed", "WalkSpeed", 8, 100, 24, 0)
	toggle(mobility, "JumpEnabled", "Alterar salto", false)
	slider(mobility, "JumpPower", "JumpPower", 20, 150, 60, 0)
	toggle(mobility, "InfiniteJump", "Salto infinito", false)
	local settings = window:AddTab("Settings")
	local cursor_settings = group(settings, "Mouse e interface", "Right")
	local free_mouse = toggle(cursor_settings, "FreeMouseClosed", "Mouse livre fora do hub", false)
	free_mouse.Callback = function(value)
		flags.FreeMouseClosed = value
		app:SetFreeMouse(value)
	end
	local config = group(settings, "Perfis e diagnóstico")
	button(config, "Salvar configuração", function()
		if type(writefile) ~= "function" then
			notice("writefile indisponível.")
			return
		end
		local saved = table.clone(flags)
		saved.DropFarmEnabled = false
		saved.AutoLevelFarm = false
		writefile("ZyonArcane-config.json", game:GetService("HttpService"):JSONEncode(saved))
		notice("Configuração salva.")
	end)
	button(config, "Carregar configuração", function()
		if type(readfile) ~= "function" then
			notice("readfile indisponível.")
			return
		end
		local values = game:GetService("HttpService"):JSONDecode(readfile("ZyonArcane-config.json"))
		if type(values.SelectedItems) == "table" then
			for _, name in ipairs(values.SelectedItems) do
				if type(name) == "string" then
					known_items[name] = true
				end
			end
			refresh_items(true)
		end
		if drop_farm then
			drop_farm:Stop("Perfil carregado; inicie o farm novamente.")
		end
		if level_farm then
			level_farm:Stop("Perfil carregado; inicie o farm novamente.")
		end
		if type(values.DropEnemy) == "string" then
			app.Options.DropEnemy:SetValue(values.DropEnemy)
		end
		for key, value in pairs(values) do
			local control = app.Options[key]
			if
				key ~= "DropFarmEnabled"
				and key ~= "AutoLevelFarm"
				and key ~= "DropEnemy"
				and key ~= "DropItem"
				and control
				and type(value) == type(control.Value)
			then
				control:SetValue(value)
			end
		end
		if type(values.DropItem) == "string" then
			app.Options.DropItem:SetValue(values.DropItem)
		end
		notice("Configuração carregada.")
	end)
	button(config, "Copiar diagnóstico", function()
		for name, job in pairs(jobs) do
			if job.busy then
				app.ModuleStatus["tarefa " .. name] = "aguardando há " .. math.floor(os.clock() - job.started) .. " s"
			end
		end
		app:Diagnostics()
	end)
	local session = group(settings, "Sessão", "Right")
	button(session, "Parar automações", function()
		drop_farm:Stop("Automações pausadas.")
		level_farm:Stop("Automações pausadas.")
		for _, key in ipairs({
			"AutoDodge",
			"AntiSteal",
			"QuestWaypoint",
			"QuestTalkOnArrival",
			"AutoQTE",
			"AutoThorian",
			"AutoAttack",
			"AutoAcceptDrop",
			"AutoRefight",
			"AutoFarmItems",
			"EssenceFarm",
			"Noclip",
			"SpeedEnabled",
			"JumpEnabled",
			"InfiniteJump",
			"Fullbright",
			"ESPItems",
			"ESPPlayers",
			"ESPMerchants",
		}) do
			app.Options[key]:SetValue(false)
		end
		stop_movement()
		update_character()
		refresh_esp()
		notice("Automações pausadas.")
	end)
	button(session, "Unload", function()
		app:Unload()
	end)
	local function job(name, interval, callback)
		jobs[name] = { interval = interval, run = callback, last = -math.huge, busy = false }
	end
	job("ataque", 0.25, attack)
	job("itens", 0.8, item_farm)
	job("catálogo de itens", 2, refresh_items)
	job("essência", 1, essence_farm)
	job("visual", 0.25, refresh_esp)
	job("personagem", 0.2, update_character)
	job("farm de drops", 0.75, function()
		drop_farm:Tick()
	end)
	job("leveling", 1, function()
		level_farm:Tick()
	end)
	job("guia de quests", 2, function() quest_guide:Tick() end)
	job("interfaces", 4, function()
		combat_ui_ready()
		bind_combat()
		refresh_skills()
		integration:Discover()
	end)
	connect(run.Heartbeat, function()
		if (in_combat() or app.DialogueActive) and moving then
			stop_movement()
		end
		local now = os.clock()
		for name, entry in pairs(jobs) do
			local paused_by_dialogue = app.DialogueActive and (
				name == "ataque" or name == "itens" or name == "essência" or name == "farm de drops"
				or (name == "leveling" and not (level_farm.Active and level_farm.Phase == "dialogue")))
			if not paused_by_dialogue and not entry.busy and now - entry.last >= entry.interval then
				entry.last = now
				entry.started = now
				entry.busy = true
				task.spawn(function()
					if alive then
						app:Run(name, entry.run)
					end
					entry.busy = false
				end)
			end
		end
		local value = essence()
		soul_label:SetText(
			"Essência: "
				.. tostring(value or "não disponível")
				.. " / "
				.. flags.EssenceGoal
				.. "\n"
				.. tostring(app.ModuleStatus.EssenceFarm or "Patrulha desligada.")
		)
	end)
	connect(player.CharacterAdded, function()
		drop_farm:Stop("Personagem reapareceu; farm interrompido.")
		level_farm:Stop("Personagem reapareceu; leveling interrompido.")
		stop_movement()
		close_turn()
		turn.submitted = -1
		turn.gui_visible = false
		turn.battle, turn.gui_instance = nil, nil
		task.delay(1, function()
			if alive then
				integration:Discover()
				refresh_skills()
			end
		end)
	end)
	app.OnUnload = function()
		quest_guide:Stop()
		drop_farm:Stop("Sessão encerrada.")
		level_farm:Stop("Sessão encerrada.")
		alive = false
		visual_dodge:Stop()
		integration:Stop()
		stop_movement()
		for hum, values in pairs(original_humanoid) do
			if hum.Parent then
				for key, value in pairs(values) do
					hum[key] = value
				end
			end
		end
		for key, value in pairs(original_lighting) do
			lighting[key] = value
		end
		overlay_root:Destroy()
		if env.ZyonArcane == app then
			env.ZyonArcane = nil
		end
	end
	app.Capabilities = {
		getgc = type(getgc) == "function",
		getupvalue = type(getupvalue) == "function",
		getupvalues = type(getupvalues) == "function",
		fireclickdetector = type(fireclickdetector) == "function",
		getcallbackvalue = type(getcallbackvalue) == "function",
		writefile = type(writefile) == "function",
		readfile = type(readfile) == "function",
	}
	app.Status = "Arcane 1.16 · teste em jogo pendente"
	app.ModuleStatus.Remotes = storage:FindFirstChild("Remotes") and "encontrado" or "não encontrado"
	app.TestAPI = {
		InCombat = in_combat,
		RefreshSkills = refresh_skills,
		Attack = attack,
		Travel = travel,
		StopMovement = stop_movement,
		Essence = essence,
		EssenceFarm = essence_farm,
		ItemFarm = item_farm,
		RefreshItems = refresh_items,
		ItemSelected = item_selected,
		RefreshESP = refresh_esp,
		UpdateNoclip = update_noclip,
		UpdateCharacter = update_character,
		OpenTurn = open_turn,
		CloseTurn = close_turn,
	}
	bind_combat()
	app:Notify({
		Title = "Zyon / Arcane 1.16",
		Content = "Painel carregado. RightCtrl/Insert abrem e fecham. Ative as funções desejadas.",
		Duration = 7,
	})
	return app
end)()
