# Entrega do LilGym — 24/11/2026

## Escopo aprovado

- Entrar e sair com e-mail e senha via Firebase Authentication. A apresentação usa uma conta de teste já criada. O primeiro login requer internet. Após autenticar, o app reabre e funciona offline.
- Guardar treinos, sessões e séries no SQLite, separados por conta. A conta nova começa sem treinos e com o catálogo pré-cadastrado.
- Listar todos os treinos na Home, iniciar o treino escolhido e destacar a sessão ativa para retomada. Se não houver treinos, oferecer a criação do primeiro.
- Criar, renomear e excluir treinos com confirmação. Adicionar, remover e reordenar exercícios. Ao adicionar, sugerir 3 séries de 8–12 repetições e permitir ajuste.
- Registrar carga e repetições realizadas na própria sessão. Aceitar carga zero ou positiva e repetições inteiras positivas. Permitir editar ou excluir qualquer série enquanto a sessão estiver ativa.
- Finalizar explicitamente após registrar pelo menos uma série, mesmo antes de cumprir todo o plano. Atingir o plano mantém a sessão aberta. Voltar à Home ou fechar o app permite retomar. Cancelar exige confirmação e seus registros ficam fora do histórico de desempenho e das sugestões.
- Mostrar histórico de sessões concluídas e consulta por exercício com data, carga e repetições. Alterar ou excluir o treino original preserva o que foi registrado na sessão.
- Sugerir carga e repetições da série correspondente na última sessão concluída que registrou o mesmo exercício, inclusive se pertencer a outro treino. Se a série correspondente não existir, deixar os campos livres.

Cadastro personalizado de exercícios, agenda por dia da semana e sincronização entre aparelhos ficam fora deste escopo.

## Entregáveis e aceite

1. Link do GitHub e referência ao commit apresentado, com instruções de execução no README.
2. APK Android instalado e testado em celular ou emulador. Conferir tela pequena e modo avião.
3. Apresentação ao vivo com demonstração e explicação do código.

### Roteiro da demonstração

1. Fazer login com internet usando a conta de teste.
2. Criar um treino com um exercício do catálogo, aceitar a sugestão de séries e repetições e iniciar pela Home.
3. Ativar o modo avião, registrar uma série, fechar o app, reabrir e retomar com os dados salvos.
4. Corrigir a série e finalizar antes de completar o plano. Reabrir e consultar o registro pelo exercício e pela sessão.
5. Explicar o caminho da ação entre a tela Flutter, o controlador e o repositório SQLite. Mostrar onde o Firebase identifica a conta e como os dados de treino são associados a ela.

A validação também cobre cancelamento com confirmação, histórico após editar ou excluir o treino original, sugestão entre treinos, isolamento entre contas e análise Flutter. O acompanhamento está na [issue #46](https://github.com/ericfr1tzenvalle/gym-tracker-app/issues/46).
