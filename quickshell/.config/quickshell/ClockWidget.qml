import QtQuick

Text {
  // directly access the time property from the Time singleton
  text: TimeSource.time
  color: 'green'
  font.bold: true
  font.family: 'JetBrainsMono Nerd Mono'
}
