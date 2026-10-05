# Pathfinding em grids, waypoints e navmeshes

Laboratório **2D**, com 32 passos para 120 minutos. Use Godot **4.7.2 padrão**, com GDScript. O projeto usa recursos nativos e não depende de plugins ou dos repositórios das aulas anteriores.

## Início

A pasta entregue abre em `main`, com a solução do professor. Para fazer a atividade, copie o repositório completo com `.git` ou faça um clone, entre em `pathfinding-godot` e execute:

```sh
git switch starter
git switch -c minha-pathfinding
```

Escolha outro nome se essa branch existir. Importe `project.godot` na Godot e pressione F5. A starter abre o mapa, mas ainda não calcula rotas. Siga `docs/ROTEIRO.md` em paralelo aos slides.

## As três etapas

| Etapa | Recurso nativo | Funções em aluno/ |
|---|---|---|
| A: grid | AStarGrid2D | grade.gd: configurar, bloquear, calcular |
| B: waypoints | AStar2D e Marker2D | waypoints.gd: adicionar, conectar, calcular |
| C: navmesh | NavigationRegion2D, NavigationPolygon e NavigationServer2D | malha.gd: calcular |

O aluno completa **sete funções curtas**. As constantes, referências e a conversão `celula` já estão prontas. A atividade também inclui editar uma conexão e refazer o bake pelo editor. Cada etapa tem uma tag com a solução.

## Responsabilidades

- `aluno/`: configuração e consulta das três representações.
- `apoio/`: movimento físico, controles, visualização, ajuste do destino e tratamento de rota incompleta.
- `cenas/`: mapa, colisões, marcadores e `malha.tres` com bake inicial.
- `verificacao/`: testes prontos para executar com F6.
- `docs/`: roteiro, entrega, relação com a teoria e fontes.

**Strategy:** cada planejador oferece `calcular(origem, destino) -> PackedVector2Array`. O apoio escolhe o nó sem alterar o seguidor. Não há uma interface de classe-base, fábrica ou framework. A busca interna é da Godot.

**Separação de responsabilidades:** uma consulta gera os pontos, o agente os percorre e o visual desenha a rota. O movimento não inicia buscas. A rota fica guardada até um novo pedido. Como o mapa é estático, não é necessário implementar uma Dirty Flag genérica.

## Controles

| Controle | Efeito |
|---|---|
| 1 | Seleciona grid |
| 2 | Seleciona waypoints |
| 3 | Seleciona navmesh |
| R | Consulta a rota de referência |
| I | Consulta a ilha isolada |
| Clique esquerdo | Escolhe um destino dentro da área do mapa |

Cada consulta reinicia o agente na origem fixa `(168, 384)`, inclusive durante o movimento. Isso permite comparar representações com o mesmo ponto de partida. Mudar o modo limpa a rota e zera o contador.

Em grid, o clique escolhe o centro da célula. Em waypoints, escolhe o Marker2D mais próximo. Na navmesh, o destino é a posição clicada. O alvo verde mostra o destino efetivamente pedido. Cliques fora da área são ignorados.

O contador **Consultas** aumenta somente a cada pedido. **Pontos da rota** mede a quantidade de posições no resultado, não vértices do grafo ou nós expandidos. **Comprimento** soma as distâncias entre os pontos, em pixels.

## O mapa e os custos de referência

Área de 960 × 432 px, com grade de 20 × 9 células de 48 px. Três StaticBody2D formam a parede central e a separação da ilha. Dezesseis células são bloqueadas. O agente tem raio 10 px e rapidez 180 px/s.

| Modo após pressionar R | Pontos | Comprimento |
|---|---:|---:|
| Grid | 24 | 1.104 px |
| Waypoints | 6 | 1.152 px |
| Navmesh | 4 | aproximadamente 864 px |

