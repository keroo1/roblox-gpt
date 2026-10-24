-- Luau | ZyonVV.lua | VV: Ultimatum | prototype 0.2
-- HUD reused from ZyonArcane; VV controller is independent. Original UI reference:
-- https://github.com/anwarlopoo/Freemium/blob/main/games/arcane_lineage.lua
-- Reference SHA256: d3291b8c9fcd004a36c1e8d6ff00bf415ecede6ac210473d91a93dadc87db8ab
-- Prototype: input automation and manually calibrated animation profiles.
local arcane_help = {
	["Reexaminar barra de Dodge"] = "Descarta a barra em cache e inicia outra busca visual. Não muda a antecipação nem carrega módulos internos. Se houver mais de uma barra compatível, nenhuma entrada será enviada.",
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
	["Velocidade de deslocamento"] = "Ajustes de transporte e caminhada automática aparecem nas áreas de deslocamento e são sincronizados entre elas.",
	["Velocidade de transporte · Tween"] = "Ajusta de 10 a 500 studs/s as próximas viagens em Tween, incluindo Noclip nos deslocamentos. O valor é compartilhado entre as abas.",
	["Velocidade de caminhada automática"] = "Ajusta de 8 a 100 studs/s os percursos e patrulhas automáticos. Restaura a velocidade anterior ao terminar e respeita mudanças de estado feitas pelo jogo. Valor compartilhado entre as abas.",
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
	["WalkSpeed"] = "Velocidade de caminhada desejada. Só é aplicada com Alterar velocidade ligado. Os percursos automáticos usam o controle de caminhada automática e restauram este valor ao terminar.",
	["Alterar salto"] = "Ativa a potência de salto configurada abaixo. Ao desligar, restaura a potência e a altura anteriores.",
	["JumpPower"] = "Potência do salto. Se o personagem usar altura em vez de potência, o script calcula a altura equivalente com a gravidade atual.",
	["Salto infinito"] = "Permite pedir outro salto no ar. Funciona com o painel fechado, fora de combate e sem uma caixa de texto selecionada.",
	["Salvar configuração"] = "Salva os valores atuais em ZyonVV-config.json, na pasta interna do executor. Uma configuração anterior com esse nome é substituída.",
	["Carregar configuração"] = "Aplica o perfil salvo, inclusive os interruptores ligados. Algumas automações podem começar imediatamente após carregar.",
	["Copiar diagnóstico"] = "Copia o estado das integrações e os erros capturados. Também tenta salvar um arquivo no executor para ajudar a investigar falhas.",
	["Parar automações"] = "Desliga as automações e os efeitos configurados, cancela o movimento e mantém o painel aberto para ajustes.",
	["Unload"] = "Encerra a sessão, restaura as alterações controladas pelo script e remove o HUD e o cursor. Execute o arquivo novamente para voltar.",
}

