# Roteiro de Pathfinding

32 passos / 120 minutos. Conteúdo correspondente aos slides e ao guia.


## 1. Sua cópia de trabalho

Local: Terminal, dentro de pathfinding-godot. Tempo: 3 minutos.

A starter contém o mapa pronto e as funções de busca por completar.

- Crie sua branch com os comandos abaixo.

```
git switch starter
git switch -c minha-pathfinding
```

Confira: Você está em minha-pathfinding, criada a partir da starter.

Distribua um clone ou o repositório completo, incluindo .git. Escolha outro nome se minha-pathfinding já existir. main contém a solução para o professor. Este projeto é independente dos laboratórios anteriores.


## 2. Importação e cena inicial

Local: Godot, gerenciador de projetos. Tempo: 3 minutos.

O agente e as três representações já estão na mesma cena.

- Importe project.godot e abra o projeto.

- Execute com F5 e pressione R no jogo.

Confira: Na starter, aparece Sem rota porque as funções ainda estão vazias.

A edição padrão da Godot 4.7.2 usa os scripts GDScript desta aula. Aguarde a importação. Não instale addons. F5 executa cenas/laboratorio.tscn. Os modos 1, 2 e 3 serão completados em sequência.


## 3. Os arquivos da atividade

Local: Painel FileSystem, pasta aluno/. Tempo: 3 minutos.

Você implementará sete funções usando recursos nativos da Godot.

- Abra aluno/grade.gd, waypoints.gd e malha.gd.

- Localize apoio/ e verificacao/.

Confira: Busca fica em aluno/. Movimento, controles e visuais já estão prontos.

Preserve extends Node2D, constantes, variáveis e funções não indicadas. A busca usa AStarGrid2D, AStar2D e NavigationServer2D. Nesta prática não escreveremos o algoritmo A* interno nem uma fila de prioridade. Essa escolha reduz o código e concentra a atividade nas representações.


## 4. Uma interface para três mapas

Local: cenas/laboratorio.tscn, nó Planejadores. Tempo: 3 minutos.

Cada planejador recebe origem e destino e devolve os pontos da rota.

- Expanda Planejadores.

- Compare a assinatura calcular nos três scripts.

```
calcular(origem, destino) -> PackedVector2Array
```

Confira: O apoio pode trocar o planejador e manter o mesmo seguidor.

Strategy aparece como três nós com a mesma operação. Não há classe-base obrigatória, fábrica ou framework. As coordenadas da entrada e da saída são posições globais 2D. O mapa da aula está na origem da cena, sem transformações adicionais.


## 5. A grade e a heurística

Local: aluno/grade.gd, função configurar. Tempo: 6 minutos.

A grade usa quatro direções e estimativa de Manhattan.

- Substitua configurar pelo trecho abaixo e salve.

```
func configurar() -> void:
    grade.region = Rect2i(0, 0, 20, 9)
    grade.cell_size = Vector2(CELULA, CELULA)
    grade.offset = ORIGEM + Vector2(24, 24)
    grade.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    grade.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
    grade.update()
```

Confira: Cada célula mede 48 px e o ponto da rota fica no seu centro.

region usa coordenadas de célula. offset posiciona os centros em coordenadas do mundo. update cria a grade e precisa vir antes dos bloqueios. O custo padrão de uma aresta horizontal ou vertical é 48. Manhattan é coerente com quatro direções. Fonte: https://docs.godotengine.org/en/stable/classes/class_astargrid2d.html


## 6. As células bloqueadas

Local: aluno/grade.gd, função bloquear. Tempo: 4 minutos.

O apoio entrega as células ocupadas pelos corpos das paredes.

- Substitua bloquear pelo trecho abaixo e salve.

```
func bloquear(celulas: Array) -> void:
    for id in celulas:
        grade.set_point_solid(id)
```

Confira: Os 16 centros ocupados pelas paredes deixam de ser caminháveis.

