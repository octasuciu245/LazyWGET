# LazyWGET

A stateful recursive web crawler written in **Bash** that implements a **lazy evaluation** paradigm. Instead of downloading an entire website tree at once like `wget -r`, `LazyWGET` crawls one depth level per execution, giving the user full control to inspect downloaded HTML pages before expanding to the next level.

Developed as a team project (*The Hobbit*) for the *Basic Tools and Techniques in Computer Science* course at the University of Bucharest.

## How It Works

The script operates as a finite-state machine using **file-system-based state** (no external database required):

- **Level Detection (`get_last_level`):** Scans `lwget_data/` for existing `nivel_X` directories using natural version sorting (`sort -V`) to determine the current crawl depth.
- **Step 1 (Initialization):** On the first run (`./lwget.sh <URL>`), it creates `lwget_data/nivel_0/`, downloads the seed page, and logs the URL in `visited.log`.
- **Step 2 (Lazy Expansion):** On each subsequent run (`./lwget.sh`), it parses all HTML files from the previous level (`nivel_X`), extracts absolute HTTP/HTTPS `href` links ("promises") via extended regex (`grep -oE`, `cut`), skips already visited URLs (`grep -Fqx`), and downloads new pages into `nivel_X+1`.

## Features

- **Step-by-Step Depth Control:** Inspect or filter each level before triggering the next download wave.
- **Deduplication & Loop Prevention:** Tracks all downloaded URLs in `lwget_data/visited.log` to prevent duplicate downloads and infinite crawling cycles.
- **Resilient Networking:** Uses `wget` with a 5-second timeout (`-T 5`) and single retry (`-t 1`), checking exit codes (`$?`) so dead links never crash the script.
- **Safe File Handling:** Uses `shopt -s nullglob` to safely handle empty directories and automatically removes empty level folders.
- **Directory Visualization:** Displays the current crawl hierarchy using `tree` (if installed).

## Tech Stack

- **Shell:** Bash (Linux / Unix)
- **CLI Utilities:** `wget`, `grep`, `cut`, `sort`, `tail`, `tree` (optional)

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/octasuciu245/LazyWGET.git
   ```
2. Make the script executable:
   ```bash
   chmod +x lwget.sh
   ```
3. Run the first level with a seed URL:
   ```bash
   ./lwget.sh http://info.cern.ch
   ```
4. Expand to the next depth level (repeat as needed):
   ```bash
   ./lwget.sh
   ```

## Known Limitations

- Parses only absolute `http://` and `https://` links from `href` attributes (relative paths and `src` assets like images/CSS are intentionally excluded to keep the prototype focused on navigable HTML documents).

## Authors

- **Octavian-Constantin Suciu**
- **Răzvan-Mihai Marin**
