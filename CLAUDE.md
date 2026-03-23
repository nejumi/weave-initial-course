# CLAUDE.md — weave-initial-course

## プロジェクト概要

W&B Weaveの基本的な使い方を学ぶための教育用リポジトリ。Jupyter Notebookをメインコンテンツとする。
対象環境は **W&B Dedicated Cloud**（`WANDB_BASE_URL`による接続先設定が必要）。

## リポジトリ構成

```
weave-initial-course/
├── CLAUDE.md
├── README.md
├── .env.example
├── requirements.txt
├── notebooks/
│   ├── 00_setup/
│   │   └── 00_environment_setup.ipynb
│   ├── 01_basics/                        # Part 1: Weave基礎
│   │   ├── 01_traces_and_ops.ipynb
│   │   ├── 02_datasets.ipynb
│   │   ├── 03_models.ipynb
│   │   └── 04_evaluations.ipynb
│   ├── 02_practice/                      # Part 2: Weave実践
│   │   ├── 01_simple_agent.ipynb
│   │   └── 02_langgraph_agent.ipynb
│   └── 03_advanced/                      # Part 3: Models+Weave発展
│       ├── 01_wandb_models_registry.ipynb
│       ├── 02_art_intro.ipynb
│       └── 03_art_agentic_rl.ipynb
└── skills/
    └── wandb-primary/                    # wandb/skills (npx skills add wandb/skills)
```

## コンテンツ方針

### Part 1: Weave基礎

- **01_traces_and_ops**: `@weave.op`の仕組み、ネストトレース、サンプリング。**マルチメディアトレースも含む**（テキスト・画像・音声・動画・構造化データなど各種メディアタイプのログ方法）
- **02_datasets**: `weave.Dataset`の作成・publish・バージョン管理・pandas連携
- **03_models**: `weave.Model`クラス、バージョニング、predictの自動トレース
- **04_evaluations**: `weave.Evaluation`・`weave.Scorer`・built-in scorers・結果分析

### Part 2: Weave実践

- **01_simple_agent**: OpenAI Function Callingでツール（検索・計算等）を持つエージェントをWeaveでトレース
- **02_langgraph_agent**: LangGraphによるReActエージェント、複数ステップのトレースをWeave UIで可視化

### Part 3: Models+Weave発展

- **01_wandb_models_registry**: W&B Registry でのArtifact管理、`run.log_artifact` / `run.use_artifact`
- **02_art_intro**: OpenPipe ART概要、GRPOアルゴリズム、Client/Serverアーキテクチャ、W&B Serverless Backend
- **03_art_agentic_rl**: ARTでエージェントをRL学習、WeaveでTrajectory可視化、W&B Modelsにモデル保存

## 環境設定

### 必須環境変数（.env）

```bash
WANDB_BASE_URL=https://your-org.wandb.io   # Dedicated Cloud URL
WANDB_API_KEY=your_api_key
OPENAI_API_KEY=your_openai_key
WANDB_ENTITY=your_entity
WANDB_PROJECT=weave-course
```

### 各notebookの冒頭パターン

```python
import os
from dotenv import load_dotenv
load_dotenv()

import wandb
import weave

weave.init(f"{os.environ['WANDB_ENTITY']}/{os.environ['WANDB_PROJECT']}")
```

## 技術スタック

- `weave` >= 0.51.0
- `wandb` >= 0.19.0
- `openai` >= 1.0.0
- `langgraph`, `langchain-openai`
- `openpipe-art`
- `python-dotenv`

## OpenPipe ART ローカルバックエンド設定

- バックエンド: `LocalBackend(in_process=True)` （Colab対応）
- モデル: `Qwen/Qwen2.5-1.5B-Instruct`（Colab T4 16GB対応）
- インストール: `pip install "openpipe-art[backend]"`

### V100 / Volta (CC 7.0) 互換パッチ

vLLM の LoRA triton カーネルは CC < 8.0 でコンパイル失敗する。さらに sleep mode の
CuMemAllocator は同一プロセスで1インスタンスのみ許可。V100 では以下のパッチが必要:

1. `PunicaWrapperCPU` への差し替え（triton LoRA 回避）
2. `enable_sleep_mode=False`（allocator クラッシュ回避）
3. `enforce_eager=True`（CUDA graph OOM 回避）
4. `gpu_memory_utilization=0.7`（sleep mode OFF 時の KV cache 確保）
5. `max_seq_length=4096`（32768 は KV cache 不足）