As paredes estão alinhadas à grade. O apoio calcula as células a partir dos retângulos de colisão. Não chame update depois de bloquear: update pode reconstruir os dados e apagar bloqueios. Nenhuma diagonal está permitida nesta atividade.


## 7. A consulta na grade

Local: aluno/grade.gd, função calcular. Tempo: 6 minutos.

A consulta converte posições para células e rejeita extremos inválidos.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(origem: Vector2, destino: Vector2) -> PackedVector2Array:
    var a = celula(origem)
    var b = celula(destino)
    if not grade.is_in_boundsv(a) or not grade.is_in_boundsv(b):
        return PackedVector2Array()
    if grade.is_point_solid(a) or grade.is_point_solid(b):
        return PackedVector2Array()
    return grade.get_point_path(a, b)
```

Confira: O resultado contém os centros das células do caminho.

celula já está pronta e usa ORIGEM e CELULA. Os testes de limite vêm antes de is_point_solid para evitar consultar um índice inexistente. PackedVector2Array vazio representa ausência de rota. get_point_path usa a configuração nativa de A*.


## 8. O caminho quadriculado

Local: Editor da Godot e janela do jogo. Tempo: 4 minutos.

A rota passa apenas entre centros de células vizinhas.

- Execute com F5 e pressione R.

Confira: A rota de referência tem 24 pontos e comprimento de 1.104 px.

O agente parte de (168,384) e busca (984,384). São 23 passos de 48 px. Caminhos empatados podem passar por cima ou por baixo da parede. O apoio reinicia o agente na origem a cada consulta para facilitar comparações.


## 9. Destino sem conexão

Local: Jogo, modo 1 Grid. Tempo: 3 minutos.

Uma célula livre pode estar isolada das outras.

- Pressione I para escolher a ilha.

- Pressione R para voltar à rota de referência.

Confira: Na ilha, a rota fica vazia e o agente permanece na origem.

A ilha é o espaço no canto inferior direito. Ela contém células livres, mas não há acesso pela grade. Uma busca sem rota é um resultado válido, não uma exceção. Cliques no mapa selecionam o centro da célula.


## 10. Verificação da grade

Local: verificacao/etapa_a.tscn. Tempo: 4 minutos.

O teste compara a rota com um custo mínimo conhecido.

- Abra etapa_a.tscn e pressione F6.

Confira: A janela termina com 27/27 verificações passaram.

F6 executa a cena aberta. Aguarde cerca de 11 segundos. O teste também confere bloqueios, origem igual ao destino, índices inválidos e o percurso físico. Veja FALHA no painel Output se necessário.


## 11. Registro da etapa A

Local: Terminal, dentro de pathfinding-godot. Tempo: 2 minutos.

Salve a grade antes de montar o grafo de waypoints.

- Execute os comandos abaixo.

```
git add aluno/grade.gd
git commit -m "Etapa A: Grid"
```

Confira: A implementação de grid fica salva na sua branch.

Para retomar da solução, preserve a tentativa com git stash push -u e use git switch -c retomada-a etapa-a-grid. Escolha um nome novo para a branch.


## 12. Os pontos e as conexões

Local: cenas/laboratorio.tscn, Mapa/Pontos. Tempo: 3 minutos.

Cada Marker2D representa um vértice com um número.

- Expanda Pontos e selecione P1.

- No Inspector, confira Vizinhos: 2 e 7.

Confira: P1 se liga a P2 e P7. P8 está isolado.

O número é o índice do filho: P0 é 0, P1 é 1 e assim por diante. Não reordene os filhos durante a atividade. As conexões foram escolhidas para que seus segmentos não atravessem paredes. Proximidade por si só não cria arestas.


## 13. Registro dos waypoints

Local: aluno/waypoints.gd, função adicionar. Tempo: 5 minutos.

AStar2D guarda um identificador e uma posição para cada ponto.

- Substitua adicionar pelo trecho abaixo e salve.

```
func adicionar() -> void:
    for ponto in pontos:
        grafo.add_point(ponto.get_index(), ponto.global_position)
