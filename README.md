# Geo Dash ✦

**Geo Dash** is a fast-paced 2D runner built with LÖVE (Love2D). Guide a small geometric hero through scrolling levels filled with spikes, platforms, traps, and precision jumps. Timing is everything — one mistake ends the run.

---

## 🎯 Features
- Auto-scrolling, precision-platformer gameplay
- Multiple handcrafted levels with unique background themes
- Collectible coins and level progression
- Theme customization per level (`theme` in `level.lua`) and background parameters in `backgroundstate.lua`

---

## ▶️ How to Play
**Controls**
- Left Click or Space: Jump
- Hold Left Click: Keep jumping (if applicable)

Tips:
- Time your jumps precisely when approaching spikes or gaps.
- Watch the level-specific theme and scroll speed — they affect gameplay feel.

---

## ⚙️ Run locally
1. Install LÖVE (https://love2d.org/)
2. In this project folder run:

   ```bash
   love .
   ```

(Or on Windows, drag the project folder onto `love.exe`.)

---

## 🧩 Project structure (important files)
- `main.lua` – game entry, state handling, and draw loop
- `conf.lua` – global constants, `Color` table, and UI tables (Buttons, LevelButtons)
- `helper.lua` – UI helpers, drawing buttons, and utility functions
- `level.lua` – level definitions and `theme` values
- `backgroundstate.lua` – theme visuals and particle/background settings
- `Sprites/` – image assets used by the game

---

## ✍️ Development notes
- Centralize visual settings in `conf.lua` (colors, button tables) to keep UI consistent.
- Add new sprites to `Sprites/` and update `LoadSprites()` in `conf.lua`.
- To add a level, edit `level.lua` and add an entry to the levels table (include `theme` and `scrollSpeed` where appropriate).

---

## ❤️ Credits
- **Muhammad Arsal** — Developer / Designer
- **Gotham Kumar** — Helper / Music

---

## Contributing
Contributions, bug reports, and improvements are welcome — open an issue or send a PR. Keep changes focused and include brief notes about why the change is needed.

---

Happy hacking — enjoy the timing!