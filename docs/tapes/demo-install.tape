# vibe-to-ship — install + first reality check, recorded against the real repo
Output ../assets/demo-install.gif
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

Type "git clone https://github.com/CyberTycoon/vibe-to-ship.git" Enter
Wait 1.5s

Type "cd vibe-to-ship" Enter
Wait 300ms

Type "./scripts/install.sh" Enter
Wait 1.2s

Type "./scripts/doctor.sh" Enter
Wait 1.4s

Ctrl+L