Na grade, o custo mínimo é 23 passos ortogonais de 48 px. A estimativa Manhattan é coerente com esse movimento. O grafo de waypoints tem nove pontos e conexões bidirecionais. Seus dois contornos da parede têm o mesmo comprimento. As arestas usam distância geométrica e peso 1.

A navmesh resulta de um contorno externo com obstruções obtidas dos StaticBody2D filhos de `Mapa/Regiao`. O recurso `cenas/malha.tres` usa **Agent Radius 12** e **Parsed Geometry Type: Static Colliders**. Selecione Regiao no editor 2D, execute **Bake NavigationPolygon** na barra superior, aguarde e salve a cena e o recurso. O bake atual gera seis polígonos navegáveis, incluindo uma área isolada.

P8 pertence à ilha e não possui conexões. A mesma área é inacessível na grade e na malha. “Sem rota” limpa o resultado anterior e mantém o agente parado. A navegação nativa pode devolver um caminho parcial ou projetar o destino. O apoio rejeita o resultado quando o último ponto fica a mais de 2 px do destino pedido. As consultas à malha aguardam a sincronização do servidor.

## Verificação da atividade

Pare o jogo, abra uma cena abaixo e pressione **F6**:

| Cena | Resultado esperado | Duração aproximada |
|---|---|---|
| verificacao/etapa_a.tscn | 27/27 | 11 s |
| verificacao/etapa_b.tscn | 40/40 | 22 s |
| verificacao/etapa_c.tscn | 50/50 | 33 s |

A starter só implementa a base, então executar uma etapa ainda incompleta deve apontar falhas. Procure `FALHA:` no painel Output para identificar o caso. F5 sempre abre o laboratório.

Alternativa de terminal, com `godot` no PATH:

```sh
godot --headless --path . --editor --import
godot --headless --path . --fixed-fps 60 --script res://verificacao/executar.gd -- --etapa=3
```

Use `--etapa=1` ou `--etapa=2` durante a aula. Sem esse argumento, o verificador usa o checkpoint indicado em `etapa.txt`, que não muda automaticamente quando o aluno escreve código. Prefira o argumento explícito ou as cenas de F6. No macOS, a instalação usada está em `/Applications/Godot.app/Contents/MacOS/Godot`.

## Referências Git

| Referência | Conteúdo |
|---|---|
| branch starter | Base pronta, funções do exercício vazias |
| tag etapa-a-grid | Grid completo |
| tag etapa-b-waypoints | Grid e waypoints completos |
| tag etapa-c-navmesh | Todas as representações completas |
| branch main | Mesma solução da etapa C |

Para retomar de uma solução sem perder sua tentativa, pare o jogo e execute:

```sh
git stash push -u
git switch -c retomada-b etapa-b-waypoints
```

Escolha outro nome se a branch existir. A tentativa fica guardada no stash. Não há remoto configurado e a entrega não foi publicada no GitHub.

## Escolhas e limites

A prática usa A* nativo. Não reimplementa a busca, não mostra listas abertas/fechadas nem conta expansões. Também não implementa BFS, Dijkstra, escalonamento ou cache global. Veja a relação com a aula teórica em `docs/TEORIA.md`.

O seguidor é cinemático e limita cada deslocamento ao ponto atual, mantendo os cantos da rota. Não reutiliza o Arrive inercial de Steering, pois uma curva poderia cortar a quina de um obstáculo. A atividade mantém a separação entre busca e movimento.

O exemplo usa um agente e mapa estático. Não há avoidance entre agentes nem atualização automática da navegação após mudanças no mundo. AStar2D não confere a colisão das conexões: os segmentos dos waypoints foram posicionados manualmente. A margem da navmesh e o tamanho das células foram escolhidos para o corpo da aula.

As malhas desta entrega são navmeshes 2D. Uma versão 3D precisaria de NavigationRegion3D, NavigationMesh e um cenário próprio. Os resultados e tempos desta distribuição foram validados no macOS com Godot 4.7.2, sem execução em Windows ou Linux.
