# W&B Weave 入門コース

W&B Weave の基本的な使い方を学ぶための教育用リポジトリです。

## コース構成

| # | ノートブック | 内容 |
|---|---|---|
| 00 | [環境セットアップ](notebooks/00_setup/00_environment_setup.ipynb) | Dedicated Cloud 接続・動作確認 |
| 01 | [Traces と @weave.op](notebooks/01_basics/01_traces_and_ops.ipynb) | トレースの基本・マルチメディア対応 |
| 02 | [アセット管理](notebooks/01_basics/02_assets.ipynb) | Model / Prompt / Dataset |
| 03 | [評価](notebooks/01_basics/03_evaluations.ipynb) | Evaluation / EvaluationLogger / Scorer / ragas |
| 04 | [シンプルエージェント](notebooks/02_practice/01_simple_agent.ipynb) | OpenAI Function Calling + Weave |
| 05 | [LangGraph エージェント](notebooks/02_practice/02_langgraph_agent.ipynb) | LangGraph ReAct + Weave |
| 06 | [W&B Models Registry](notebooks/03_advanced/01_wandb_models_registry.ipynb) | Artifact 管理・Weave 連携 |
| 07 | [ART 入門](notebooks/03_advanced/02_art_intro.ipynb) | GRPO・LocalBackend・Trajectory |
| 08 | [Agentic RL](notebooks/03_advanced/03_art_agentic_rl.ipynb) | ART 学習 + Weave トレース + W&B Models |

## セットアップ

### 環境変数

```bash
cp .env.example .env
# .env を編集して API キーを設定
```

| 変数 | 説明 |
|---|---|
| `WANDB_BASE_URL` | Dedicated Cloud URL（例: `https://your-org.wandb.io`） |
| `WANDB_API_KEY` | W&B API キー |
| `OPENAI_API_KEY` | OpenAI API キー |
| `WANDB_ENTITY` | W&B エンティティ名 |
| `WANDB_PROJECT` | プロジェクト名（デフォルト: `weave-course`） |

### Google Colab

各ノートブック上部の **Open in Colab** ボタンから開き、
左サイドバー 🔑 **Secrets** に上記の変数を登録してください。

> Part 3（ART）は GPU が必要です: ランタイム → GPU を変更 → T4

### ローカル

```bash
pip install -r requirements.txt
```

### Appendix

| # | ノートブック | 内容 |
|---|---|---|
| A | [wandb/skills](notebooks/appendix/A_wandb_skills.ipynb) | AI エージェント向けスキルパッケージの使い方・ヘルパー関数 |
| B | [W&B MCP サーバー](notebooks/appendix/B_mcp_server.ipynb) | Claude Code / Desktop からのデータ直接アクセス |

## 技術スタック

- **W&B Weave** `>=0.51.0` — LLM オブザーバビリティ・評価
- **W&B** `>=0.19.0` — 実験管理・Artifact Registry
- **OpenAI** `>=1.0.0` — LLM API
- **LangGraph** — マルチステップエージェント
- **OpenPipe ART** — エージェント強化学習（GRPO/CISPO）
- **ragas** — RAG 評価フレームワーク