local arcane_english = {
	["Português"] = "Português",
	["Buscar nesta aba..."] = "Search this tab...",
	["Combate"] = "Combat", ["Coleta"] = "Items", ["Essência"] = "Essence", ["Bosses e drops"] = "Bosses & Drops",
	["Quests e roteiro"] = "Quests & Route", ["Auto Quest"] = "Auto Quest", ["Quests do quadro"] = "Quest Board",
	["Viagens"] = "Travel", ["Visuais"] = "Visuals", ["Personagem"] = "Character", ["Aparência"] = "Appearance", ["Configurações"] = "Settings",
	["Defesa e QTE"] = "Defense & QTE", ["Combate por turnos"] = "Turn-Based Combat", ["Coleta do mundo"] = "World Item Collection",
	["Filtro de itens"] = "Item Filters", ["Deslocamento"] = "Movement", ["Farm de essência · preparação"] = "Essence Farm · Setup",
	["Acompanhamento"] = "Status", ["Mapa da referência"] = "Reference Map", ["NPCs atualmente carregados"] = "Loaded NPCs",
	["Marcadores"] = "ESP Markers", ["Ambiente"] = "Environment", ["Movimento local"] = "Local Movement", ["Estilo e cores"] = "Style & Colors",
	["Seu painel"] = "Your Hub", ["Mouse e interface"] = "Mouse & Interface", ["Diálogos: recuperação"] = "Dialogue Recovery",
	["Perfis e diagnóstico"] = "Profiles & Diagnostics", ["Sessão"] = "Session", ["Idioma"] = "Language", ["English"] = "English",
	["Auto Dodge"] = "Auto Dodge", ["Anti-Steal"] = "Anti-Steal", ["Antecipação Dodge"] = "Dodge Lead",
	["Antecipação Anti-Steal"] = "Anti-Steal Lead", ["Auto QTE de armas"] = "Auto Weapon QTE", ["Auto Thorian QTE"] = "Auto Thorian QTE",
	["Espera extra"] = "Extra Delay", ["Reexaminar barra de Dodge"] = "Rescan Dodge Bar", ["Reexaminar integrações"] = "Rescan Integrations",
	["Buscar callbacks via getgc"] = "Scan Callbacks with getgc", ["Atacar no próprio turno"] = "Attack on Your Turn", ["Ataque preferido"] = "Preferred Attack",
	["Prioridade · nomes separados por vírgula"] = "Priority · comma-separated names", ["Habilidades em si mesmo · nomes por vírgula"] = "Self-target Skills · comma-separated names",
	["Reservar ao uso manual · nomes por vírgula"] = "Reserve for Manual Use · comma-separated names", ["Intervalo mínimo"] = "Minimum Interval",
	["Atualizar habilidades"] = "Refresh Skills", ["Aceitar disputa de drops"] = "Accept Item Roll", ["Aceitar revanche de boss"] = "Accept Boss Rematch",
	["Auto coletar itens"] = "Auto Collect Items", ["Alcance de busca"] = "Search Range", ["Filtrar por parte do nome"] = "Filter by Name",
	["Repetir tentativa após"] = "Retry After", ["Coletar quais itens"] = "Items to Collect", ["Itens para coletar"] = "Items to Collect",
	["Atualizar lista de itens"] = "Refresh Item List", ["Selecionar todos os itens"] = "Select All Items", ["Limpar seleção de itens"] = "Clear Item Selection",
	["Buscar em todo mapa carregado"] = "Search Entire Loaded Map", ["Velocidade de deslocamento"] = "Travel Speed", ["Método"] = "Method",
	["Noclip nos deslocamentos"] = "Noclip During Travel", ["Cancelar deslocamento"] = "Cancel Movement", ["Velocidade de transporte · Tween"] = "Tween Travel Speed",
	["Velocidade de caminhada automática"] = "Auto-Walk Speed", ["Patrulhar ponto de encontro"] = "Patrol Encounter Point", ["Meta de essência"] = "Essence Goal",
	["Raio de patrulha"] = "Patrol Radius", ["Usar minha posição como encontro"] = "Save My Position as Encounter Point", ["Destino"] = "Destination",
	["Ir ao destino"] = "Travel to Destination", ["Cancelar percurso"] = "Cancel Route", ["NPC"] = "NPC", ["Atualizar NPCs"] = "Refresh NPCs", ["Ir ao NPC"] = "Travel to NPC",
	["ESP de itens"] = "Item ESP", ["ESP de jogadores"] = "Player ESP", ["ESP de mercadores"] = "Merchant ESP", ["Mostrar distância"] = "Show Distance",
	["Distância máxima"] = "Maximum Distance", ["Fullbright"] = "Fullbright", ["Noclip manual"] = "Manual Noclip", ["Alterar velocidade"] = "Change Walk Speed",
	["WalkSpeed"] = "WalkSpeed", ["Alterar salto"] = "Change Jump", ["JumpPower"] = "JumpPower", ["Salto infinito"] = "Infinite Jump",
	["Transparência"] = "Transparency", ["Tema"] = "Theme", ["Cor de destaque (#RRGGBB)"] = "Accent Color (#RRGGBB)",
	["Cor de fundo (#RRGGBB)"] = "Background Color (#RRGGBB)", ["Restaurar aparência padrão"] = "Reset Appearance",
	["Mouse livre fora do hub"] = "Free Mouse Outside Hub", ["Registrar cliques do diálogo (F7)"] = "Record Dialogue Clicks (F7)",
	["Descarregar hub (F9)"] = "Unload Hub (F9)", ["Opção do diálogo"] = "Dialogue Option", ["Selecione uma opção"] = "Select an option",
	["Atualizar opções do diálogo"] = "Refresh Dialogue Options", ["Acionar opção selecionada"] = "Activate Selected Option", ["Sair do diálogo (F8)"] = "Exit Dialogue (F8)",
	["Salvar configuração"] = "Save Configuration", ["Carregar configuração"] = "Load Configuration", ["Copiar diagnóstico"] = "Copy Diagnostics",
	["Parar automações"] = "Stop Automations", ["Unload"] = "Unload", ["Todos"] = "All", ["Selecionados"] = "Selected",
	["Nenhum selecionado  ▾"] = "None selected  ▾", [" itens selecionados  ▾"] = " items selected  ▾", ["Fechar seleção"] = "Close Selection",
	["Opcional"] = "Optional", ["Nenhum NPC carregado"] = "No NPCs loaded", ["Nenhum"] = "None", ["Automático"] = "Automatic",
	["Caminhar"] = "Walk", ["Tween"] = "Tween", ["essência"] = "essence", ["aguardando leitura"] = "waiting for data",
	["Temas mudam o painel inteiro. O avatar e o nome vêm da conta Roblox em uso."] = "Themes change the entire hub. The avatar and name come from the active Roblox account.",
	["Transparência afeta fundos; textos e avatar continuam legíveis. Use Salvar configuração para guardar seu visual."] = "Transparency affects backgrounds; text and avatar remain readable. Save the configuration to keep your appearance.",
	["A meta pausa a patrulha. A etapa de reset do personagem não é executada por este farm."] = "The goal pauses the patrol. This farm does not reset your character.",
	["Automático usa habilidades da lista de combate e Strike como reserva. Custos e recargas são lidos da interface; o jogo valida a ação."] = "Automatic uses skills from the combat list and Strike as a fallback. Costs and cooldowns are read from the interface; the game validates each action.",
	["Mostra o nome dos itens carregados no mundo. O marcador ajuda a localizar o item, mas não confirma que ele já foi coletado."] = "Shows names of items loaded in the world. Markers help locate items but do not confirm they were collected.",
	["Mostra marcadores com o nome dos outros jogadores carregados no seu cliente. Não seleciona alvos de combate."] = "Shows markers with the names of other players loaded on your client. It does not select combat targets.",
	["Adiciona a distância em studs aos marcadores ESP. A distância é medida a partir do seu personagem."] = "Adds distance in studs to ESP markers. Distance is measured from your character.",
	["Oculta marcadores ESP além deste alcance. Reduza para deixar a tela menos cheia."] = "Hides ESP markers beyond this range. Lower it to reduce screen clutter.",
	["Ajusta iluminação, horário e sombras apenas no seu cliente para melhorar a visibilidade. Os valores anteriores são restaurados ao desligar."] = "Adjusts lighting, time, and shadows on your client to improve visibility. Previous values are restored when disabled.",
	["Desativa colisões do personagem enquanto ligado. Pode atravessar paredes e pisos; prefira o modo automático para viagens. Ao desligar, restaura cada parte ao valor anterior."] = "Disables character collisions while enabled. You can pass through walls and floors; use travel noclip for routes. Each part's previous collision setting is restored when disabled.",
	["Usa Tween sem colisões em viagens e coleta, mesmo com Caminhar selecionado. Restaura ao chegar ou cancelar, salvo com Noclip manual ligado. Alterar esta opção cancela o percurso atual."] = "Uses collision-free Tween movement for travel and item collection, even when Walk is selected. Restores collisions on arrival or cancel unless Manual Noclip is enabled. Changing this cancels the current route.",
	["Acompanha a linha branca da barra Stop e envia Space na faixa amarela. Minimize o hub e feche o chat durante o QTE. O diagnóstico mostra a detecção e o envio da entrada."] = "Tracks the white line on the Stop bar and presses Space in the yellow zone. Minimize the hub and close chat during the QTE. Diagnostics show detection and input status.",
	["Responde ao Stop da barra apenas amarela, como o Steal mostrado pelo jogo. Não inicia a habilidade Steal. Minimize o painel durante o QTE."] = "Responds to the Stop bar only when it is yellow, as in the game's Steal prompt. It does not start Steal. Minimize the hub during the QTE.",
	["Compensa o atraso de entrada. Padrão: 15 ms de antecipação adicional. Reduza se parar antes do centro; aumente um pouco se parar depois."] = "Compensates for input delay. Default: 15 ms of extra lead. Lower it if the marker stops before center; raise it slightly if it stops after center.",
	["Antecipação adicional para a barra amarela do Steal. Padrão: 15 ms; ajuste ao atraso do seu cliente."] = "Extra lead for the yellow Steal bar. Default: 15 ms; adjust for your client latency.",
	["Busca itens em SpawnedItems, vai até o alvo e tenta clicar no detector. Exige fireclickdetector e pausa durante o combate."] = "Searches SpawnedItems, travels to the target, and attempts to click its detector. Requires fireclickdetector and pauses during combat.",
	["Distância máxima, em studs, para procurar um item a partir do personagem. Um alcance maior pode gerar percursos mais longos."] = "Maximum search distance in studs from your character. A larger range can create longer routes.",
	["Seleciona uma posição da lista de cidades, bosses, treinadores e serviços. As coordenadas vieram da referência e podem mudar no jogo."] = "Selects a location from the cities, bosses, trainers, and services list. Coordinates come from a reference and may change in the game.",
	["Seleciona um NPC encontrado no mapa carregado pelo seu cliente. Um NPC distante ou ainda não carregado pode não aparecer."] = "Selects an NPC found in the map loaded on your client. Distant or not-yet-loaded NPCs may not appear.",
	["Salva os valores atuais em ZyonVV-config.json, na pasta interna do executor. Uma configuração anterior com esse nome é substituída."] = "Saves current values to ZyonVV-config.json in the executor's folder. An existing file with that name is overwritten.",
	["Aplica o perfil salvo, inclusive os interruptores ligados. Algumas automações podem começar imediatamente após carregar."] = "Applies the saved profile, including enabled toggles. Some automations may start immediately after loading.",
	["Copia o estado das integrações e os erros capturados. Também tenta salvar um arquivo no executor para ajudar a investigar falhas."] = "Copies integration status and captured errors. It also tries to save a file through the executor to help investigate issues.",
	["Encerra a sessão, restaura as alterações controladas pelo script e remove o HUD e o cursor. Execute o arquivo novamente para voltar."] = "Ends the session, restores changes controlled by the script, and removes the HUD and cursor. Run the file again to reopen it.",
	["Desligado por padrão para respeitar o Shift Lock e a câmera do jogo. Ligue apenas se quiser forçar o mouse solto com o painel fechado. O painel aberto libera o cursor temporariamente e restaura o estado anterior ao fechar."] = "Off by default to respect Shift Lock and the game camera. Enable only if you want to force the mouse free while the hub is closed. The open panel temporarily releases the cursor and restores the previous state when closed.",
	["Liga ataque no seu turno, Auto Dodge e QTE de armas. Ajuste a prioridade de habilidades. O jogo precisa iniciar o combate e aceitar cada ação."] = "Enables turn-based attacks, Auto Dodge, and weapon QTE. Adjust skill priority. The game must start combat and accept each action.",
	["Escolha o inimigo. O farm só aceita revanche após identificá-lo na equipe inimiga. Outros nomes observados em combate também entram na lista."] = "Choose an enemy. Farming only accepts a rematch after identifying it on the enemy team. Other names seen in combat are also added to the list.",
	["Escolha um exemplo de drop do inimigo. A lista é uma referência da comunidade, pode estar desatualizada e não é completa. Não altera a chance de drop."] = "Choose an example drop for the enemy. The list is a community reference, may be outdated, and is incomplete. It does not change drop rates.",
	["Opcional: substitui o drop escolhido pelo nome informado. A confirmação exige uma Tool com esse nome na mochila ou no personagem; outros inventários não são interpretados."] = "Optional: replaces the selected drop with this exact name. Confirmation requires a Tool with that name in your backpack or character; other inventories are not checked.",
	["Quantas unidades adicionais precisam aparecer como Tools, comparadas ao início da sessão. Itens que você já tinha não completam a meta."] = "How many additional copies must appear as Tools compared with the start of the session. Items you already owned do not count toward the goal.",
	["Liga combate e QTEs e monitora o item. Inicie o primeiro encontro manualmente. Revanches só são aceitas para o alvo identificado; para ao confirmar a meta ou atingir limites."] = "Enables combat and QTEs and tracks the item. Start the first encounter manually. Rematches are accepted only for the identified target; stops at the goal or a limit.",
	["Aceita a oferta RefightBoss apenas quando o ID corresponde a um combate reconhecido com o alvo. Não invoca bosses nem ignora condições de entrada."] = "Accepts RefightBoss only when its ID matches a recognized fight with the target. It does not summon bosses or bypass entry requirements.",
	["Aguarda esse tempo para o inventário atualizar antes de repetir. A meta e os limites são conferidos novamente antes da resposta ao servidor."] = "Waits this long for the inventory to update before retrying. The goal and limits are checked again before responding to the server.",
	["Interrompe após esta quantidade de combates encerrados com o alvo. Um encerramento não confirma vitória. Zero remove esse limite."] = "Stops after this many fights with the target end. An ended fight does not confirm a win. Zero removes this limit.",
	["Duração máxima da sessão de farm de drops, em minutos. Zero deixa a sessão sem limite de tempo."] = "Maximum drop-farming session length in minutes. Zero removes the time limit.",
	["Interrompe as novas ações do farm ao atingir essa porcentagem de vida. Não foge do combate nem impede dano do servidor."] = "Stops new farm actions at this health percentage. It does not flee combat or prevent server damage.",
	["Mostra quantas Tools do nome escolhido estão na mochila e equipadas. Durante o farm, também verifica a meta. Não confirma itens guardados em outro sistema."] = "Shows how many Tools with the selected name are in your backpack or equipped. Also checks the goal during farming. It does not detect items stored elsewhere.",
	["Vai à coordenada cadastrada da entrada de Yar'thul ou Thorian. O encontro inicial continua manual. Alvos sem coordenada geram um aviso."] = "Travels to the saved entrance coordinate for Yar'thul or Thorian. The first encounter remains manual. Targets without coordinates show a notice.",
	["Encerra a sessão e cancela revanches pendentes. Restaura os interruptores de combate que o farm ligou, quando ainda estão no valor aplicado."] = "Ends the session and cancels pending rematches. Restores combat toggles enabled by the farm when they still have the values it set.",
	["Seleciona Yar'thul, liga o farm e a revanche e vai à entrada quando fora de combate. Escolha antes o drop desejado; comece o primeiro combate manualmente."] = "Selects Yar'thul, enables farming and rematches, and travels to the entrance when out of combat. Choose the desired drop first; start the first fight manually.",
	["Patrulha o ponto salvo e luta nos encontros. Só essência para na meta. Leveling com Aretim tenta meditar, abrir o diálogo e concluir atributos, verificando as respostas."] = "Patrols the saved point and fights encounters. Essence-only mode stops at its goal. Leveling with Aretim attempts meditation, dialogue, and stat allocation, checking each result.",
	["Só essência encerra na meta. Leveling com Aretim continua até meditação e atributos, exigindo firesignal e fireproximityprompt no executor."] = "Essence-only mode stops at the goal. Leveling with Aretim continues through meditation and stat allocation, requiring firesignal and fireproximityprompt in the executor.",
	["Número de ciclos com atributos concluídos e consumo de essência confirmado. Um ciclo pode subir vários níveis; não é um contador de níveis."] = "Number of cycles with completed stat allocation and confirmed essence use. A cycle may gain several levels; this is not a level counter.",
	["Encerra a sessão após esse tempo total, incluindo encontros, viagens e espera por interfaces. Evita uma patrulha indefinida sem progresso."] = "Ends the session after this total time, including encounters, travel, and interface waits. Prevents an endless patrol without progress.",
	["Interrompe a automação ao atingir essa porcentagem de vida. Não foge de um combate já iniciado nem impede novos ataques do servidor."] = "Stops automation at this health percentage. It does not flee an active fight or prevent server attacks.",
	["Manual pausa com a tela de atributos aberta. Escolher um atributo distribui todos os pontos disponíveis nele, um por vez, e verifica a redução do saldo."] = "Manual pauses with the stat screen open. Choosing a stat spends all available points on it one at a time and checks that the remaining points decrease.",
	["Interrompe o percurso e o ciclo de leveling. Restaura os interruptores de combate ativados por esta sessão; não desfaz pontos já gastos."] = "Stops the route and leveling cycle. Restores combat toggles enabled by this session; it does not undo spent points.",
	["Todos considera qualquer tipo de item. Selecionados coleta somente os nomes marcados na lista. A seleção vazia não coleta nada nesse modo."] = "All includes every item type. Selected collects only names checked in the list. An empty selection collects nothing in this mode.",
	["Marque vários tipos de itens para o modo Selecionados. A lista reúne os itens coletáveis encontrados no mapa carregado e mantém os nomes descobertos nesta sessão."] = "Check multiple item types for Selected mode. The list includes collectible items found in the loaded map and keeps names discovered during this session.",
	["Reexamina SpawnedItems. Novos tipos também aparecem automaticamente. Itens que o jogo ainda não carregou no cliente não podem ser identificados."] = "Rescans SpawnedItems. New types also appear automatically. Items not yet loaded by the game on your client cannot be identified.",
	["Marca todos os tipos conhecidos e muda para Selecionados. Tipos descobertos depois precisam ser marcados; use Todos para aceitar também os futuros."] = "Checks all known types and switches to Selected. Newly discovered types must be checked; use All to include future types.",
	["Desmarca todos os nomes e ativa Selecionados. A coleta fica sem alvos até você marcar algum item ou voltar ao modo Todos."] = "Unchecks every name and enables Selected. Nothing will be collected until you check an item or switch back to All.",
	["Adiciona espera aos QTEs de armas. O Auto Dodge visual usa a posição da barra e não aplica esta espera."] = "Adds a delay to weapon QTEs. Visual Auto Dodge uses the bar position and does not apply this delay.",
	["Procura novamente os módulos e callbacks de QTE e drops. Use depois que a interface de combate aparecer ou mudar."] = "Searches again for QTE and drop modules and callbacks. Use after the combat interface appears or changes.",
	["Faz uma busca opcional e limitada por funções de QTE nas tabelas do cliente. Depende do suporte do executor; veja o resultado no diagnóstico."] = "Runs an optional, limited search for QTE functions in client tables. Depends on executor support; check the diagnostic result.",
	["Escolhe um inimigo da equipe retornada pelo jogo e envia uma ação por turno. Respeita a prioridade de habilidades e a energia disponível."] = "Chooses an enemy from the team returned by the game and sends one action per turn. Respects skill priority and available energy.",
	["Habilidade usada depois da lista de prioridade. Atualize as habilidades com a tela de combate aberta. Strike é o ataque de reserva."] = "Skill used after the priority list. Refresh skills with the combat screen open. Strike is the fallback attack.",
	["Digite os nomes exatos em ordem, como Fire, Strike. O primeiro ataque disponível é escolhido; habilidades desconhecidas são ignoradas."] = "Enter exact names in order, such as Fire, Strike. The first available attack is chosen; unknown skills are ignored.",
	["Tempo mínimo entre tentativas de ataque. Reduzir esse valor não cria turnos extras nem remove cooldowns do jogo."] = "Minimum time between attack attempts. Lowering it does not create extra turns or remove game cooldowns.",
	["Lê as habilidades presentes na interface do jogo e atualiza a seleção. Use ao aprender uma habilidade ou mudar de arma."] = "Reads skills shown in the game interface and refreshes the selection. Use after learning a skill or changing weapons.",
	["Aceita automaticamente participar da disputa de um item oferecido pelo jogo. Participar não garante ganhar o item."] = "Automatically accepts participation in an item roll offered by the game. Joining does not guarantee winning the item.",
	["Responde Accept quando o jogo oferece uma revanche de boss. Pode iniciar outro combate sem um clique manual."] = "Responds Accept when the game offers a boss rematch. This can start another fight without a manual click.",
	["Filtro adicional: o nome também precisa conter este texto, mesmo se estiver marcado na lista. Deixe vazio para usar somente a seleção por tipo."] = "Extra filter: the name must also contain this text, even if checked in the list. Leave blank to filter only by item type.",
	["Espera mínima antes de tentar o mesmo item novamente. Aumente se um item que não pode ser coletado estiver prendendo o farm."] = "Minimum wait before retrying the same item. Increase it if an uncollectible item is holding up the farm.",
	["Caminhar usa rotas e MoveTo. Tween desloca o personagem em linha direta. Os dois modos podem ser interrompidos ao entrar em combate."] = "Walk uses paths and MoveTo. Tween moves the character in a straight line. Both modes can stop when combat begins.",
	["Ajustes de transporte e caminhada automática aparecem nas áreas de deslocamento e são sincronizados entre elas."] = "Travel and auto-walk speed controls appear in movement sections and stay synchronized.",
	["Ajusta de 10 a 500 studs/s as próximas viagens em Tween, incluindo Noclip nos deslocamentos. O valor é compartilhado entre as abas."] = "Sets the speed from 10 to 500 studs/s for future Tween trips, including travel noclip. The value is shared between tabs.",
	["Ajusta de 8 a 100 studs/s os percursos e patrulhas automáticos. Restaura a velocidade anterior ao terminar e respeita mudanças de estado feitas pelo jogo. Valor compartilhado entre as abas."] = "Sets auto routes and patrols from 8 to 100 studs/s. Restores the previous speed when finished and respects game-driven changes. Shared between tabs.",
	["Interrompe o percurso atual e restaura as colisões alteradas. A coleta automática pode escolher outra rota depois; desligue-a para parar tudo."] = "Stops the current route and restores changed collisions. Auto collection may choose another route afterward; turn it off to stop completely.",
	["Anda de um lado para o outro perto do ponto salvo para buscar encontros. Defina o ponto primeiro. Pausa no combate e para na meta de essência."] = "Moves back and forth near the saved point to find encounters. Set the point first. Pauses during combat and stops at the essence goal.",
	["Quantidade de essência que faz a patrulha parar. O valor é lido do HUD. Atingir a meta não compra classe nem faz reset do personagem."] = "Essence amount that stops the patrol. Read from the HUD. Reaching the goal does not buy a class or reset your character.",
	["Distância lateral percorrida a partir do ponto salvo. Use um raio que caiba na área de encontro escolhida."] = "Side-to-side distance from the saved point. Choose a radius that fits the encounter area.",
	["Salva sua posição atual para a patrulha de essência. Vá até uma área de encontro antes de clicar; o ponto dura só nesta sessão."] = "Saves your current position for the essence patrol. Move to an encounter area first; the point lasts for this session only.",
	["Inicia o percurso para o destino selecionado usando o método de movimento atual. Não inicia diálogos nem compra itens ao chegar."] = "Starts a route to the selected destination using the current movement method. It does not start dialogue or buy items on arrival.",
	["Interrompe a viagem em andamento e restaura as colisões alteradas. Não desliga as outras automações."] = "Stops the current trip and restores changed collisions. Other automations remain enabled.",
	["Reexamina a pasta de NPCs e atualiza a lista. Use se o NPC desejado acabou de carregar ou desaparecer."] = "Rescans the NPC folder and refreshes the list. Use it if the NPC just loaded or disappeared.",
	["Vai até o NPC selecionado usando sua posição atual. Não aciona diálogos ou serviços automaticamente."] = "Travels to the selected NPC using its current position. It does not automatically trigger dialogue or services.",
	["Ativa o valor de WalkSpeed abaixo. Ao desligar, restaura a velocidade anterior. O servidor pode corrigir mudanças locais."] = "Applies the WalkSpeed value below. Restores the previous speed when disabled. The server may correct local changes.",
	["Velocidade de caminhada desejada. Só é aplicada com Alterar velocidade ligado. Os percursos automáticos usam o controle de caminhada automática e restauram este valor ao terminar."] = "Desired walking speed. Applied only while Change Walk Speed is enabled. Auto routes use their separate speed control and restore this value when done.",
	["Ativa a potência de salto configurada abaixo. Ao desligar, restaura a potência e a altura anteriores."] = "Applies the jump power set below. Restores the previous power and height when disabled.",
	["Potência do salto. Se o personagem usar altura em vez de potência, o script calcula a altura equivalente com a gravidade atual."] = "Jump power. If the character uses jump height instead, the script calculates the equivalent height using current gravity.",
	["Permite pedir outro salto no ar. Funciona com o painel fechado, fora de combate e sem uma caixa de texto selecionada."] = "Allows another jump in midair. Works with the panel closed, outside combat, and when no text box is selected.",
	["Desliga as automações e os efeitos configurados, cancela o movimento e mantém o painel aberto para ajustes."] = "Turns off automations and configured effects, cancels movement, and leaves the panel open for adjustments.",
}

