# Mecânica: gerar vídeo no Google Flow (Veo 3.x)

> **STATUS: escrito a partir do conhecimento do produto, NÃO validado clique a clique
> nesta instalação.** Seletores e nomes de botão mudam. Antes da primeira leva, rode
> o protocolo de descoberta abaixo e corrija este arquivo com o que encontrar
> (só entra o que foi executado e verificado). Setup de browser: `browser-setup.md`.
> Motor equivalente ao Hub: mesmo Veo, sem intermediário — e sem o re-roteamento do Hub.

Flow = `https://labs.google/fx/tools/flow` (Google Labs). Precisa de conta Google com
plano que dê créditos de vídeo (AI Pro/Ultra) — a cota é da conta, vista na própria UI.

## Nesta máquina (já verificado em outra skill)

Perfis Flow logados no Google: `flow-enovalabs-pro` (9265) e clones `-2/-3/-4` (9266–9268) para
paralelo (`~/.claude/bin/flow-livre.sh <lane>` escolhe o livre). Modelo padrão **OmniFlash**
(menos crédito; sobe de modelo só se a qualidade não bastar). Flow faz imagem E animação (Veo)
na mesma casa. Fluxo verificado, seletores e regras: `tiktok-shop/references/formato-pov-bruno.md`
(seção Google Flow) — prevalece sobre este arquivo quando divergir.

## Diferenças que importam para o criativo

| Ponto | Hub | Flow |
|---|---|---|
| Entrada | Imagem→Vídeo (anexo) | **Frames to Video** (imagem = 1º frame; opcional 2º frame = último) |
| Modelo | Veo 3.1 Quality | escolher **Veo 3.1 – Quality** (não Fast) no seletor de modelo |
| Proporção | chip Aspect | **9:16** no menu de configurações do prompt |
| Saídas por prompt | 1 | 1 a 4 (**use 1**, cada saída gasta crédito) |
| Áudio/fala | gerado com o vídeo | gerado com o vídeo (Veo 3.x); a fala vem do prompt |
| Organização | histórico da conta | **projetos** (crie 1 projeto por criativo; nome = lane) |
| Download | por `src` | menu do clipe → resolução (720p original; 1080p = upscale) |

Os blocos de prompt (CANON_VOICE, anti-morphing, dentes, lip-sync, orçamento de
palavras) são os MESMOS do SKILL.md deste orq. O que muda é só o teclado.

## Sequência de envio (mesma disciplina do Hub)

1. `S=$(~/.claude/bin/flow-livre.sh <lane>)` → abre o Flow na sua aba.
2. Abra/crie o **projeto** do criativo (um por criativo).
3. Modo **Frames to Video**. Anexe a imagem da cena (upload no campo de frame
   inicial) e **confira que entrou exatamente 1 frame** e que é a da cena.
4. Configurações: modelo Veo 3.1 Quality · 9:16 · saídas = 1 · duração 8s.
   **Releia depois de qualquer reload ou erro** — configuração pode resetar.
5. Cole o prompt (mesmo setter nativo de textarea/contenteditable do Hub: dispare
   `input` depois). Compare o que entrou com o arquivo do prompt (tamanho e cauda).
6. `Enviar` **uma vez**. Prova de envio = card do clipe aparece em "gerando"/o
   contador de créditos desce. Sem retry rápido.
7. Espere por polling (geração leva minutos). Se falhar, LEIA a mensagem: política de
   conteúdo (mude o prompt), fila/saturação (espere), crédito (pare).
8. Baixe o clipe (menu do card → Download → 720p). Salve como `<lane>-cena-N.mp4`.
   Valide com `ffprobe` (duração, 720×1280, áudio) — mesmo gate do Hub.
9. Antes da cena seguinte: limpe o frame anexado e o prompt (não confie que limpou).

## Protocolo de descoberta (rode 1x, depois grave o resultado aqui)

```bash
S=$(~/.claude/bin/flow-livre.sh descoberta)
agent-browser --session $S snapshot -i -c      # lista botões/inputs com refs
agent-browser --session $S screenshot /tmp/flow-1.png
```
Anote: (a) como se cria projeto, (b) onde fica o seletor Frames→Video, (c) o
`aria-label`/texto do upload e do botão de gerar, (d) onde aparece o contador de
créditos, (e) o caminho do Download. Depois cole a tabela verificada abaixo:

| Elemento | Seletor/texto verificado | Data |
|---|---|---|
| _(vazio: preencher na primeira execução)_ | | |

## Quando usar Flow em vez do Hub

- Sem assinatura do Hub, ou cota do Veo do Hub esgotada.
- Hub devolvendo "Google Flow rejeitou a geração" em série (o Hub re-roteia para o
  próprio Flow — ir direto tira o intermediário).
- Precisa do último frame controlado (2º frame) para emendar cenas.