```python
import torch
import vllm.platforms.cuda as _cuda_platform
from art import dev

@classmethod
def _v100_punica(cls): return "vllm.lora.punica_wrapper.punica_cpu.PunicaWrapperCPU"
if torch.cuda.is_available() and torch.cuda.get_device_capability()[0] < 8:
    _cuda_platform.CudaPlatform.get_punica_wrapper = _v100_punica

_IS_OLD_GPU = torch.cuda.is_available() and torch.cuda.get_device_capability()[0] < 8
_V100_CONFIG = dev.InternalModelConfig(
    engine_args=dev.EngineArgs(enable_sleep_mode=False, enforce_eager=True),
    init_args=dev.InitArgs(gpu_memory_utilization=0.7, max_seq_length=4096),
) if _IS_OLD_GPU else None

backend = LocalBackend(in_process=True)
model = art.TrainableModel(
    name="qwen-1.5b-001",
    project="weave-course-art",
    base_model="Qwen/Qwen2.5-1.5B-Instruct",
    _internal_config=_V100_CONFIG,
)
await model.register(backend)
```

## Colabボタン形式

各notebookの先頭に以下を挿入（OWNERは実際のGitHubユーザー名に置換）:

```html
<a href="https://colab.research.google.com/github/OWNER/weave-initial-course/blob/main/notebooks/PATH.ipynb" target="_parent">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>
```

## 開発ガイドライン

- **セル構成**: 各notebookは「概念説明（Markdown）→ コード実装 → Weave UI確認ポイント」の流れで構成する
- **再現性**: notebookは上から順に実行すれば動くように書く（セル間の依存を明示する）
- **マルチメディア**: Weaveのトレースには積極的にテキスト以外のメディア（画像・表・JSON構造）も含める
- **wandb/skills**: `skills/wandb-primary/` 配下のヘルパー関数（`weave_helpers.py`, `wandb_helpers.py`）を積極活用する

## 参考notebookから得た重要情報

参考ファイル: `WandBで始める実験管理_第3章Weave_Colabサンプル.ipynb`（書籍「Weights & Biases 実践ガイド」第3章のサンプル）

### マルチメディアトレースのパターン

`from weave import Content` と `Annotated` 型ヒントを組み合わせて、バイト列にメディアタイプを付与する：

```python
from typing import Annotated, Literal
from weave import Content

@weave.op()
def generate_image(...) -> Annotated[bytes, Content[Literal['png']]]:   # 画像
def tts(...)           -> Annotated[bytes, Content[Literal['mp3']]]:   # 音声
def generate_video(...)-> Annotated[bytes, Content[Literal['mp4']]]:   # 動画
def fetch_pdf(...)     -> Annotated[bytes, Content[Literal['pdf']]]:   # PDF
def fetch_html(...)    -> Annotated[bytes, Content[Literal['html']]]:  # HTML
```

### 参照可能な公開アセット

動画生成等で使用するリファレンス画像（インターネット上で公開済み）:
- `https://assets.st-note.com/img/1762403176-PimhEZu3voSeGp5C0l9t4z2N.png`

### Asset管理のカバレッジ

- `weave.Model` — クラス定義＋`@weave.op()` で predict を自動トレース
- `weave.StringPrompt` / `weave.MessagesPrompt` — プロンプトのバージョン管理・テンプレート化
- `weave.Dataset` — rows / from_calls / from_pandas / from_hf

### Evaluation のカバレッジ

| API | 用途 |
|---|---|
| `weave.Evaluation` + `weave.Scorer` | 事前定義データセットを使った系統的評価 |
| `weave.EvaluationLogger` | 実行中に逐次ログ（軽量・柔軟） |
| `call.apply_scorer()` | ガードレール（生成後即時スコアリング） |
| ragas連携 | RAG評価指標をEvaluationLoggerへ流し込み |

### その他の機能カバレッジ

- フィードバック: `call.feedback.add_reaction()`, `add_note()`, `add()`
- カスタムコスト: `client.add_cost(llm_id=..., prompt_token_cost=..., completion_token_cost=...)`
- サンプリングレート: `@weave.op(tracing_sample_rate=0.1)`

### コーディングスタイル

- Colabでは `await eval_job.evaluate(model)` を直接使用（asyncio.run不要）
- `try: weave.publish(...) except Exception: pass` で重複publish を吸収
- OpenAIクライアントは関数内でインスタンス化するパターン

## 参考資料

- wandb/skills: https://github.com/wandb/skills
- Weave Docs: https://docs.wandb.ai/weave
- OpenPipe ART: https://github.com/OpenPipe/ART
- W&B Models + Weave: https://docs.wandb.ai/tutorials/weave_models_registry/