local function create_arcane_help(ui, make, label, button, round, border, gui, input, colors)
	local panel = make("Frame", {
		Name = "FunctionHelp",
		Size = UDim2.fromOffset(360, 160),
		BackgroundColor3 = colors.panel,
		BorderSizePixel = 0,
		Visible = false,
		Active = true,
		ZIndex = 100,
	}, gui)
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
		heading.Text = ui:Translate(text)
		body.Text = ui:Translate(arcane_help[text])
		heading:SetAttribute("ZyonSourceText", text)
		body:SetAttribute("ZyonSourceText", arcane_help[text])
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
	local ui = { Options = {}, Connections = {}, Open = true, Unloaded = false, Errors = {}, ModuleStatus = {}, Language = "Português" }
	function ui:Translate(text)
		text = tostring(text or "")
		if self.Language == "English" then
			return arcane_english[text] or text
		end
		return text
	end
	function ui:SetLanguage(language)
		self.Language = language == "English" and "English" or "Português"
		if self.ScreenGui then
			for _, object in ipairs(self.ScreenGui:GetDescendants()) do
				if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
					local source = object:GetAttribute("ZyonSourceText")
					if source ~= nil and not object:IsA("TextBox") then
						object.Text = self:Translate(source)
					end
					local placeholder = object:GetAttribute("ZyonSourcePlaceholder")
					if placeholder ~= nil then
						object.PlaceholderText = self:Translate(placeholder)
					end
				end
			end
		end
		if self.HelpTooltip then
			local title = self.HelpTooltip:FindFirstChild("HelpTitle")
			local body = self.HelpTooltip:FindFirstChild("HelpBody")
			if title then
				title.Text = self:Translate(title:GetAttribute("ZyonSourceText") or "")
			end
			if body then
				body.Text = self:Translate(body:GetAttribute("ZyonSourceText") or "")
			end
		end
	end
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
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			obj:SetAttribute("ZyonSourceText", tostring(obj.Text or ""))
			obj.Text = ui:Translate(obj.Text)
			if obj:IsA("TextBox") then
				obj:SetAttribute("ZyonSourcePlaceholder", tostring(obj.PlaceholderText or ""))
				obj.PlaceholderText = ui:Translate(obj.PlaceholderText)
			end
		end
		if ui.AppearanceAlpha and obj:IsA("GuiObject") and obj.BackgroundTransparency < 1 then
			local base = obj.BackgroundTransparency
			obj:SetAttribute("ZyonBaseTransparency", base)
			obj.BackgroundTransparency = base + (1 - base) * ui.AppearanceAlpha
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
		return make("TextLabel", {
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = colors.text,
			Font = Enum.Font.BuilderSans,
			TextSize = size or 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, 0, 0, 22),
		}, parent)
	end
	local function button(parent, text)
		local obj = make("TextButton", {
			BackgroundColor3 = colors.raised,
			BorderSizePixel = 0,
			AutoButtonColor = true,
			Text = text,
			TextColor3 = colors.text,
			TextSize = 13,
			Font = Enum.Font.BuilderSansMedium,
			Size = UDim2.new(1, 0, 0, 32),
		}, parent)
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
	local gui = make("ScreenGui", {
		Name = "ZyonVV",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 80,
	})
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
	local shell = make("Frame", {
		Name = "Window",
		Size = UDim2.fromOffset(840, 580),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = colors.bg,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 10,
	}, gui)
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
	local sub = label(titlebar, "VV: ULTIMATUM / 0.2", 13)
	sub.TextColor3 = colors.muted
	sub.Position = UDim2.fromOffset(23, 37)
	sub.Size = UDim2.fromOffset(170, 18)
	local current = label(titlebar, "Combate", 17)
	current.Position = UDim2.fromOffset(205, 22)
	current.Size = UDim2.fromOffset(235, 24)
	local search = make("TextBox", {
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
	}, titlebar)
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
	local cursor_gui = make("ScreenGui", {
		Name = "ZyonCursorOverlay",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.None,
		ClipToDeviceSafeArea = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 2147483647,
	}, gui.Parent)
	local cursor = make("Frame", {
		Name = "Pointer",
		Size = UDim2.fromOffset(21, 29),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Visible = false,
		ZIndex = 1,
	}, cursor_gui)
	cursor_gui.Enabled = false
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
			make("Frame", {
				BackgroundColor3 = Color3.fromRGB(20, 16, 32),
				BorderSizePixel = 0,
				Active = false,
				Position = UDim2.fromOffset(left, y),
				Size = UDim2.fromOffset(right - left + 1, 1),
				ZIndex = 1,
			}, cursor)
		end
		if inner_left then
			make("Frame", {
				BackgroundColor3 = Color3.fromRGB(248, 246, 255),
				BorderSizePixel = 0,
				Active = false,
				Position = UDim2.fromOffset(inner_left, y),
				Size = UDim2.fromOffset(inner_right - inner_left + 1, 1),
				ZIndex = 2,
			}, cursor)
		end
	end
	local cursor_binding = "ZyonVVCursor"
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
	local function release_cursor()
		cursor.Visible = false
	end
	cursor_gui.Enabled = false
	minimize.Modal = false
	local function update_cursor()
		cursor.Visible = false
	end
	local function refresh_cursor_binding()
		run:UnbindFromRenderStep(cursor_binding)
	end
	local function set_cursor_enabled(enabled)
		cursor_active = enabled == true
		minimize.Modal = false
		refresh_cursor_binding()
	end
	function ui:SetFreeMouse(enabled)
		free_mouse = false
		self:Notify({ Content = "Entrada nativa: altere o Shift Lock pelo próprio jogo." })
	end
	local function is_dialogue_visible(object)
		if not object or not object.Parent then
			return false
		end
		local node = object
		while node and node ~= players.LocalPlayer do
			if node:IsA("GuiObject") and not node.Visible then
				return false
			end
			if node:IsA("ScreenGui") and not node.Enabled then
				return false
			end
			node = node.Parent
		end
		return true
	end
	local function cache_dialogue(root)
		if root == dialogue_root then
			return
		end
		for _, connection in ipairs(dialogue_connections) do
			connection:Disconnect()
		end
		dialogue_connections, dialogue_nodes, dialogue_root = {}, {}, root
		if not root then
			return
		end
		local function add(object)
			if object:IsA("TextLabel") or object:IsA("GuiButton") then
				dialogue_nodes[object] = true
			end
		end
		for _, object in ipairs(root:GetDescendants()) do
			add(object)
		end
		table.insert(dialogue_connections, ui:Connect(root.DescendantAdded, add))
		table.insert(
			dialogue_connections,
			ui:Connect(root.DescendantRemoving, function(object)
				dialogue_nodes[object] = nil
			end)
		)
	end
	local function poll_dialogue()
		local player_gui = players.LocalPlayer:FindFirstChild("PlayerGui")
		local root
		if player_gui then
			for _, name in ipairs({ "NPCDialogue", "NPCDialog", "Dialogue", "DialogueGui" }) do
				local candidate = player_gui:FindFirstChild(name)
				if candidate and (candidate:IsA("ScreenGui") or candidate:IsA("GuiObject")) then
					root = candidate
					break
				end
			end
		end
		cache_dialogue(root)
		ui.DialogueRoot = dialogue_root
		local active = false
		if dialogue_root and is_dialogue_visible(dialogue_root) then
			for object in pairs(dialogue_nodes) do
				if is_dialogue_visible(object) and object.AbsoluteSize.X > 0 and object.AbsoluteSize.Y > 0 then
					if object:IsA("GuiButton") or object.Text:match("%S") then
						active = true
						break
					end
				end
			end
		end
		ui.DialogueActive = active
		ui.ModuleStatus.Dialogue = active and ("aberto: " .. dialogue_root.Name .. "; entrada nativa preservada")
			or "fechado"
		if active ~= dialogue_active then
			dialogue_active = active
			if active and ui.CreateWindow then
				ui:CreateWindow():SetOpen(false)
			end
			if not active then
				release_cursor()
			end
			refresh_cursor_binding()
			update_cursor()
		end
	end
	ui:Connect(run.Heartbeat, function()
		if cursor_stopped then
			return
		end
		local now = os.clock()
		if now < next_dialogue_check then
			return
		end
		next_dialogue_check = now + 0.1
		ui:Run("diálogo e cursor", poll_dialogue)
	end)
	local function shutdown_cursor()
		cursor_stopped = true
		cursor_active = false
		minimize.Modal = false
		for _, connection in ipairs(dialogue_connections) do
			connection:Disconnect()
		end
		dialogue_connections, dialogue_nodes = {}, {}
		run:UnbindFromRenderStep(cursor_binding)
		release_cursor()
	end
	set_cursor_enabled(true)
	local theme_palettes = {
		["Nebula"] = {
			bg = { 17, 18, 29 },
			panel = { 25, 27, 43 },
			raised = { 37, 40, 61 },
			line = { 60, 64, 88 },
			text = { 239, 240, 251 },
			muted = { 163, 172, 199 },
			accent = { 162, 139, 250 },
			danger = { 255, 112, 133 },
		},
		["Oceano"] = {
			bg = { 12, 23, 33 },
			panel = { 18, 34, 46 },
			raised = { 27, 48, 63 },
			line = { 46, 75, 91 },
			text = { 230, 245, 252 },
			muted = { 152, 184, 201 },
			accent = { 63, 204, 224 },
			danger = { 255, 112, 133 },
		},
		["Esmeralda"] = {
			bg = { 15, 25, 23 },
			panel = { 23, 36, 32 },
			raised = { 33, 51, 44 },
			line = { 54, 78, 68 },
			text = { 234, 247, 239 },
			muted = { 158, 188, 173 },
			accent = { 91, 219, 163 },
			danger = { 255, 112, 133 },
		},
		["Obsidiana"] = {
			bg = { 16, 17, 20 },
			panel = { 25, 27, 31 },
			raised = { 38, 41, 47 },
			line = { 62, 66, 74 },
			text = { 239, 240, 245 },
			muted = { 167, 174, 187 },
			accent = { 230, 185, 109 },
			danger = { 255, 112, 133 },
		},
		["Aurora clara"] = {
			bg = { 235, 239, 248 },
			panel = { 249, 251, 255 },
			raised = { 219, 226, 240 },
			line = { 188, 199, 221 },
			text = { 29, 38, 60 },
			muted = { 87, 101, 129 },
			accent = { 102, 76, 204 },
			danger = { 192, 51, 75 },
		},
	}
	local base_transparency = setmetatable({}, { __mode = "k" })
	local function hex_color(value)
		local h = tostring(value or ""):gsub("^#", "")
		if not h:match("^%x%x%x%x%x%x$") then
			return nil
		end
		return Color3.fromRGB(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16))
	end
	function ui:SetAppearance(theme, transparency, accent_hex, background_hex)
		if self.Unloaded then
			return
		end
		local palette = theme_palettes[theme] or theme_palettes.Nebula
		local next_colors = {}
		for role, rgb in pairs(palette) do
			next_colors[role] = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
		end
		next_colors.accent = hex_color(accent_hex) or next_colors.accent
		next_colors.bg = hex_color(background_hex) or next_colors.bg
		local alpha = math.clamp((tonumber(transparency) or 8) / 100, 0, 0.75)
		local function recolor(object, property)
			local value = object[property]
			for role, old in pairs(colors) do
				if value == old then
					object[property] = next_colors[role]
					break
				end
			end
		end
		for _, object in ipairs(gui:GetDescendants()) do
			if object:IsA("GuiObject") then
				recolor(object, "BackgroundColor3")
				if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
					recolor(object, "TextColor3")
				end
				if object:IsA("TextBox") then
					recolor(object, "PlaceholderColor3")
				end
				if object:IsA("ScrollingFrame") then
					recolor(object, "ScrollBarImageColor3")
				end
				if base_transparency[object] == nil then
					base_transparency[object] = object:GetAttribute("ZyonBaseTransparency")
						or object.BackgroundTransparency
				end
				local base = base_transparency[object]
				if base < 1 then
					object.BackgroundTransparency = base + (1 - base) * alpha
				end
			elseif object:IsA("UIStroke") then
				recolor(object, "Color")
			end
		end
		for role, value in pairs(next_colors) do
			colors[role] = value
		end
		self.AppearanceAlpha = alpha
		self.ModuleStatus.Appearance = tostring(theme)
			.. " · transparência "
			.. tostring(math.floor(alpha * 100))
			.. "%"
	end

	local nav = make(
		"ScrollingFrame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = colors.accent,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(0, 174, 1, -228),
			Position = UDim2.fromOffset(14, 84),
		},
		shell
	)
	make("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, nav)
	local sidebar_line = make(
		"Frame",
		{ BackgroundColor3 = colors.line, BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -108), Position = UDim2.fromOffset(
			192,
			80
		) },
		shell
	)
	local header_line = make(
		"Frame",
		{ BackgroundColor3 = colors.accent, BorderSizePixel = 0, Size = UDim2.new(1, -40, 0, 2), Position = UDim2.fromOffset(
			20,
			70
		) },
		shell
	)
	local profile = make(
		"Frame",
		{
			Name = "AccountProfile",
			BackgroundColor3 = colors.panel,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(174, 82),
			Position = UDim2.new(0, 14, 1, -126),
		},
		shell
	)
	round(profile, 10)
	border(profile)
	local local_player = players.LocalPlayer
	local fallback = label(profile, local_player.DisplayName:sub(1, 1):upper(), 20)
	fallback.Position = UDim2.fromOffset(10, 16)
	fallback.Size = UDim2.fromOffset(42, 42)
	fallback.TextXAlignment = Enum.TextXAlignment.Center
	fallback.BackgroundColor3 = colors.raised
	fallback.BackgroundTransparency = 0
	round(fallback, 21)
	local avatar = make(
		"ImageLabel",
		{
			Name = "RobloxAvatar",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(42, 42),
			Position = UDim2.fromOffset(10, 16),
			Image = "",
		},
		profile
	)
	round(avatar, 21)
	local display = label(profile, local_player.DisplayName, 12)
	display.Font = Enum.Font.BuilderSansBold
	display.Position = UDim2.fromOffset(60, 17)
	display.Size = UDim2.fromOffset(105, 20)
	local username = label(profile, "@" .. local_player.Name, 10)
	username.TextColor3 = colors.muted
	username.Position = UDim2.fromOffset(60, 37)
	username.Size = UDim2.fromOffset(105, 18)
	local account_status = label(profile, "CONTA CONECTADA", 8)
	account_status.TextColor3 = colors.accent
	account_status.Position = UDim2.fromOffset(12, 63)
	account_status.Size = UDim2.fromOffset(152, 12)
	task.spawn(function()
		local ok, content, ready = pcall(function()
			return players:GetUserThumbnailAsync(
				local_player.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
		end)
		if ui.Unloaded then
			return
		end
		if ok and ready and type(content) == "string" and content ~= "" then
			avatar.Image = content
			fallback.Visible = false
			ui.ModuleStatus.Account = "@" .. local_player.Name .. " · avatar carregado"
		else
			ui.ModuleStatus.Account = "@" .. local_player.Name .. " · avatar indisponível; inicial exibida"
		end
	end)
	local footer = label(shell, "ZYON  /  Insert · RightCtrl para abrir e fechar", 10)
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
		toast.Text = self:Translate(tostring(info.Title or "Zyon"))
			.. "  ·  "
			.. self:Translate(tostring(info.Content or ""))
		toast:SetAttribute("ZyonSourceText", toast.Text)
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
		ui.Open = value == true
		gui.Enabled = ui.Open
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
		elseif event.KeyCode == Enum.KeyCode.F7 and ui.ProbeDialogue then
			ui:Run("captura de diálogo", function()
				ui:ProbeDialogue()
			end)
		elseif event.KeyCode == Enum.KeyCode.F9 then
			ui:Unload()
		elseif event.KeyCode == Enum.KeyCode.F8 and ui.ExitDialogue then
			ui:Run("sair do diálogo", function()
				local _, message = ui:ExitDialogue()
				ui:Notify({ Content = message })
			end)
		end
	end)
	local translations = {
		["Drops"] = "Bosses e drops",
		["Items"] = "Coleta",
		["Soul"] = "Essência",
		["Travel"] = "Viagens",
		["Character"] = "Personagem",
		["Settings"] = "Configurações",
		["Appearance"] = "Aparência",
		["Auto Quest"] = "Auto Quest",
		["Board Quests"] = "Quests do quadro",
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
		tab_button.Size = UDim2.new(1, -5, 0, 35)
		tab_button.LayoutOrder = #tabs
		tab_button.TextXAlignment = Enum.TextXAlignment.Left
		make("UIPadding", { PaddingLeft = UDim.new(0, 14) }, tab_button)
		local page = make("ScrollingFrame", {
			Size = UDim2.new(1, -224, 1, -128),
			Position = UDim2.fromOffset(206, 84),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = colors.accent,
			Visible = false,
		}, shell)
		local columns = {}
		for index, side in ipairs({ "Left", "Right" }) do
			local col = make("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, -9, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Position = UDim2.new((index - 1) * 0.5, index == 2 and 5 or 0, 0, 0),
			}, page)
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
			local card = make("Frame", {
				BackgroundColor3 = colors.panel,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = #tab.groups,
			}, columns[side or "Left"])
			round(card, 9)
			border(card)
			make("UIPadding", {
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12),
			}, card)
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
				local value = make("TextBox", {
					BackgroundColor3 = colors.raised,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(77, 25),
					Position = UDim2.new(1, -77, 0, 42),
					TextColor3 = colors.text,
					TextSize = 13,
					Font = Enum.Font.BuilderSansMedium,
					ClearTextOnFocus = false,
				}, frame)
				round(value, 4)
				local track = button(frame, "")
				track.Size = UDim2.new(1, -90, 0, 18)
				track.Position = UDim2.fromOffset(0, 46)
				track.BackgroundTransparency = 1
				local rail = make("Frame", {
					BackgroundColor3 = colors.line,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 3),
					Position = UDim2.fromOffset(0, 7),
				}, track)
				round(rail, 3)
				local fill = make(
					"Frame",
					{ BackgroundColor3 = colors.accent, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) },
					rail
				)
				round(fill, 3)
				local dot = make("Frame", {
					BackgroundColor3 = colors.text,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(10, 10),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0, 0.5),
				}, rail)
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
					popup = make("Frame", {
						Size = UDim2.fromOffset(350, 330),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundColor3 = colors.panel,
						BorderSizePixel = 0,
						ZIndex = 20,
					}, shell)
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
					local list = make("ScrollingFrame", {
						Position = UDim2.fromOffset(10, 50),
						Size = UDim2.new(1, -20, 1, -60),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.new(),
						ScrollBarThickness = 3,
						ZIndex = 21,
					}, popup)
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
				local box = make("TextBox", {
					Position = UDim2.fromOffset(0, 31),
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = colors.raised,
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					TextColor3 = colors.text,
					PlaceholderText = "Opcional",
					TextSize = 13,
					Font = Enum.Font.BuilderSansMedium,
				}, frame)
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
			"ZYON VV / 0.2",
			"PlaceId: " .. tostring(game.PlaceId),
			"GameId: " .. tostring(game.GameId),
			"Validação em jogo: pendente de teste local",
		}
		for _, name in ipairs({
			"getgc",
			"getcallbackvalue",
			"fireclickdetector",
			"firesignal",
			"writefile",
			"readfile",
		}) do
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
			pcall(writefile, "ZyonVV-diagnostico.txt", report)
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