```

Confira: Os nove Marker2D passam a existir no grafo de busca.

pontos já resolve os filhos de Mapa/Pontos. get_index fornece o identificador. global_position fornece a posição no mundo. O grafo deve receber todos os pontos antes das conexões. Fonte: https://docs.godotengine.org/en/stable/classes/class_astar2d.html


## 14. As arestas do grafo

Local: aluno/waypoints.gd, função conectar. Tempo: 5 minutos.

As listas Vizinhos definem quais trajetos são permitidos.

- Substitua conectar pelo trecho abaixo e salve.

```
func conectar() -> void:
    for ponto in pontos:
        for vizinho in ponto.vizinhos:
            grafo.connect_points(ponto.get_index(), vizinho)
```

Confira: Cada conexão permite ir e voltar pelo mesmo segmento.

connect_points usa conexão bidirecional por padrão. Por isso basta registrar cada par uma vez. A aula usa custo geométrico padrão e peso 1 em todos os pontos. AStar2D não inspeciona paredes: quem monta as arestas precisa garantir a passagem.


## 15. A consulta por waypoints

Local: aluno/waypoints.gd, função calcular. Tempo: 5 minutos.

A busca usa os pontos mais próximos das posições recebidas.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(origem: Vector2, destino: Vector2) -> PackedVector2Array:
    if grafo.get_point_count() == 0:
        return PackedVector2Array()
    var a = grafo.get_closest_point(origem)
    var b = grafo.get_closest_point(destino)
    return grafo.get_point_path(a, b)
```

Confira: AStar2D devolve as posições dos vértices escolhidos.

O apoio ajusta o clique ao waypoint mais próximo e mostra o alvo nessa posição. O agente sempre recomeça em P0, que coincide com a origem. Esse ajuste evita prometer chegada exata a qualquer ponto fora do grafo. O teste de grafo vazio protege uma configuração ainda não montada.


## 16. O percurso pelas arestas

Local: Jogo, modo 2 Waypoints. Tempo: 4 minutos.

O agente percorre as conexões desenhadas entre os marcadores.

- Execute com F5, pressione 2 e depois R.

Confira: A rota de referência usa 6 pontos e mede 1.152 px.

A rota superior e a inferior têm o mesmo custo. A disposição manual dos waypoints produz uma rota mais longa que a grade deste exemplo. Poucos vértices não significam automaticamente um trajeto mais curto.


## 17. Uma conexão a menos

Local: cenas/laboratorio.tscn, Mapa/Pontos/P2. Tempo: 4 minutos.

Sem a ligação entre P2 e P3, resta o caminho inferior.

- Em Vizinhos, mude o tamanho da lista para 0 e salve.

- Execute com F5, pressione 2 e depois R.

Confira: O caminho passa por P7 e P6.

P2 possui apenas o vizinho 3 na configuração original. Esvaziar a lista remove essa aresta ao montar o grafo na próxima execução. O número de pontos permanece nove. O custo continua 1.152 px, pois as duas alternativas têm o mesmo comprimento.


## 18. Restauração e verificação

Local: Mapa/Pontos/P2 e verificacao/etapa_b.tscn. Tempo: 4 minutos.

Restaure o grafo de referência antes do teste.

- Pare o jogo e restaure Vizinhos para tamanho 1, valor 3. Salve.

- Abra etapa_b.tscn e pressione F6.

Confira: A janela termina com 40/40 verificações passaram.

A verificação demora cerca de 22 segundos em velocidade normal. Além da consulta, ela verifica ida e volta, remoção de conexão, aumento de custo e execução física. Os testes usam a configuração original do mapa.


## 19. Registro da etapa B

Local: Terminal, dentro de pathfinding-godot. Tempo: 2 minutos.

A implementação dos waypoints fica em um único script.

- Execute os comandos abaixo.

```
git add aluno/waypoints.gd
git commit -m "Etapa B: Waypoints"
```

Confira: A etapa B fica salva sem alterar o movimento do agente.

