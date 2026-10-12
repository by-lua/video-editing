---
name: flow-video-playwright
description: Mecânica completa do Google Flow (labs.google/fx/pt/tools/flow) — pega lane, gera imagem OU vídeo via prompt no Omni 1.1 Flash, espera o fim da fila/geração, baixa pelo conteúdo (não pelo "último card"), valida duração+cor bt709+áudio, e move pro projeto. Cobre o pipeline INTEIRO (envio → fila → pronto → download → gate), não só o clique. Use quando a skill-mãe (`tiktok-shop` ou `criativo-ads-video-orq`) pedir vídeo via Flow (alternativa ao Hub quando Hub está expirado). Profile `flow-enovalabs-pro` (porta 9265), logado Google conta contato.inovalabsx; clones -2/3/4 pra paralelo.
---

> **HUB DESATIVADO (02/10/2026, ordem da usuária):** NinjaBR Hub está SEM COTA e os perfis `hub`/`hubv2`/`hubts` foram removidos (backup em `~/.agent-profiles/_removidos-hub-2026-10-02/`). NÃO use Hub, NÃO rode `hub-livre.sh` (sai com erro), NÃO espere perfil do Hub liberar. Imagem: ChatGPT — se a cota de upload de uma conta acabar, troque de CONTA: `gpt-noelia-7-10*` ↔ `gpt-noelia.empt*`. Vídeo: Google Flow (`flow-video-playwright`).


# flow-video-playwright

Mecânica de geração de **imagem+vídeo via Google Flow** (labs.google/fx/pt/tools/flow). Alternativa ao `hub-video-playwright` quando o Hub está expirado (morreu 21/09/2026, ver [[feedback-ninjabr-hub-acesso-expirado]]).

## Profile

`flow-enovalabs-pro` (porta 9265), já logado Google. **Antes de gastar tempo**, navegar e confirmar logado:

```bash
agent-browser --session flow-enovalabs-pro navigate "https://labs.google/fx/pt/tools/flow"
```

Se cair em login, **parar e avisar o usuário** — credenciais não estão no `.credentials.env`.

## Modelo

**Omni 1.1 Flash** — confirmado em produção 30/09/2026. Custa menos crédito que Veo 3.1. É multimodal: gera imagem E vídeo do prompt puro, sem upload.

Antes da geração, abrir settings (botão `tune`, aria-label "Configurações") e garantir:
- **Confirmar antes de gerar = Nunca** (default vem em "Sempre" — gasta crédito e bloqueia envio se deixar Sempre).
- **Modelo padrão de geração de vídeo = Omni 1.1 Flash**.
- **Proporção de vídeo = crop_9_16 9:16** (radio role="radio", o SEGUNDO crop_9_16 da lista, índice 10 no mapeamento atual).

Salvar.

## Fluxo (passo a passo verificado 01/10/2026)

1. **Criar projeto**: dashboard → botão "Novo projeto" → URL vira `https://flow.google.com/project/<uuid>`.
2. **Composer**: `[contenteditable=true]`. **Paste via clipboard**, NÃO `innerText` — medido 01/10:
   - `c.innerText = prompt; c.dispatchEvent(new InputEvent('input'))` cola o texto mas o botão "Iniciar geração" NÃO trava em disabled ao clicar (handler de "text changed" do Material não dispara). 2 cliques não geram nada.
   - **Caminho certo**: `clipboard write` nativo do `agent-browser`, depois `Ctrl+A Ctrl+V` no composer:
     ```bash
     agent-browser --session flow-enovalabs-pro clipboard write "$PROMPT"
     agent-browser --session flow-enovalabs-pro click "[contenteditable=true]"
     agent-browser --session flow-enovalabs-pro press "Control+a"
     agent-browser --session flow-enovalabs-pro press "Control+v"
     ```
   - Confirmar `txtLen === prompt.length` antes de enviar.
