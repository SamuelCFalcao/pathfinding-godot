# Relação com a teoria e escolhas didáticas

Referência: `Módulo III - Encontro 3 - Pathfinding - Aula Teórica.pptx`, consultada em 05/10/2026. O arquivo original permanece preservado.

| Conteúdo teórico | Atividade |
|---|---|
| Slides 12–15: grade, waypoints, navmesh | Três representações do mesmo mapa |
| Slide 23: heurística adequada ao movimento | Grade ortogonal com Manhattan |
| Slides 37–38: separação de responsabilidades e testes | Interface calcular, seguidor independente e custos conhecidos |
| Slide 40: composição entre busca e movimento | Rota guardada e percorrida pelo agente |

A teoria sugere escrever A*, visualizar abertos/fechados e comparar expansões. Nesta aula prática, a prioridade é o pedido de código direto com elementos nativos da Godot. Usamos AStarGrid2D, AStar2D e NavigationServer2D. O aluno escreve sete funções de configuração e consulta. Não há um algoritmo A* próprio nem fila de prioridade.

A comparação mede a forma, a quantidade de pontos do resultado e o comprimento das rotas. Não mede vértices explorados, custo de CPU ou desempenho geral das representações. A navmesh tem seis polígonos no bake fornecido, mas a interface não usa esse número como medida do trabalho de busca.

A prática mostra consultas sob demanda em um mapa estático. Escalonamento, invalidação dinâmica de cache, BFS e Dijkstra ficam fora do escopo. Os três planejadores compartilham uma assinatura por convenção, sem um framework de grafos genérico.

O laboratório anterior de Steering usava aceleração. Aqui o seguidor pronto percorre segmentos sem arredondar as quinas. Isso mantém o corpo dentro do corredor navegável. A arquitetura continua separando busca, locomoção e apresentação, em um projeto independente.

Meshes aqui significa malhas de navegação 2D. As instruções não pressupõem conhecimento de modelagem 3D nem criação de assets externos.
