# Núcleo de Situação de Saúde — Deployment e Arquitetura

Este repositório centraliza a **documentação arquitetural** e os artefatos de **integração, execução e deployment** do sistema do Núcleo de Situação de Saúde (NSS) da Universidade Estadual do Norte Fluminense Darcy Ribeiro (UENF).

O sistema é dividido em três repositórios de aplicação, mantidos separadamente para permitir autonomia entre as equipes e facilitar a evolução futura do projeto:

- **Frontend:** aplicação web responsável pela interface, mapas e interação com os dados.
- **Java / Spring Boot:** backend principal, responsável pela API, autenticação, autorização, regras de negócio e acesso ao PostgreSQL.
- **Python / Pipeline:** pipeline de dados responsável por obter os dados do SINAN via PySUS, transformar e validar os dados e atualizar o PostgreSQL.

## Arquitetura em alto nível

```text
                    ┌──────────────────────┐
                    │      Front-end       │
                    │ React + TypeScript   │
                    │ TanStack + Tailwind  │
                    └──────────┬───────────┘
                               │ HTTPS
                               ▼
                    ┌──────────────────────┐
                    │   Java / Spring Boot │
                    │                      │
                    │ REST API             │
                    │ Auth / Authorization │
                    │ Business Rules       │
                    │ Persistence          │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      PostgreSQL      │
                    └──────────▲───────────┘
                               │
                          batch / ETL
                               │
                    ┌──────────┴───────────┐
                    │   Python Pipeline    │
                    │ PySUS / SINAN        │
                    │ Bronze → Silver → Gold│
                    └──────────┬───────────┘
                               │
                               ▼
                             SINAN
```

O Python **não faz parte do caminho síncrono de consulta do usuário**. Sua função principal é manter os dados consolidados e validados do PostgreSQL atualizados.

Os arquivos Parquet e os `DataFrame`s utilizados pelo pipeline continuam sendo mantidos como artefatos intermediários e ferramentas de inspeção, depuração e validação dos dados.

## Repositórios de aplicação

| Componente | Repositório | Responsabilidade principal |
|---|---|---|
| Front-end | `Zadoque/<frontend-repo>` | Interface web, mapas e consumo da API Java |
| Java | `ArtursPereira/Site-Sala-de-Situa-o-de-Saude-Java` | API principal, segurança, regras de negócio e PostgreSQL |
| Python | `Zadoque/Nucleo-de-Situacao-De-Saude` | Pipeline SINAN/PySUS, processamento e atualização de dados |

> Os nomes acima podem ser atualizados conforme os repositórios do frontend e as convenções definitivas da equipe forem estabelecidos.

## Papel deste repositório

Este repositório **não é outro backend da aplicação**. Ele funciona como o ponto de integração e documentação do sistema. Seu objetivo é registrar decisões arquiteturais, dependências entre os componentes, ambientes Docker, contratos de integração e procedimentos de execução.

Uma organização futura recomendada é:

```text
nss-deployment/
├── README.md
└── documentacao/
    ├── flake.nix
    ├── main.tex
    └── Section-*.tex
```

Conforme o deployment evoluir, o mesmo repositório poderá receber, quando fizer sentido, arquivos como `compose.yaml`, exemplos de `.env`, scripts auxiliares e configurações de infraestrutura.

## Documentação completa

A documentação técnica detalhada está em [`documentacao/`](documentacao/). O documento LaTeX é modular e dividido em arquivos `Section-X-...tex` para facilitar manutenção por várias pessoas.

Para compilar a documentação em NixOS, entre na pasta `documentacao` e use:

```bash
nix develop
make pdf
```

ou, sem entrar no shell interativo:

```bash
nix run .#pdf
```

## Princípios arquiteturais

1. O frontend conversa somente com a API Java.
2. O Java é o ponto de entrada da aplicação e o responsável por autenticação e autorização.
3. O Java acessa o PostgreSQL para atender às consultas da aplicação.
4. O Python mantém os dados do PostgreSQL atualizados a partir do SINAN.
5. O pipeline mantém Bronze, Silver e Gold para rastreabilidade, reprocessamento e debugging.
6. Cada componente possui seu próprio repositório e pode gerar sua própria imagem Docker.
7. Um ambiente de integração pode orquestrar os containers dos três repositórios juntamente com o PostgreSQL via Docker Compose.

## Equipe atual

O desenvolvimento atual é realizado por três estagiários:

- **Zadoque Carneiro:** arquitetura e documentação;
- **Artur Pereira:** Java + Spring Boot;
- **Gabriel Costa:** Python + pipeline de dados.

A separação por repositórios foi mantida deliberadamente para permitir que a mesma arquitetura possa crescer para equipes maiores sem exigir uma migração de monorepo.
