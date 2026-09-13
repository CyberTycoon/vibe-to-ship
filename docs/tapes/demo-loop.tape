# vibe-to-ship — the 5-beat loop, recorded live against the real scripts
Output ../assets/demo-loop.gif
Set FontSize 19
Set Width 1180
Set Height 620
Set Padding 24
Set Shell bash
Set Theme {
  "name": "openlotus",
  "background": "#0d0d0c",
  "foreground": "#f6f5f2",
  "cursor": "#f6f5f2",
  "black": "#0d0d0c",
  "red": "#e5484d",
  "green": "#46a758",
  "yellow": "#f5a623",
  "blue": "#52a9ff",
  "magenta": "#c084fc",
  "cyan": "#4ccce6",
  "white": "#f6f5f2",
  "brightBlack": "#7c7a75",
  "brightGreen": "#46a758",
  "brightYellow": "#f5a623"
}

Type "cd /tmp/vts-demo" Enter
Wait 400ms

Type "./scripts/loop.sh triage" Enter
Wait 1.2s

Type "./scripts/loop.sh act" Enter
Wait 1.6s

Type "./scripts/loop.sh verify --scope \"src/api.ts\"" Enter
Wait 1.2s

Type "./scripts/loop.sh learn" Enter
Wait 1s

Ctrl+L