3. **Enviar**: `click button[aria-label='Iniciar geração']`. Botao trava em `disabled=true` = envio aceito. Texto "Na fila" aparece, depois "Conceptualizing the Video" / "play_circle" + percentual.
4. **Aguardar**: status muda pra "Conceptualizing the Video" (Flow) ou "Criando imagem" (ChatGPT). Botão "Parar" só aparece enquanto gera. ~50s pra imagem prompt-only, mais pra vídeo.
5. **Resultado**: `<img src="blob:https://flow.google.com/...">` com `naturalWidth>800` quando 9:16. Baixar via fetch+blob+`<a download>` (link DOM nativo).

### Settings obrigatórios (antes do primeiro envio)

Abrir `button[aria-label='Configurações']` (ícone tune):

- **Confirmar antes de gerar** = **Nunca** (radio group `mat-radio-group-2`, `value=2`). Default vem em "Sempre" — gasta o crédito E bloqueia envio automático.
- **Modelo padrão de geração de vídeo** = Omni 1.1 Flash (combobox).
- **Proporção de vídeo** = crop_9_16 9:16 (button role="radio", SEGUNDO crop_9_16 da lista, índice 10).

Setar radios via `input[type=radio]` direto (clicar no mat-radio-button não flipa o input):

```js
// Nunca
const inputs = Array.from(document.querySelectorAll('input[type=radio]'));
inputs.find(r => r.closest('mat-radio-button')?.innerText.startsWith('Nunca')).click();

// 9:16 vídeo (segundo crop_9_16)
const r916 = Array.from(document.querySelectorAll('button[role=radio]'))
  .filter(b => b.innerText === 'crop_9_16\n9:16')[1];
r916.click();

// Salvar
Array.from(document.querySelectorAll('button')).find(b => b.innerText?.trim() === 'Salvar').click();
```

## Upload de referência — bloqueado 30/09/2026

Botão "Enviar mídia" do painel "Adicionar elementos" abre **file dialog nativo do OS** (CDP `Page.fileChooserOpened`, não `<input type=file>` no DOM). `agent-browser upload` falha silenciosamente.

**Workaround**: gerar **prompt-only**. OmniFlash é multimodal e interpreta o prompt descritivo. Não é tão fiel à referência quanto upload daria, mas evita o file dialog. Escalonar `browser-harness` com `Page.setInterceptFileChooser` se prompt-only não bastar — não testado em produção.

## Prompt-only — template base

```
A <tipo de plano> shot of <composição>. <sujeito> doing <ação única, lenta>.
<cenário>. <luz>. Shot in vertical 9:16 aspect ratio. Photorealistic,
shot on iPhone, no text, no watermark. <anti-morphing>.
```

**Anti-morphing obrigatório** (Flow não tem campo NEGATIVE separado, enfie na mesma string):

- "Hand never clips through the fabric"
- "Garment stays flat / never floats unsupported"
- "Single continuous motion, no jumping"

Validado 30/09/2026: cena 1 (mão feminina puxando tecido canelado rosa, fundo cama branco) gerada em ~50s no OmniFlash, saída 941x1672, look iPhone UGC convincente.

## Download (verificado 01/10/2026)

Vídeo não renderiza `<video>` na grade — só após abrir o card no modal. Fluxo:

1. Clicar na thumbnail (`img[alt="Miniatura do vídeo gerada"]`) — abre modal com player + botões de header.
2. Clicar `button[aria-label="Baixar mídia"]` (ícone download no header).
3. Abre menu de qualidade: 270p (GIF), 720p (Tamanho original), 1080p (Aprimorada), 4K (Aprimorada).
4. Clicar a opção certa via DOM direto:
   ```js
   Array.from(document.querySelectorAll('button'))
     .find(b => b.innerText.trim() === '720p\nTamanho original').click();
   ```
5. Arquivo cai em `~/Downloads/` com nome do título Flow + timestamp (`Hands_lifting_brown_skirt_fabric_20261001180016.mp4`). Mover pro staging do projeto e re-nomear.

Pra imagem (gerada direto, sem vídeo): `<img src="blob:https://flow.google.com/...">` aparece na grade após gerar. Salvar via fetch+blob+`<a download>` OU screenshot direto.

