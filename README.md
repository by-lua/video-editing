# video-editing

Pacote de skills de criação e edição de vídeo/áudio por IA para Claude Code: criativo de anúncio
(vídeo/estático/carrossel), geração de imagem (ChatGPT), geração de vídeo (Google Flow), narração/TTS,
b-roll, legendas embutidas, montagem (Remotion/Hyperframes), e vídeos utilitários (changelog, PR, landing).

**Não inclui** a mecânica de vídeo do NinjaBR Hub (`hub-video-playwright`) — só a de **áudio/narração**
(`narracao-hub-tts`, via API NinjaVoice, sem browser).

## Instalar

```bash
git clone https://github.com/by-lua/video-editing.git && cd video-editing
./install.sh --dry-run   # confere
./install.sh
```
Instala em `~/.claude/skills` e `~/.claude/plugins/cache`. Skill/plugin que já existe vira `.bak-<data>`.

## Atualizar

```bash
cd video-editing && git pull && ./install.sh
```

## Mapa

```
criativo-ads          (estratégia: briefing, matriz persona×dor, formato, quantidade)
 ├─ vídeo  → criativo-ads-video-orq  (orquestradora)
 │            ├─ imagem da cena → gpt-imagem-playwright   (ChatGPT)
 │            ├─ vídeo          → flow-video-playwright    (Google Flow, Veo 3.x)
 │            ├─ voz            → narracao-hub-tts          (NinjaVoice API, 82 vozes)
 │            ├─ b-roll         → get-brolls (plugin)       (YouTube/Insta/TikTok/Wikimedia/Pexels/Pixabay)
 │            └─ edição         → video-use · remotion-* · hyperframes-* · embedded-captions ·
 │                                captions-overlay · talking-head-recut · cut-the-curve
 ├─ estático/carrossel → modelagem-escalados → gpt-imagem-playwright
 └─ infra               → agent-browser · browser-cloudflare · browser-harness

Vídeos utilitários (sem persona/oferta): music-to-video · slideshow · changelog-video ·
pr-to-video · website-to-video · product-launch-video · faceless-explainer · general-video ·
motion-graphics · motion-doctrine · watch · watch-video
```

## Skills incluídas

| Grupo | Skills |
|---|---|
| Estratégia de criativo | `criativo-ads`, `criativo-ads-video-orq` |
| Geração de imagem/vídeo | `gpt-imagem-playwright`, `flow-video-playwright`, `modelagem-escalados` |
| Áudio/narração | `narracao-hub-tts` |
| B-roll | plugin `get-brolls` (engenheirodevideo) |
| Legenda/caption | `embedded-captions`, `captions-overlay` |
| Montagem/edição | `video-use`, `talking-head-recut`, `cut-the-curve`, `watch`, `watch-video` |
| Remotion | `remotion-best-practices`, `remotion-captions`, `remotion-create`, `remotion-docs`, `remotion-interactivity`, `remotion-maps`, `remotion-markup`, `remotion-multimedia`, `remotion-render`, `remotion-saas`, `remotion-to-hyperframes`, `remotion-upgrade` |
| Hyperframes | `hyperframes`, `hyperframes-animation`, `hyperframes-audio`, `hyperframes-cli`, `hyperframes-core`, `hyperframes-creative`, `hyperframes-keyframes`, `hyperframes-registry` |
| Vídeos utilitários | `music-to-video`, `slideshow`, `changelog-video`, `pr-to-video`, `website-to-video`, `product-launch-video`, `faceless-explainer`, `general-video`, `motion-graphics`, `motion-doctrine` |
| Infra browser | `agent-browser`, `browser-cloudflare`, `browser-harness` |

## Precisa de conta própria

| Peça | Conta |
|---|---|
| Imagem | ChatGPT (plano com geração de imagem) |
| Vídeo | Google Flow (plano com créditos de vídeo) |
| Narração/voz | NinjaVoice API (NinjaBR Hub) ou outro TTS que entregue WAV |
| Transcrição/corte | ElevenLabs Scribe (via `video-use`) |
| B-roll de bancos | Pexels/Pixabay (chaves opcionais, ver `get-brolls`) |

## Notas

- Browsers persistentes (ChatGPT, Flow): sempre headed, com perfil próprio — nunca headless.
- `narracao-hub-tts` é só API (sem browser, sem login).
- `get-brolls` é um plugin (`plugins/cache/engenheirodevideo/get-brolls`), não uma skill solta.