-- Quest assistance reads only explicitly selected visible progress; no server protocol assumed.
local QuestRules = {}
function QuestRules.parse(value)
 local clean=tostring(value or ""):gsub("<[^>]*>","")
 local count,current,total=0,nil,nil
 for a,b in clean:gmatch("(%d+)%s*/%s*(%d+)") do count+=1; current=tonumber(a); total=tonumber(b) end
 if count~=1 or total<=0 or current>total then return end
 return current,total
end
function QuestRules.update(state,current,total)
 if not current or total~=state.total or current<state.current then return "changed" end
 state.current=current
 return current==total and "complete" or "active"
end
local function create_quest_tools(app,window,d)
 local q={active=false,phase="idle",waypoint=nil,rows={},bound=nil,last_read=0}
 local tab=window:AddTab(d.text("Quests","Quests"))
 local setup=d.group(tab,"Objetivo acompanhado","Tracked objective")
 local execution=d.group(tab,"Ciclo e retorno","Cycle and return","Right")
 local f=d.flags
 local selector=d.control(setup,"AddDropdown","QuestLabel","Contador visível","Visible counter","—",{Values={"—"}})
 local status=setup:AddLabel(d.text("Selecione um contador incompleto como 0/4.","Select an incomplete counter such as 0/4."),{Height=80})
 local function set_status(pt,en)
  q.status_pt,q.status_en=pt,en or pt
  status:SetText(app.Language=="English" and q.status_en or q.status_pt)
 end
 local function visible(object)
  local gui=d.player:FindFirstChild("PlayerGui")
  if not gui or not object or not object.Parent or not object:IsDescendantOf(gui) then return false end
  if app.ScreenGui and object:IsDescendantOf(app.ScreenGui) then return false end
  local p=object
  while p do
   if p:IsA("GuiObject") and not p.Visible then return false end
   if p:IsA("ScreenGui") and not p.Enabled then return false end
   if p.Name=="Chat" or p.Name=="ExperienceChat" then return false end
   p=p.Parent
  end
  return true
 end
 d.button(setup,"Ler contadores da tela","Read on-screen counters",function()
  if q.active then d.notice("Pare o ciclo antes de trocar o contador.","Stop the cycle before changing the counter."); return end
  q.rows={}; local values={"—"}
  local gui=d.player:FindFirstChild("PlayerGui")
  if gui then
   for _,o in ipairs(gui:GetDescendants()) do
    if (o:IsA("TextLabel") or o:IsA("TextButton")) and visible(o) and QuestRules.parse(o.Text) then
     local caption=tostring(#values).." · "..o.Text:gsub("<[^>]*>",""):sub(1,65).." · "..o.Parent.Name
     q.rows[caption]=o; values[#values+1]=caption
    end
   end
  end
  selector:SetValues(values); selector:SetValue("—")
  set_status(tostring(#values-1).." contadores. Confira que é o objetivo da quest.",tostring(#values-1).." counters. Verify this is the quest objective.")
 end)
 setup:AddLabel(d.text("Leitura de texto, não reconhecimento da quest. Vida, munição e outros contadores também podem aparecer. Selecione somente o objetivo correto, visível durante a luta.","Text reading, not quest recognition. Health, ammo and other counters may appear. Select only the correct objective, visible during combat."),{Height=105})
 d.slider(execution,"QuestMinutes","Limite do ciclo (min)","Cycle limit (min)",10,1,60)
 d.slider(execution,"QuestMinHP","Parar abaixo de HP (%)","Stop below HP (%)",25,1,90)
 d.toggle(execution,"QuestReturn","Retornar ao ponto ao atingir meta","Return to point at goal")
 d.toggle(execution,"QuestInteract","Enviar interação ao chegar","Send interaction on arrival")
 d.box(execution,"InteractKey","Tecla de interação","Interaction key","T")
 local point_label=execution:AddLabel("—",{Height=55})
 d.button(execution,"Salvar minha posição de retorno","Save my return position",function()
  if q.active then return end
  local _,root=d.parts(d.player.Character)
  if root then
   local p=root.Position; q.waypoint={place=game.PlaceId,x=p.X,y=p.Y,z=p.Z}
   point_label:SetText(string.format("%.1f / %.1f / %.1f",p.X,p.Y,p.Z))
  end
 end)
 function q:Stop(pt,en)
  self.active=false; self.phase="idle"; self.bound=nil
  if pt then set_status(pt,en) end
 end
 local function abort(pt,en)
  d.stop(); set_status(pt,en)
 end
 d.button(execution,"Iniciar objetivo · NPC selecionado","Start objective · selected NPC",function()
  local obj=q.rows[f.QuestLabel]
  if not obj or not visible(obj) then d.notice("Selecione um contador visível.","Select a visible counter."); return end
  local current,total=QuestRules.parse(obj.Text)
  if not current or current>=total then d.notice("O contador precisa estar incompleto.","Counter must be incomplete."); return end
  if f.TargetName=="—" then d.notice("Selecione o inimigo em Alvos e farm.","Select the enemy in Targets and farm."); return end
  if f.QuestReturn and (not q.waypoint or q.waypoint.place~=game.PlaceId) then
   d.notice("Salve um retorno neste mapa.","Save a return point in this place."); return
  end
  d.stop()
  q.active=true; q.phase="objective"; q.bound=obj; q.current=current; q.total=total
  q.started=os.clock(); q.last_read=-math.huge; q.missing=nil; q.enemy=f.TargetName; q.completed_at=nil
  q.return_enabled=f.QuestReturn; q.interact_enabled=f.QuestInteract
  for _,key in ipairs({"Attack","Farm","Lock"}) do app.Options[key]:SetValue(true) end
  set_status("Ciclo ativo; feche o painel. A meta é apenas este contador.","Cycle active; close panel. Goal is this counter only.")
 end)
 d.button(execution,"Parar ciclo","Stop cycle",function() abort("Ciclo parado.","Cycle stopped.") end)
 local guide=d.group(tab,"Roteiro de referência","Reference guide")
 guide:AddLabel(d.text("Missing Necklace: aceite com Nikla em Fort Adams, rastreie a quest, use U para Soul Society Outskirts, procure o marcador e baú; depois retorne a Nikla. Guia comunitário, não rota automática.","Missing Necklace: accept from Nikla in Fort Adams, track the quest, use U for Soul Society Outskirts, find the marker and chest; then return to Nikla. Community guide, not an automatic route."),{Height=140})
 guide:AddLabel(d.text("Fontes: progameguides.com/roblox/how-to-complete-missing-necklace-quest-in-vv-ultimatum/ e vvultimatum.net/quests. Confirme o objetivo atual no jogo. Este ciclo não aceita quests, troca mapas ou confirma recompensas.","Sources: progameguides.com/roblox/how-to-complete-missing-necklace-quest-in-vv-ultimatum/ and vvultimatum.net/quests. Confirm the current in-game objective. This cycle does not accept quests, change maps or verify rewards."),{Height=135})
 local function halt_fight()
  for _,key in ipairs({"Attack","Farm","Skills","Lock","Counter"}) do app.Options[key]:SetValue(false) end
  d.release_all()
 end
 function q:Tick(now)
  if not self.active then return false end
  if now-self.started>f.QuestMinutes*60 then abort("Limite de tempo atingido.","Time limit reached."); return true end
  local hum,root=d.parts(d.player.Character)
  if not hum or hum.Health/math.max(1,hum.MaxHealth)*100<=f.QuestMinHP then
   abort("Ciclo parado por vida baixa ou personagem ausente.","Cycle stopped: low health or missing character."); return true
  end
  if not d.ready() then d.release_all(); hum:MoveTo(root.Position); return true end
  if self.phase=="objective" then
   if f.TargetName~=self.enemy then abort("Alvo alterado; reinicie o ciclo.","Target changed; restart cycle."); return true end
   if now-self.last_read<0.25 then return self.missing~=nil end
   self.last_read=now
   local a,b
   if visible(self.bound) then a,b=QuestRules.parse(self.bound.Text) end
   if not a then
    self.missing=self.missing or now
    d.release_all(); hum:MoveTo(root.Position)
    if now-self.missing>=3 then abort("Contador indisponível. Conclusão não confirmada.","Counter unavailable. Completion not confirmed.") end
    return true
   end
   self.missing=nil
   local result=QuestRules.update(self,a,b)
   if result=="changed" then abort("Contador mudou de objetivo; ciclo parado.","Objective counter changed; cycle stopped."); return true end
   set_status("Objetivo: "..a.."/"..b,"Objective: "..a.."/"..b)
   if result=="complete" then
    halt_fight(); hum:MoveTo(root.Position)
    self.phase="settle"; self.completed_at=now
    set_status("Meta observada; confirmando estabilidade.","Goal observed; checking stability.")
    return true
   end
   return false
  elseif self.phase=="settle" then
   local a,b
   if visible(self.bound) then a,b=QuestRules.parse(self.bound.Text) end
   if a~=self.total or b~=self.total then abort("Meta não permaneceu visível; revise a quest.","Goal did not remain visible; review quest."); return true end
   if now-self.completed_at<0.75 then return true end
   if self.return_enabled then
    self.phase="return"; self.return_started=now; self.progress_at=now; self.best_distance=math.huge
   else abort("Contador completo. Entrega e recompensa ainda não verificadas.","Counter complete. Turn-in and reward are unverified.") end
   return true
  elseif self.phase=="return" then
   local p=self.waypoint
   if not p or p.place~=game.PlaceId then abort("Mapa diferente; retorno cancelado.","Different place; return cancelled."); return true end
   local destination=Vector3.new(p.x,p.y,p.z)
   local distance=(root.Position-destination).Magnitude
   if distance<self.best_distance-1 then self.best_distance=distance; self.progress_at=now end
   if now-self.progress_at>8 or now-self.return_started>60 then abort("Retorno bloqueado; caminhe manualmente.","Return blocked; walk manually."); return true end
   if distance<=4 then
    local interact=self.interact_enabled; local key=d.vk(f.InteractKey)
    abort("Retorno concluído. Confira o diálogo e entregue manualmente.","Return complete. Check dialogue and turn in manually.")
    if interact and key then d.pulse(key,0.08) end
   elseif now-(self.last_move or 0)>=0.3 then
    self.last_move=now; hum:MoveTo(destination)
    set_status("Retornando: "..math.floor(distance).." studs","Returning: "..math.floor(distance).." studs")
   end
   return true
  end
  return true
 end
 return q
end

-- Original VV controller: input automation, configurable animation profiles.
local env = getgenv and getgenv() or _G
if env.ZyonVV then pcall(function() env.ZyonVV:Unload() end) end
local app = create_hud()
env.ZyonVV = app
local window = app:CreateWindow()
local players = game:GetService("Players")
local player = players.LocalPlayer
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local http = game:GetService("HttpService")
local flags, profiles, candidates = {}, {}, {}
local target, observed, animation_connection, watched_animator
local held, next_action = {}, {}
local generation, last_scan, last_move = 0, 0, 0
local was_moving=false
local quest
local animation_history, pending_parries = {}, {}
local refresh_animation_choices
local counters={attack=0,parry=0,skill=0,input_errors=0,animations=0}
local latest_reason="Inicializando"
local last_report=0
local npc_catalog={}
local pending_input_test
local active_keys = {"Attack", "Counter", "Lock", "Farm", "Skills"}
local function notice(pt, en)
 app:Notify({Title="Zyon / VV", Content=app.Language == "English" and (en or pt) or pt})
end
local function text(pt,en) arcane_english[pt]=en; return pt end
local help={
 Attack={"Envia clique esquerdo somente com alvo selecionado dentro do alcance e painel fechado.","Sends left click only with a selected target in range and the panel closed."},
 Farm={"Caminha em linha direta até a distância configurada. Não calcula rotas em obstáculos.","Walks directly to the configured distance. Does not navigate around obstacles."},
 Counter={"Usa apenas IDs cadastrados. O atraso começa no evento da animação; não confirma acerto ou defesa no servidor.","Uses registered IDs only. Delay starts at the animation event; server hits and defenses are not verified."},
 SkillKeys={"Teclas separadas por vírgula, como R,T,Y. Também aceita CTRL, SHIFT, ALT e SPACE.","Comma-separated keys such as R,T,Y. Also accepts CTRL, SHIFT, ALT and SPACE."},
 Delay={"Tempo entre início da animação e envio da defesa. Ajuste individualmente para cada golpe.","Time between animation start and defense input. Adjust separately for each attack."},
 Lead={"Subtrai este valor do atraso cadastrado. Não mede latência automaticamente.","Subtracts this value from the saved delay. Does not measure latency automatically."},
 TargetName={"Lista modelos carregados com Humanoid, excluindo personagens de jogadores. O nome não comprova que o NPC é hostil.","Lists loaded models with a Humanoid, excluding player characters. A name does not prove the NPC is hostile."},
 Lock={"Aponta a câmera para o NPC selecionado enquanto o painel está fechado.","Points the camera at the selected NPC while the panel is closed."},
}
local function group(tab,pt,en,side) return tab:AddGroup(text(pt,en),side or "Left") end
local function control(card,kind,key,pt,en,default,extra)
 if help[key] then arcane_help[pt]=help[key][1]; arcane_english[help[key][1]]=help[key][2] end
 flags[key]=default
 local options=extra or {}; options.Text=text(pt,en); options.Default=default
 options.Callback=function(v) flags[key]=v end
 return card[kind](card,key,options)
end
local function toggle(c,k,pt,en) return control(c,"AddToggle",k,pt,en,false) end
local function slider(c,k,pt,en,d,lo,hi)
 return control(c,"AddSlider",k,pt,en,d,{Min=lo,Max=hi,Rounding=2})
end
local function box(c,k,pt,en,d) return control(c,"AddTextbox",k,pt,en,d or "") end
local function button(c,pt,en,fn) return c:AddButton(text(pt,en),{Callback=fn}) end
local function parts(model)
 if not model or not model.Parent then return end
 local h=model:FindFirstChildOfClass("Humanoid")
 local root=model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
 if h and h.Health>0 and root and root:IsA("BasePart") then return h,root end
end
local function release_all()
 for key in pairs(held) do
  if key=="M1" then pcall(function() mouse1release() end)
  else pcall(function() keyrelease(key) end) end
 end
 table.clear(held)
end
local function stop()
 generation+=1
 table.clear(pending_parries)
 pending_input_test=nil
 if quest then quest:Stop("Ciclo parado.","Cycle stopped.") end
 for _,k in ipairs(active_keys) do
  flags[k]=false
  if app.Options[k] then app.Options[k]:SetValue(false,true) end
 end
 release_all()
 local h,r=parts(player.Character)
 if h then h:MoveTo(r.Position) end
end
local function pulse(key,duration)
 if held[key] then return false end
 local press=key=="M1" and mouse1press or keypress
 local release=key=="M1" and mouse1release or keyrelease
 if type(press)~="function" or type(release)~="function" then
  stop(); notice("Entrada indisponível no executor.","Executor input unavailable."); return false
 end
 local ok,err=pcall(function() if key=="M1" then press() else press(key) end end)
 if not ok then counters.input_errors+=1; stop(); notice(tostring(err)); return false end
 local token={}; held[key]=token
 task.delay(duration,function()
  if held[key]~=token then return end
  pcall(function() if key=="M1" then release() else release(key) end end)
  held[key]=nil
 end)
 return true
end
local function vk(name)
 name=tostring(name):upper()
 if name:match("^[A-Z0-9]$") then return string.byte(name) end
 return ({SPACE=0x20,CTRL=0x11,SHIFT=0x10,ALT=0x12})[name]
end
local function ready()
 return not app.Unloaded and not app.Open and not app.DialogueActive and not input:GetFocusedTextBox()
end
local function in_range(maximum)
 local h,r=parts(player.Character); local th,tr=parts(target)
 if not h or not th then return false end
 return (r.Position-tr.Position).Magnitude<=maximum
end
local combat=window:AddTab("Combat")
local attacks=group(combat,"Ataques","Attacks")
toggle(attacks,"Attack","Auto ataque leve","Auto light attack")
slider(attacks,"AttackInterval","Intervalo de ataque (s)","Attack interval (s)",0.45,0.1,3)
slider(attacks,"Range","Alcance de ataque","Attack range",7,2,25)
toggle(attacks,"Lock","Travar câmera no alvo","Lock camera to target")
button(attacks,"Equipar arma · X","Equip weapon · X",function() pulse(0x58,0.08) end)
local skills=group(combat,"Habilidades","Skills","Right")
toggle(skills,"Skills","Auto habilidades","Auto skills")
box(skills,"SkillKeys","Sequência de teclas","Key sequence","R,T,Y")
slider(skills,"SkillInterval","Intervalo entre habilidades (s)","Time between skills (s)",5,0.5,60)
skills:AddLabel(text("Intervalo fixo: não lê cooldowns do servidor.","Fixed interval: does not read server cooldowns."),{Height=50})
local farm=window:AddTab(text("Alvos e farm","Targets and farm"))
local selection=group(farm,"Seleção de NPC","NPC selection")
local list_signature=""
local target_control=control(selection,"AddDropdown","TargetName","NPC carregado","Loaded NPC","—",{Values={"—"}})
local function scan()
 table.clear(candidates)
 table.clear(npc_catalog)
 local names, unique={},{}
 for _,o in ipairs(workspace:GetDescendants()) do
  if o:IsA("Humanoid") and o.Parent and o.Parent:IsA("Model") then
   local m=o.Parent
   if m~=player.Character and not players:GetPlayerFromCharacter(m) and parts(m) then
    candidates[#candidates+1]=m
   if #npc_catalog<25 then npc_catalog[#npc_catalog+1]=m:GetFullName() end
    if not unique[m.Name] then unique[m.Name]=true; names[#names+1]=m.Name end
   end
  end
 end
 table.sort(names); table.insert(names,1,"—")
 local signature=table.concat(names,"\n")
 if signature~=list_signature then
  list_signature=signature
  local selected=flags.TargetName
  target_control:SetValues(names)
  if table.find(names,selected) then target_control:SetValue(selected) end
 end
end
button(selection,"Atualizar NPCs","Refresh NPCs",scan)
toggle(selection,"Farm","Aproximar do NPC selecionado","Approach selected NPC")
slider(selection,"ScanRange","Raio de busca","Search radius",100,10,1000)
slider(selection,"Distance","Distância de parada","Stopping distance",5,2,20)
local status=group(farm,"Estado","Status","Right")
local target_label=status:AddLabel("—",{Height=85})
button(status,"Selecionar NPC mais próximo","Select nearest NPC",function()
 scan()
 local _,root=parts(player.Character); local best,dist=nil,flags.ScanRange
 if not root then notice("Personagem sem Humanoid/raiz.","Character has no Humanoid/root."); return end
 for _,model in ipairs(candidates) do
  local _,r=parts(model)
  local distance=r and (r.Position-root.Position).Magnitude or math.huge
  if distance<dist then best,dist=model,distance end
 end
 if best then target_control:SetValue(best.Name)
 else notice("Nenhum NPC reconhecido no raio. Copie o diagnóstico.","No recognized NPC in range. Copy diagnostics.") end
end)
button(status,"Iniciar combate no alvo selecionado","Start combat on selected target",function()
 if flags.TargetName=="—" then notice("Selecione um NPC primeiro.","Select an NPC first."); return end
 if type(mouse1press)~="function" or type(mouse1release)~="function" then
  notice("Cliques do executor indisponíveis.","Executor clicks unavailable."); return
 end
 for _,k in ipairs({"Attack","Farm","Lock"}) do app.Options[k]:SetValue(true) end
 if next(profiles) then app.Options.Counter:SetValue(true) end
 window:SetOpen(false)
end)
status:AddLabel(text("Escolha um NPC. Farm aproxima em linha direta; ligue o ataque separadamente. Não distingue bosses de NPCs comuns.","Choose an NPC. Farm approaches directly; enable attack separately. Bosses and ordinary NPCs are not classified."),{Height=110})
local defense=window:AddTab("Defense & Parry")
local timing=group(defense,"Counter por animação","Animation counter")
local counter_toggle=toggle(timing,"Counter","Auto parry / counter · perfis","Auto parry / counter · profiles")
counter_toggle.Callback=function(value) flags.Counter=value; table.clear(pending_parries) end
box(timing,"CounterKey","Tecla de counter","Counter key","F")
slider(timing,"CounterRange","Alcance de counter","Counter range",12,2,30)
slider(timing,"Hold","Duração da tecla (s)","Key hold time (s)",0.08,0.02,0.5)
slider(timing,"Cooldown","Intervalo mínimo (s)","Minimum interval (s)",1,0.1,10)
slider(timing,"Lead","Antecipação (s)","Lead time (s)",0,0,0.3)
local calibration=group(defense,"Calibração manual","Manual calibration","Right")
local anim_label=calibration:AddLabel("—",{Height=70})
local animation_choice=control(calibration,"AddDropdown","ObservedAnimation","Animações observadas","Observed animations","—",{Values={"—"}})
refresh_animation_choices=function()
 local values={"—"}
 for id,name in pairs(animation_history) do values[#values+1]=id.." / "..name end
 table.sort(values,function(a,b) return a<b end)
 animation_choice:SetValues(values)
end
animation_choice.Callback=function(value)
 flags.ObservedAnimation=value
 local id=value:match("^(%d+)")
 if id then
  app.Options.AnimationId:SetValue(id)
  if profiles[id] then app.Options.Delay:SetValue(profiles[id]) end
 end
end
button(calibration,"Atualizar lista de animações","Refresh animation list",refresh_animation_choices)
box(calibration,"AnimationId","ID da animação","Animation ID")
slider(calibration,"Delay","Atraso desde o início (s)","Delay from animation start (s)",0.35,0,3)
button(calibration,"Copiar última animação observada","Use latest observed animation",function()
 if observed then app.Options.AnimationId:SetValue(observed.id) end
end)
button(calibration,"Salvar perfil da animação","Save animation profile",function()
 local id=flags.AnimationId:match("(%d+)")
 if not id then notice("Informe um ID numérico.","Enter a numeric ID."); return end
 profiles[id]=flags.Delay
 table.clear(pending_parries)
 notice("Perfil salvo. Valide o tempo no jogo.","Profile saved. Validate timing in game.")
end)
button(calibration,"Remover perfil","Remove profile",function()
 local id=flags.AnimationId:match("(%d+)"); if id then profiles[id]=nil end
end)
calibration:AddLabel(text("Sem perfis, não envia counter. A última animação pode ser caminhada ou idle: confirme que é um golpe. Tempos são hipóteses até testar.","No profiles means no counter input. Latest animation may be walk or idle: verify it is an attack. Timings require testing."),{Height=110})
local appearance=window:AddTab("Appearance")
local style=group(appearance,"Estilo e idioma","Style and language")
local theme=control(style,"AddDropdown","Theme","Tema","Theme","Nebula",{Values={"Nebula","Oceano","Esmeralda","Obsidiana","Aurora clara"}})
local alpha=slider(style,"Transparency","Transparência (%)","Transparency (%)",8,0,75)
local accent=box(style,"Accent","Destaque (#RRGGBB)","Accent (#RRGGBB)")
local background=box(style,"Background","Fundo (#RRGGBB)","Background (#RRGGBB)")
for _,entry in ipairs({{theme,"Theme"},{alpha,"Transparency"},{accent,"Accent"},{background,"Background"}}) do
 entry[1].Callback=function(v)
  if (entry[2]=="Accent" or entry[2]=="Background") and v~="" and not v:match("^#?%x%x%x%x%x%x$") then
   notice("Use #RRGGBB."); return
  end
  flags[entry[2]]=v
  app:SetAppearance(flags.Theme,flags.Transparency,flags.Accent,flags.Background)
 end
end
local language=control(style,"AddDropdown","Language","Idioma","Language","Português",{Values={"Português","English"}})
language.Callback=function(v) flags.Language=v; app:SetLanguage(v) end
quest=create_quest_tools(app,window,{
 text=text,group=group,control=control,button=button,slider=slider,toggle=toggle,box=box,
 flags=flags,player=player,parts=parts,notice=notice,stop=stop,ready=ready,
 release_all=release_all,vk=vk,pulse=pulse,
})
local settings=window:AddTab("Settings")
local session=group(settings,"Sessão e perfis","Session and profiles")
local diagnostic_card=group(settings,"Diagnóstico real","Runtime diagnostics","Right")
local diagnostic_label=diagnostic_card:AddLabel("—",{Height=120})
local function schedule_input(key)
 stop(); window:SetOpen(false)
 pending_input_test={key=key,due=os.clock()+1}
 notice("Teste em 1 segundo. Mantenha Roblox em foco. F6 cancela.","Test in 1 second. Keep Roblox focused. F6 cancels.")
end
button(diagnostic_card,"Testar um ataque · clique esquerdo","Test one attack · left click",function()schedule_input("M1")end)
button(diagnostic_card,"Testar counter · tecla configurada","Test counter · configured key",function()
 local key=vk(flags.CounterKey); if key then schedule_input(key) end
end)
button(diagnostic_card,"Testar equipar · X","Test equip · X",function()schedule_input(0x58)end)
diagnostic_card:AddLabel(text("Estes testes enviam uma única entrada e não exigem alvo. Uma chamada aceita pelo executor não comprova que o jogo executou a ação.","These tests send one input and need no target. An accepted executor call does not prove the game performed the action."),{Height=100})
button(session,"Parar tudo · F6","Stop all · F6",stop)
button(session,"Descarregar · F9","Unload · F9",function() app:Unload() end)
button(session,"Salvar configuração","Save settings",function()
 if type(writefile)~="function" then notice("writefile indisponível.","writefile unavailable."); return end
 local saved=table.clone(flags); for _,k in ipairs(active_keys) do saved[k]=false end
 writefile("ZyonVV-config.json",http:JSONEncode({settings=saved,profiles=profiles,waypoint=quest.waypoint,version=2}))
 notice("Configuração salva.","Settings saved.")
end)
button(session,"Carregar configuração","Load settings",function()
 if type(readfile)~="function" then notice("readfile indisponível.","readfile unavailable."); return end
 local data=http:JSONDecode(readfile("ZyonVV-config.json")); assert(type(data)=="table" and type(data.settings)=="table","Invalid configuration")
 stop()
 for k,v in pairs(data.settings) do
  if not table.find(active_keys,k) and app.Options[k] and type(v)==type(flags[k]) then app.Options[k]:SetValue(v) end
 end
 table.clear(profiles)
 for id,delay in pairs(type(data.profiles)=="table" and data.profiles or {}) do
  if type(id)=="string" and id:match("^%d+$") and type(delay)=="number" and delay>=0 and delay<=3 then profiles[id]=delay end
 end
 local point=data.waypoint
 if type(point)=="table" and type(point.place)=="number" then
  local valid=true
  for _,k in ipairs({"x","y","z"}) do if type(point[k])~="number" or point[k]~=point[k] or math.abs(point[k])>10000000 then valid=false end end
  if valid then quest.waypoint=point end
 end
 notice("Perfil carregado; automações desligadas.","Profile loaded; automation remains off.")
end)
button(session,"Copiar diagnóstico","Copy diagnostics",function() app:Diagnostics() end)
local function on_animation(track)
 local id=track.Animation and track.Animation.AnimationId:match("(%d+)")
 if not id then return end
 observed={id=id}; anim_label:SetText(id.." / "..track.Name)
 counters.animations+=1
 if not animation_history[id] then
  local n=0; for _ in pairs(animation_history) do n+=1 end
  if n<200 then animation_history[id]=track.Name end
 end
 local delay=profiles[id]
 if not delay or not flags.Counter or not ready() then return end
 pending_parries[track]={token=generation,model=target,delay=delay,expires=os.clock()+6}
end
local function parry_tick(now)
 if not ready() or not flags.Counter then table.clear(pending_parries); return end
 for track,p in pairs(pending_parries) do
  if p.token~=generation or p.model~=target or not track.IsPlaying or now>p.expires then
   pending_parries[track]=nil
  else
   local speed=track.Speed
   local due=math.max(0,p.delay-flags.Lead*math.max(0,speed))
   if speed>0 and track.TimePosition>=due then
    pending_parries[track]=nil
    if in_range(flags.CounterRange) and now>=(next_action.counter or 0) then
     local key=vk(flags.CounterKey)
     if key and pulse(key,flags.Hold) then counters.parry+=1; next_action.counter=now+flags.Cooldown end
    end
   end
  end
 end
end
local function update_target()
 local _,r=parts(player.Character); local best,distance=nil,flags.ScanRange
 if r then
  for _,m in ipairs(candidates) do
   local _,tr=parts(m)
   if tr and m.Name==flags.TargetName then
    local d=(r.Position-tr.Position).Magnitude
    if d<distance then best,distance=m,d end
   end
  end
 end
 local h=best and best:FindFirstChildOfClass("Humanoid")
 local animator=h and h:FindFirstChildOfClass("Animator")
 if best~=target or animator~=watched_animator then
  generation+=1; target=best; watched_animator=animator
  if animation_connection then animation_connection:Disconnect(); animation_connection=nil end
  if animator then animation_connection=animator.AnimationPlayed:Connect(on_animation) end
 end
 target_label:SetText(target and (target.Name.." / "..math.floor(distance).." studs") or app:Translate("Sem alvo"))
end
local skill_index=0
local function tick()
 local now=os.clock()
 if pending_input_test and now>=pending_input_test.due then
  local test=pending_input_test; pending_input_test=nil
  if ready() then
   local ok=pulse(test.key,0.08)
   app.ModuleStatus.InputTest=ok and "entrada enviada; confirme resultado no jogo" or "falha ao enviar"
  else app.ModuleStatus.InputTest="cancelado: painel, diálogo ou campo de texto ativo" end
 end
 if now-last_scan>=3 then last_scan=now; scan() end
 update_target()
 if quest:Tick(now) then latest_reason="Quest: "..quest.phase; table.clear(pending_parries); return end
 if not ready() then
  latest_reason=app.Open and "Painel aberto: ações pausadas" or "Diálogo ou campo de texto: ações pausadas"
  table.clear(pending_parries)
  release_all()
  if was_moving then local h,r=parts(player.Character); if h then h:MoveTo(r.Position) end; was_moving=false end
  return
 end
 local h,r=parts(player.Character)
 if not h then latest_reason="Personagem ausente ou sem Humanoid/raiz"; return end
 latest_reason=target and "Alvo reconhecido; conferindo alcance e opções" or "Sem alvo: selecione NPC carregado dentro do raio"
 parry_tick(now)
 if was_moving and (not flags.Farm or not target) then h:MoveTo(r.Position); was_moving=false end
 if flags.Farm and target and now-last_move>=0.25 then
  last_move=now; local _,tr=parts(target)
  if tr then
   local delta=r.Position-tr.Position
   h:MoveTo(delta.Magnitude>flags.Distance and tr.Position+delta.Unit*flags.Distance or r.Position)
   was_moving=true
  end
 end
 if not in_range(flags.Range) then
  if target then latest_reason="Alvo fora do alcance de ataque" end
  return
 end
 latest_reason=flags.Attack and "Ataque ativo" or "Ataque desligado"
 if flags.Counter and held[vk(flags.CounterKey)] then return end
 if flags.Attack and now>=(next_action.attack or 0) then
  next_action.attack=now+flags.AttackInterval; if pulse("M1",0.04) then counters.attack+=1 end
 end
 if flags.Skills and now>=(next_action.skill or 0) then
  local keys={}; for name in flags.SkillKeys:gmatch("[^,%s]+") do local key=vk(name); if key then keys[#keys+1]=key end end
  next_action.skill=now+flags.SkillInterval
  if #keys>0 then skill_index=skill_index%#keys+1; if pulse(keys[skill_index],0.06) then counters.skill+=1 end end
 end
end
local function refresh_diagnostics()
 local count=0; for _ in pairs(profiles) do count+=1 end
 app.ModuleStatus.Runtime=latest_reason
 app.ModuleStatus.Target="selected="..tostring(flags.TargetName).." detected="..tostring(target and target.Name).." candidates="..#candidates
 app.ModuleStatus.Profiles="registered="..count.." observed_events="..counters.animations
 app.ModuleStatus.Sent="attack="..counters.attack.." parry="..counters.parry.." skills="..counters.skill.." errors="..counters.input_errors
 app.ModuleStatus.Quest=quest.phase.." / "..tostring(quest.status_pt or "idle")
 local toggles={}; for _,key in ipairs(active_keys)do toggles[#toggles+1]=key.."="..tostring(flags[key])end
 app.ModuleStatus.Toggles=table.concat(toggles," ")
 app.ModuleStatus.NPCCatalog=table.concat(npc_catalog," | ")
 diagnostic_label:SetText(latest_reason.."\n"..app.ModuleStatus.Target.."\n"..app.ModuleStatus.Sent)
end
function app:Diagnostics()
 refresh_diagnostics()
 local lines={"ZYON VV / 0.2", "PlaceId: "..tostring(game.PlaceId),"GameId: "..tostring(game.GameId),"Contadores medem entradas enviadas, não sucesso no servidor."}
 local capabilities={keypress=keypress,keyrelease=keyrelease,mouse1press=mouse1press,mouse1release=mouse1release,writefile=writefile,readfile=readfile,setclipboard=setclipboard}
 for _,name in ipairs({"keypress","keyrelease","mouse1press","mouse1release","writefile","readfile","setclipboard"}) do
  lines[#lines+1]=name..": "..tostring(type(capabilities[name])=="function")
 end
 for name,value in pairs(self.ModuleStatus)do lines[#lines+1]=name..": "..tostring(value)end
 for area,entry in pairs(self.Errors)do lines[#lines+1]="ERROR "..area..": "..entry.message end
 local report=table.concat(lines,"\n")
 print(report)
 if type(setclipboard)=="function" then pcall(setclipboard,report) end
 if type(writefile)=="function" then pcall(writefile,"ZyonVV-diagnostico.txt",report) end
 notice("Diagnóstico enviado ao console.","Diagnostics sent to console.")
 return report
end
app:Connect(run.Heartbeat,function()
 app:Run("VV controller",tick)
 if os.clock()-last_report>=1 then last_report=os.clock(); refresh_diagnostics() end
end)
app:Connect(run.RenderStepped,function()
 if ready() and flags.Lock and target then
  local _,r=parts(target); local camera=workspace.CurrentCamera
  if r and camera and (camera.CFrame.Position-r.Position).Magnitude>0.1 then
   camera.CFrame=CFrame.lookAt(camera.CFrame.Position,r.Position+Vector3.new(0,1,0))
  end
 end
end)
app:Connect(input.InputBegan,function(event,processed)
 if not processed and event.KeyCode==Enum.KeyCode.F6 then stop() end
end)
app:Connect(player.CharacterAdded,stop)
app.OnUnload=function()
 stop(); if animation_connection then animation_connection:Disconnect() end
 if env.ZyonVV==app then env.ZyonVV=nil end
end
arcane_english["Sem alvo"]="No target"
app:SetAppearance(flags.Theme,flags.Transparency,flags.Accent,flags.Background)
app.Status="VV 0.2 / quest assistance + animation parry / in-game validation pending"
app.ModuleStatus.Input="keypress="..tostring(type(keypress)=="function").." mouse1press="..tostring(type(mouse1press)=="function")
app.ModuleStatus.Profiles="Manual animation calibration required"
scan()
notice("Protótipo carregado. Selecione um NPC e calibre o counter. F6 para parar.","Prototype loaded. Select an NPC and calibrate counter. F6 stops all.")
return app


