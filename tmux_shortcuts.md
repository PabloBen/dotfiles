# TMUX Configurations

### Basic
| **Action**  | **Command**      |
| :---------- | :--------------- |
| Prefix      | `Ctrl + [space]` |
| Source file | `Prefix + r`     |

### Session
| **Action**     | **Command**  |
| :------------- | :----------- |
| Create session | `Alt + s`    |
| Rename session | `Prefix + q` |
| Kill session   | `Alt + x`    |
| Choose session | `Alt + q`    |

### Window
| **Action**        | **Command**           |
| :---------------- | :-------------------- |
| Create window     | `Prefix + w`          |
| Rename window     | `Prefix + n`          |
| Move window left  | `Alt + Shift + Left`  |
| Move window right | `Alt + Shift + Right` |

### Panes
| **Action**       | **Command**   |
| :--------------- | :------------ |
| Split horizontal | `Alt + v`     |
| Split vertical   | `Alt + h`     |
| Move pane left   | `Alt + Left`  |
| Move pane right  | `Alt + Right` |
| Move pane up     | `Alt + Up`    |
| Move pane down   | `Alt + Down`  |
| Kill pane        | `Alt + d`     |

### Advanced
| **Action**           | **Command**         |
| :------------------- | :------------------|
| Resize pane left     | `Prefix + Left`    |
| Resize pane right    | `Prefix + Right`   |
| Resize pane up       | `Prefix + Up`      |
| Resize pane down     | `Prefix + Down`    |
| Copy mode            | `Prefix + [`       |
| Paste buffer         | `Prefix + ]`       |
| Search in copy mode  | `/` (in copy mode) |
| Synchronize panes    | `Prefix + :setw synchronize-panes on` |
| Install plugins (TPM)| `Prefix + I`       |
| Update plugins (TPM) | `Prefix + U`       |
| Reload config        | `Prefix + r`       |

---

### Troubleshooting
- **Mouse not working?** Ensure `set -g mouse on` is in your config and restart tmux.
- **Prefix not responding?** Check for conflicts with your window manager or other keybindings.
- **Plugin issues?** Run `Prefix + I` to reinstall plugins, and check plugin paths in your config.

### Customization Tips
- **Change prefix:** Edit the `set -g prefix` line in your config.
- **Add plugins:** Add plugin lines under the TPM section and reload config, then run `Prefix + I`.
- **Symlink config:** Use `ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf` for tmux to auto-load your config.