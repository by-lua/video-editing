#!/usr/bin/env bash
# Instala o pacote video-editing em ~/.claude (skills + plugins).
#   ./install.sh            instala (não sobrescreve skill/plugin que já existe: faz backup .bak-<data>)
#   ./install.sh --dry-run  só mostra o que faria
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
run(){ if [ $DRY = 1 ]; then echo "[dry] $*"; else "$@"; fi; }
STAMP=$(date +%Y%m%d-%H%M%S)

echo "Destino: $DEST"
run mkdir -p "$DEST/skills" "$DEST/plugins/cache"

echo "→ skills"
for d in "$HERE"/skills/*/; do
  n=$(basename "$d")
  if [ -e "$DEST/skills/$n" ] || [ -L "$DEST/skills/$n" ]; then run mv "$DEST/skills/$n" "$DEST/skills/$n.bak-$STAMP"; echo "  (backup de $n)"; fi
  run cp -a "$d" "$DEST/skills/$n"
done

echo "→ plugins"
for p in "$HERE"/plugins/*/; do
  pn=$(basename "$p")
  run mkdir -p "$DEST/plugins/cache/$pn"
  for d in "$p"*/; do
    n=$(basename "$d")
    if [ -e "$DEST/plugins/cache/$pn/$n" ]; then run mv "$DEST/plugins/cache/$pn/$n" "$DEST/plugins/cache/$pn/$n.bak-$STAMP"; echo "  (backup de $pn/$n)"; fi
    run cp -a "$d" "$DEST/plugins/cache/$pn/$n"
  done
done

echo "→ dependências"
for c in chromium agent-browser ffmpeg ffprobe python3 node npm curl uv; do
  if command -v "$c" >/dev/null 2>&1 || { [ "$c" = chromium ] && command -v chromium-browser >/dev/null 2>&1; }; then echo "  ok   $c"; else echo "  FALTA $c"; fi
done
cat <<'MSG'

Pronto. Falta (uma vez):
  1. Instalar o que estiver FALTANDO acima (agent-browser: npm i -g agent-browser; uv: pipx install uv ou curl -LsSf https://astral.sh/uv/install.sh | sh).
  2. Logar browsers persistentes das contas que o pacote usa (ChatGPT p/ imagem, Google Flow p/ vídeo, NinjaBR Hub p/ narração/TTS) — perfis próprios, nunca headless.
  3. video-use: cd ~/.claude/skills/video-use && uv sync   (ELEVENLABS_API_KEY se for transcrever/cortar).
  4. get-brolls: cd ~/.claude/plugins/cache/engenheirodevideo/get-brolls/<versão> && leia docs/ (copie .env.example → .env).
  5. narracao-hub-tts: precisa de chave da API NinjaVoice (variável de ambiente — ver SKILL.md).
  6. Reinicie o Claude Code e peça: "faz um criativo de vídeo para <produto>" ou "gera uma narração para <roteiro>".

Leia README.md para o mapa completo.
MSG