### Gate de cor após download

**Quase toda mídia do Flow sai com `color_range/color_space/color_transfer/color_primaries = unknown`** — confirmado 01/10/2026 no Flow Omni 1.1 Flash. Gate `feedback-metadado-cor-video-final` reprova. Re-encodar pra bt709 ANTES de marcar o clipe como pronto:

```bash
ffmpeg -nostdin -i cena-1.mp4 \
  -c:v libx264 -crf 18 -preset veryfast -pix_fmt yuv420p \
  -x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709:fullrange=off" \
  -color_primaries bt709 -color_trc bt709 -colorspace bt709 -color_range tv \
  -c:a copy cena-1-fixed.mp4
mv cena-1-fixed.mp4 cena-1.mp4
```

Confere com `ffprobe -show_entries stream=color_*` — os 4 campos têm que ser `bt709`/`tv`.

## Pegar a lane — PRIMEIRA COISA, SEMPRE

Vários Claudes usam este mesmo browser. Sem lane, todos caem na mesma projeto: o `criar projeto` de um sobrescreve o do outro, e as gerações saem trocadas.

```bash
~/.claude/bin/lane.sh take flow <lane>      # ex.: lane.sh take flow pov-bella
S=flow-<lane>                               # use $S em TODO comando daqui pra frente
```

Profile persistente `~/.agent-profiles/flow-enovalabs-pro`, porta 9265, URL `https://labs.google/fx/pt/tools/flow`. **Nunca use `agent-browser open`**, **`press Escape`** (manda a aba para `about:blank` e quebra a lane). Ao terminar: `~/.claude/bin/lane.sh drop flow <lane>`.

A área de download do Flow é **`FLOW`**, não `HUB` nem `PLAYWRIGHT`. Exporte uma vez no início:

```bash
export LANE_AREA=FLOW
```

Arquivo sai do Flow com nome do título + timestamp (ex.: `Hands_lifting_brown_skirt_fabric_20261001180016.mp4`), cai em `~/Downloads/`, e o `lane.sh collect` move pra `~/Downloads/FLOW/$LANE/` → pasta do projeto. **Nada fica largado em Downloads.**

## CHECK-LIST DE ENVIO — rode ANTES de cada clique em "Iniciar geração"

O Flow **não limpa nada entre gerações** (igual Hub): o prompt do composer fica grudado, o modelo/proporção podem ser resetados pelo re-render após envio. A ordem abaixo existe porque cada passo fora de lugar já custou crédito (cota cobrada mesmo em geração inválida).

**1. CRIAR projeto novo (ou trocar pra um existente) — cada leva usa um projeto.** Botão "Novo projeto" no dashboard. URL vira `https://flow.google.com/project/<uuid>`. Reusar projeto velho acumula lixo e confunde a diff de `src` do download (ver adiante).

**2. LIMPAR o composer do projeto novo:**

```bash
agent-browser --session $S click "[contenteditable=true]"
agent-browser --session $S press "Control+a"
agent-browser --session $S press "Delete"
```

Confirme:

```bash
echo '(()=>document.querySelector("[contenteditable=true]").textContent.length)()' \
  | agent-browser --session $S eval --stdin    # tem que dar 0
```

