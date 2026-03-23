.PHONY: install install-art test test-basics test-practice test-advanced test-appendix clean

# ── インストール ─────────────────────────────────────────────────────────────

install:
	uv sync
	uv pip install --system -e ".[all]"

install-art:
	uv pip install --system "openpipe-art[backend]"

# ── テスト ───────────────────────────────────────────────────────────────────

# 全ノートブック（ART除く）
test:
	uv run pytest notebooks/ \
		--nbmake \
		--nbmake-timeout=300 \
		--ignore=notebooks/03_advanced/02_art_intro.ipynb \
		--ignore=notebooks/03_advanced/03_art_agentic_rl.ipynb \
		-v

# Part 0-1: 基礎のみ（高速）
test-basics:
	uv run pytest \
		notebooks/00_setup/ \
		notebooks/01_basics/ \
		--nbmake --nbmake-timeout=180 -v

# Part 2: エージェント
test-practice:
	uv run pytest notebooks/02_practice/ \
		--nbmake --nbmake-timeout=300 -v

# Part 3: 発展（ART除く）
test-advanced:
	uv run pytest notebooks/03_advanced/01_wandb_models_registry.ipynb \
		--nbmake --nbmake-timeout=300 -v

# Appendix
test-appendix:
	uv run pytest notebooks/appendix/ \
		--nbmake --nbmake-timeout=120 -v

# ART（GPU必須、時間がかかる）
test-art:
	uv run pytest \
		notebooks/03_advanced/02_art_intro.ipynb \
		notebooks/03_advanced/03_art_agentic_rl.ipynb \
		--nbmake --nbmake-timeout=3600 -v

# ── クリーン ─────────────────────────────────────────────────────────────────

clean:
	find notebooks -name "*.nbmake" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