Para retomar da solução, preserve a tentativa com git stash push -u e use git switch -c retomada-b etapa-b-waypoints. A edição temporária de P2 deve estar restaurada.


## 20. A malha de navegação 2D

Local: cenas/laboratorio.tscn, Mapa/Regiao. Tempo: 3 minutos.

NavigationRegion2D usa um recurso NavigationPolygon.

- Selecione Regiao.

- No Inspector, abra Navigation Polygon.

Confira: O recurso cenas/malha.tres contém o contorno da área caminhável.

Mesh aqui significa malha de navegação 2D, não malha visual 3D. O contorno externo já está desenhado e o recurso já possui um bake inicial. A busca nativa trabalha sobre essa representação. Referência: https://docs.godotengine.org/en/stable/classes/class_navigationpolygon.html


## 21. Espaço para o corpo

Local: Inspector, recurso Navigation Polygon de Regiao. Tempo: 4 minutos.

O bake deixa uma margem para o agente não encostar nas paredes.

- Confira Agent Radius igual a 12.

- Confira Parsed Geometry Type igual a Static Colliders.

Confira: O bake considera os três corpos de parede, que são filhos de Regiao.

O corpo do agente tem raio 10 px. A margem de 12 px é maior que o corpo. O contorno delimita o chão e os StaticBody2D retiram áreas. Parsed Collision Mask inclui a camada 1. Não use somente a aparência do Polygon2D como prova de colisão ou de navegação.


## 22. O bake da malha

Local: Editor 2D, com Mapa/Regiao selecionado. Tempo: 5 minutos.

O bake transforma o contorno e as paredes em polígonos navegáveis.

- Clique em Bake NavigationPolygon na barra superior do editor 2D.

- Aguarde a conclusão e salve a cena e o recurso.

Confira: A área navegável contorna as paredes e mantém a ilha separada.

Dependendo do idioma do editor, o rótulo aparece traduzido. As opções de bake surgem ao selecionar o NavigationRegion2D. Selecione o recurso malha.tres no FileSystem e use o comando de salvar do Inspector caso ele permaneça marcado como modificado. Fonte: https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationmeshes.html


## 23. A consulta na navmesh

Local: aluno/malha.gd, função calcular. Tempo: 5 minutos.

NavigationServer2D consulta o mapa de navegação da cena.

- Substitua calcular pelo trecho abaixo e salve.

```
func calcular(origem: Vector2, destino: Vector2) -> PackedVector2Array:
    var mapa = get_world_2d().navigation_map
    return NavigationServer2D.map_get_path(mapa, origem, destino, true)
```

Confira: A consulta devolve uma rota otimizada na malha.

O último argumento true otimiza o caminho pelas passagens entre polígonos. O apoio espera a sincronização do mapa e rejeita caminhos que terminem longe do destino pedido. Fonte: https://docs.godotengine.org/en/stable/classes/class_navigationserver2d.html


## 24. O percurso na malha

Local: Jogo, modo 3 Navmesh. Tempo: 4 minutos.

A rota pode cruzar o chão livre em qualquer ângulo.

- Execute com F5, pressione 3 e depois R.

Confira: Neste mapa, a rota tem 4 pontos e mede aproximadamente 864 px.

O valor usa o bake de referência com raio 12. O agente segue a mesma rotina usada nos outros modos. O número de pontos da rota não é o número de polígonos da malha nem o número de vértices examinados pela busca.


## 25. A ilha na navmesh

Local: Jogo, modo 3 Navmesh. Tempo: 3 minutos.

Uma região pode conter áreas navegáveis sem conexão entre si.

- Pressione I.

Confira: A rota some e o agente permanece na origem.

O servidor pode devolver uma rota parcial até o ponto alcançável mais próximo. O apoio só aceita uma rota cujo último ponto esteja a até 2 px do destino ajustado. A aplicação informa Sem rota e limpa o caminho anterior.


## 26. Busca e movimento separados