**3. CONFERIR settings:** "Confirmar antes de gerar" = **Nunca**, modelo = **Omni 1.1 Flash**, proporção = **crop_9_16 9:16**. A skill abre com defaults errados (Sempre + modelo Lite + 16:9) — ver bloco [Settings obrigatórios](#settings-obrigatórios-antes-do-primeiro-envio).

**4. ESCREVER o prompt via clipboard (não `innerText`) e CONFERIR** — `txtLen === prompt.length` antes de enviar. Detalhes no bloco [Fluxo](#fluxo-passo-a-passo-verificado-01102026) abaixo.

**5. ENVIAR** e confirmar que o composer travou em disabled:

```bash
agent-browser --session $S click "button[aria-label='Iniciar geração']"
sleep 2
echo '(()=>{const c=document.querySelector("[contenteditable=true]");return c.contentEditable==="false"||c.getAttribute("aria-disabled")==="true"?"travao":"livre";})()' \
  | agent-browser --session $S eval --stdin
```

## ESPERA: três estados, três condutas

Depois de enviar, o status na página passa por três fases. Confundir elas faz você abortar cedo (perder crédito) ou esperar demais (achar que travou quando já saiu).

| Estado | Texto na tela | Conduta |
|---|---|---|
| **Fila** | "X foi agendado e está na fila devido à alta demanda. Sinta-se à vontade para verificar o status daqui a alguns minutos." | **Esperar.** Pode levar 1-30min. NÃO reenvie. |
| **Gerando** | "Conceptualizing the Video" + ícone `play_circle` + percentual | **Esperar.** Botão "Parar" visível. |
| **Pronto** | Card com `<img alt="Miniatura do vídeo gerada">` aparece na grade | **Baixar.** Ver bloco de download. |

**Limite duro: 30 minutos em fila sem transição pra "Gerando" = abortar.** Medido 02/10/2026: o Flow mostrou "alta demanda" por **45min** em `flow-enovalabs-pro`, e quando moveu o status de fato o job já tinha consumido o crédito sem entregar nada. Sintoma: "alta demanda" >30min E botão "Iniciar geração" da composição anterior continua `disabled=true` travado — não é fila real, é cota perdida.

**Caminho de recuperação se travar:**

```bash
# 1. Cancelar o job pendente (libera o composer pra novo envio)
agent-browser --session $S click "button[aria-label='Parar']" 2>/dev/null
sleep 2
# 2. Se composer não destravar, recarregar a página inteira (perde o projeto atual)
agent-browser --session $S navigate "https://labs.google/fx/pt/tools/flow"
# 3. Tentar clone paralelo
S=flow-<lane>-2  # ou -3, -4
```

Se o `flow-enovalabs-pro-2/3/4` também estiver logado e em fila, **use-o em paralelo** (Flow permite múltiplos profiles do mesmo login, diferente do Hub). Confirmar login: `lane.sh take flow <lane> && agent-browser --session $S navigate "https://labs.google/fx/pt/tools/flow"` — se cair em dashboard sem pedir login, está OK.

**Polling curto, teto generoso:**

```bash
T0=$(date +%s)
for i in $(seq 1 360); do                                # 30min × 6 = 360 × 5s
  STATE=$(echo '(()=>{const txt=document.body.innerText;
    if(/alta demanda/i.test(txt)) return "fila";
    if(/Conceptualizing|Criando/i.test(txt)) return "gerando";
    const imgs=document.querySelectorAll("img[alt=\\"Miniatura do vídeo gerada\\"]").length;
    if(imgs>0) return "pronto";
    return "?")()' \
    | agent-browser --session $S eval --stdin | tr -d '"' | tail -1)
  echo "  [$(( $(date +%s)-T0 ))s] $STATE"
  [ "$STATE" = "pronto" ] && break
  [ "$STATE" = "?" ] && [ $i -gt 6 ] && { echo "abort: composer travado sem estado"; break; }
  sleep 5
done
```

## DOWNLOAD pelo CONTEÚDO — guarde antes, escolha o novo

`vs[vs.length-1]` não existe no Flow (não há `<video>` na grade). O Flow renderiza uma **thumbnail** (`<img alt="Miniatura do vídeo gerada">`) na grade; o vídeo real só aparece **depois de abrir o card no modal** e clicar `Baixar mídia`. Logo, o caminho de download é diferente do Hub:

**1. ANTES do envio**, guarde a lista de thumbnails existentes:

```bash
BEFORE=$(echo '(()=>[...document.querySelectorAll("img[alt=\\"Miniatura do vídeo gerada\\"]")].map(i=>i.src).join("|"))()' \
  | agent-browser --session $S eval --stdin | tr -d '"')
```

**2. DEPOIS** que `pronto` sair, ache a thumbnail **nova**:

```bash
AFTER=$(echo '(()=>[...document.querySelectorAll("img[alt=\\"Miniatura do vídeo gerada\\"]")].map(i=>i.src).join("|"))()' \
  | agent-browser --session $S eval --stdin | tr -d '"')
NEW=$(python3 -c "import sys;a=set('$AFTER'.split('|'));b=set('$BEFORE'.split('|'));print('|'.join(a-b))")
```

Se `NEW` vier vazio, o card não apareceu ainda — espere mais 10-30s e re-tente.

**3. Abrir o modal do card novo** e baixar 720p:

```bash
# click no thumbnail novo
python3 -c "
import sys
srcs='$NEW'.split('|')
print('(()=>{const imgs=[...document.querySelectorAll(\"img[alt=\\\\\"Miniatura do vídeo gerada\\\\\"]\")];'
      'const t=imgs.find(i=>i.src===\"'+srcs[0]+'\");'
      'if(!t) return \"sem thumb\";t.click();return \"abriu\";})()')" \
  | agent-browser --session $S eval --stdin
sleep 2
# click "Baixar mídia" no header do modal
agent-browser --session $S click "button[aria-label='Baixar mídia']"
sleep 1
# escolhe 720p
python3 -c "
print('(()=>{const b=[...document.querySelectorAll(\"button\")]'
      '.find(x=>x.innerText.trim()===\"720p\\\\nTamanho original\");'
      'if(!b) return \"sem 720p\";b.click();return \"baixar\";})()')" \
  | agent-browser --session $S eval --stdin
```

**4. Espera download cair em `~/Downloads/` e mover pra área do Flow:**

```bash
sleep 6
LANE_AREA=FLOW ~/.claude/bin/lane.sh collect <lane> <projeto>/VIDEO
```

`collect` varre `~/Downloads/FLOW/$lane-*` (não `HUB/*`), move pra `~/Downloads/FLOW/$LANE/` e expõe o path. Se nada apareceu em 15s, ver diagnóstico abaixo.

**5. Renomear pro padrão do projeto** e fechar modal:

```bash
mv ~/Downloads/FLOW/$LANE/*.mp4 <projeto>/cena-N.mp4
agent-browser --session $S click "button[aria-label='Botão \"Voltar\" para acessar a página anterior']"
```

## Diagnóstico: "baixou nada depois de 15s"

Três causas, nesta ordem:

1. **Modal abriu em card errado** — o `find(i=>i.src===NEW)` pode ter falhado silenciosamente. Tire screenshot e inspecione:
   ```bash
   agent-browser --session $S screenshot
   ```
2. **Menu de qualidade não abriu** — `Baixar mídia` foi clicado mas o menu está fora da viewport. O menu do Flow renderiza **abaixo** do botão; `innerHeight` em viewport curta pode cortar. Use:
   ```js
   document.querySelectorAll("button").forEach(b=>b.scrollIntoView({block:"center"}))
   ```
3. **Bloqueio de download pelo browser** — Flow às vezes exige interação adicional ("Permitir downloads deste site"). Profile persistente do Flow está com permissão, mas se não estiver:
   ```bash
   agent-browser --session $S eval --stdin <<< '(()=>{const a=[...document.querySelectorAll("button")].find(b=>/permitir|allow/i.test(b.innerText));if(a){a.click();return "permitiu";}return "sem prompt";})()'
   ```

## Validação pós-download — `ffprobe` e cor bt709

**Antes de marcar o clipe como pronto, dois gates obrigatórios** (mesmos do Hub):

```bash
F=<projeto>/cena-N.mp4
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$F")
W=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$F")
H=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$F")
echo "$W x $H, $DUR s"
# esperado: 720 x 1280, 8-10s
```

**Gate de cor** — Flow Omni 1.1 Flash sai com `color_*=unknown` em quase tudo (confirmado 01/10/2026). Re-encodar pra bt709:

```bash
ffmpeg -nostdin -i "$F" \
  -c:v libx264 -crf 18 -preset veryfast -pix_fmt yuv420p \
  -x264-params "colorprim=bt709:transfer=bt709:colormatrix=bt709:fullrange=off" \
  -color_primaries bt709 -color_trc bt709 -colorspace bt709 -color_range tv \
  -c:a copy "${F%.mp4}-fixed.mp4" -y
mv "${F%.mp4}-fixed.mp4" "$F"
ffprobe -v error -show_entries stream=color_primaries,color_trc,colorspace,color_range \
  -of csv=p=0 "$F"   # 4 linhas: bt709,bt709,bt709,tv
```

**Gate de conteúdo (RMSE contra imagem de referência)** — só aplicável se a cena foi gerada via Hub com imagem de origem. Em Flow **prompt-only não há referência para comparar**: o frame 0 do clipe **não** vai bater com nenhuma imagem do projeto. Pule este gate; valide o conteúdo **assistindo o clipe** (eye-check) ou comparando frame 0 com a última cena do clipe anterior (continuidade).

## Da geração ao acabamento

Um download tecnicamente válido ainda pode conter falsa partida, repetição, música/ruído depois da fala e gesto tardio. Ao entregar clipes para montagem, sinalize essas ocorrências e leia `../criativo-ads-video-orq/references/acabamento-natural-audio-cortes.md`. Preserve originais. A fronteira de som do `silencedetect` não é a fronteira de fala; a montagem decide depois de revisar palavras e gestos.

## CHECK-LIST PÓS-DOWNLOAD

Rode em ordem, falhe em qualquer um:

| Gate | Esperado | Como verificar |
|---|---|---|
| Arquivo existe | `~/Downloads/FLOW/$LANE/*.mp4` | `ls -la` |
| Duração | 8-10s | `ffprobe -show_entries format=duration` |
| Resolução | 720×1280 | `ffprobe -show_entries stream=width,height` |
| Cor bt709 | 4 campos `bt709/tv` | gate acima, obrigatório |
| Áudio AAC | stream 1, codec_name=aac | `ffprobe -show_streams` |
| Mover pro projeto | `<projeto>/cena-N.mp4` | `mv` |
| Fechar modal Flow | sim | `click "Botão Voltar"` |

## Drop lane ao terminar

```bash
~/.claude/bin/lane.sh drop flow <lane>
```

Crítico: lane segurada = outras panes pegam outra lane, e o `~Downloads/FLOW/$LANE/` fica acessível só pra você. Soltar garante que o `collect` funcione e que o profile não fique órfão.

## Paralelismo

Profile `flow-enovalabs-pro` é sessão única — mesma restrição do Hub (`hub`/`hubv2`). Pra paralelo, usar clones do mesmo login: `flow-enovalabs-pro-2/3/4`. Mexer em duas abas do mesmo perfil ao mesmo tempo dá conflito de anexo (igual Hub).

## Receita de seletores (mapa 30/09/2026)

| Alvo | Seletor |
|---|---|
| Composer | `[contenteditable=true]` |
| Enviar | `button[aria-label='Iniciar geração']` |
| Settings | `button[aria-label='Configurações']` |
| Vídeo 9:16 | `button[role=radio]` com `innerText='crop_9_16\n9:16'` (segundo da lista, índice 10) |
| Confirm Sempre/Nunca | `input[type=radio]` em `mat-radio-group-2`, `value=2` = Nunca |
| Salvar | `button` com `innerText='Salvar'` |
| Thumbnail (abre modal) | `img[alt='Miniatura do vídeo gerada']` |
| Download mídia | `button[aria-label='Baixar mídia']` |
| Qualidade 720p | `button` com `innerText='720p\nTamanho original'` |
| Close modal | `button[aria-label='Botão "Voltar" para acessar a página anterior']` |
| Paste via ClipboardEvent | `dispatchEvent(new ClipboardEvent('paste', {clipboardData: dt, bubbles: true, cancelable: true}))` no composer focado |

## Profile único

| Profile | Porta | Estado verificado 30/09 |
|---|---|---|
| `flow-enovalabs-pro` | 9265 | logado Google conta `contato.inovalabsx`, gera imagem/vídeo OK |
