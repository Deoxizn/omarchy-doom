pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

Panel {
  id: root

  moduleName: "com.user.doom"
  manageIpc: false

  readonly property string binary: setting("binary", "doomretro")
  readonly property string userWad: setting("wad", "")
  readonly property string extraArgs: setting("extraArgs", "")

  property string detectedWad: ""
  readonly property string wad: userWad.length > 0 ? userWad : detectedWad
  property bool configReady: false

  readonly property bool isRunning: doomProcess.running
  readonly property string glyph: isRunning ? "🔥" : "💀"
  readonly property string tooltipText: isRunning
    ? "DOOM is running \u2014 click to kill"
    : "Click to RIP AND TEAR"

  function setting(name, fallback) {
    const value = settings ? settings[name] : undefined
    return value === undefined || value === null || value === "" ? fallback : value
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: {
    configSetup.running = true
    wadDetector.running = true
  }

  // Auto-create doomretro.cfg with windowed defaults on first run
  Process {
    id: configSetup
    command: ["bash", "-c",
      "CFG=\"$HOME/.config/doomretro/doomretro.cfg\"; " +
      "if [ ! -f \"$CFG\" ]; then " +
      "  mkdir -p \"$(dirname \"$CFG\")\"; " +
      "  cat > \"$CFG\" << 'EOF'\n" +
      "vid_fullscreen                   off\n" +
      "vid_widescreen                   on\n" +
      "vid_borderlesswindow             off\n" +
      "vid_screenresolution             desktop\n" +
      "vid_windowpos                    centered\n" +
      "vid_windowsize                   960x600\n" +
      "r_screensize                     8\n" +
      "EOF\n" +
      "fi; " +
      // Also patch existing config to windowed if still fullscreen
      "sed -i 's/^vid_fullscreen\\s\\+on$/vid_fullscreen                   off/' \"$CFG\" 2>/dev/null; " +
      "echo done"]
    onExited: root.configReady = true
  }

  // Auto-detect WAD files
  Process {
    id: wadDetector
    command: ["bash", "-c",
      "for d in ~/Games/doom ~/doom ~/.local/share/doom /usr/share/doom; do " +
      "  for f in \"$d\"/DOOM*.WAD \"$d\"/doom*.wad; do " +
      "    [ -f \"$f\" ] && echo \"$f\" && exit 0; " +
      "  done; " +
      "done; exit 1"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var path = String(text || "").trim()
        if (path.length > 0)
          root.detectedWad = path
      }
    }
  }

  Process {
    id: doomProcess
  }

  function launchDoom() {
    var cmd = [root.binary]
    if (root.wad.length > 0)
      cmd.push("-iwad", root.wad)
    if (root.extraArgs.length > 0)
      cmd.push(...root.extraArgs.split(" ").filter(a => a.length > 0))
    doomProcess.command = cmd
    doomProcess.running = true
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.glyph
    tooltipText: root.tooltipText
    active: root.isRunning
    onPressed: function(_button) {
      if (doomProcess.running) {
        doomProcess.signal(9)
      } else {
        root.launchDoom()
      }
    }
  }
}