Local: apoio/agente.gd, função _physics_process. Tempo: 3 minutos.

O seguidor percorre os pontos que a busca já calculou.

- Localize a variável indice e a chamada move_and_slide.

Confira: Ao alcançar um ponto, indice avança para o próximo.

Este seguidor pronto é cinemático: limita o deslocamento ao ponto atual e preserva os cantos da rota. Não copia o Arrive inercial do laboratório de Steering, que poderia cortar uma quina. A ligação entre camadas permanece: busca fornece pontos, locomoção os percorre. Não há avoidance entre múltiplos agentes nesta aula.


## 27. Uma consulta por pedido

Local: Jogo, qualquer modo implementado. Tempo: 4 minutos.

A rota permanece guardada enquanto o agente a percorre.

- Pressione R e observe Consultas durante o movimento.

- Clique em outro destino caminhável.

Confira: O contador só aumenta quando você pede outra rota.

A aula usa mapa estático. O apoio calcula em pedir, guarda o resultado e não consulta no passo de física. Trocar de modo zera o contador. Cada pedido reinicia o agente em uma origem fixa, inclusive se ele ainda estava se movendo. Não há cache global nem Dirty Flag genérica.


## 28. Comparação das representações

Local: Jogo, modos 1, 2 e 3. Tempo: 4 minutos.

O mesmo mapa permite comparar a forma das três rotas.

- Em cada modo, pressione R e anote pontos e comprimento.

Confira: Grid: 24 e 1.104 px. Waypoints: 6 e 1.152 px. Navmesh: 4 e cerca de 864 px.

A diferença decorre do movimento permitido, das conexões manuais e das margens. Estes números caracterizam este mapa, não uma superioridade universal. Não compare tempo de CPU ou nós expandidos a partir do número de pontos da rota.


## 29. Verificação final

Local: verificacao/etapa_c.tscn. Tempo: 4 minutos.

O teste cobre rotas completas, ausência de rota e colisões reais.

- Abra etapa_c.tscn e pressione F6.

Confira: A janela termina com 50/50 verificações passaram.

A execução normal leva cerca de 33 segundos. Os três modos devem alcançar o destino sem contatos com as paredes. Se houver falha após editar a malha, confira Agent Radius, Static Colliders e refaça o bake.


## 30. Registro da etapa C

Local: Terminal, dentro de pathfinding-godot. Tempo: 2 minutos.

Salve a consulta da malha e os recursos editados na aula.

- Execute os comandos abaixo.

```
git add aluno/malha.gd cenas/
git commit -m "Etapa C: Navmesh"
```

Confira: Sua branch contém as três representações completas.

O bake pode regravar cenas/malha.tres. A restauração de P2 deve manter a configuração original. Para consultar a solução em outra branch, preserve sua tentativa e use git switch -c consulta-final etapa-c-navmesh.


## 31. Os limites do laboratório

Local: docs/TEORIA.md. Tempo: 3 minutos.

Este exercício usa as implementações nativas de busca.

- Leia as escolhas de escopo em TEORIA.md.

Confira: A prática cobre representações e consultas, sem reimplementar A*.

A teoria também propõe implementar A*, comparar heurísticas por expansões e escalonar buscas. Esses itens ficam fora desta prática para preservar a simplicidade solicitada. A demonstração é 2D, com um agente e mapa estático. NavigationServer3D e NavigationMesh são equivalentes para uma extensão 3D, que não integra esta entrega.


## 32. Entrega do exercício

Local: Sua branch e docs/ENTREGA.md. Tempo: 3 minutos.

A entrega reúne os scripts e as observações sobre os três mapas.

- Responda às perguntas de ENTREGA.md.

- Entregue sua branch e as respostas pelo canal da turma.

Confira: Explique as diferenças de rota, a ilha, o bake e o momento da consulta.

Não é necessário publicar no GitHub para executar o exercício. O canal e o prazo de entrega ficam a cargo do professor. A branch main e as três tags contêm as soluções para consulta.
