/*
cleanup.ts — script post-render : supprime les fichiers intermédiaires inutiles
après `quarto render` (le thème ne produit que du PDF).

Pour chaque document source (.qmd, .ipynb, .md, .Rmd) du projet, supprime à
côté de la source et dans le dossier de sortie :
  - <nom>.html
  - <nom>_files/
  - <nom>_html/

Les fichiers réellement produits par le rendu en cours (par ex. si un format
HTML est demandé explicitement) sont conservés.

Activation dans _quarto.yml :

  project:
    post-render:
      - _extensions/fabrizioalbertetti/theme-hearc-assignments/cleanup.ts

Le script est exécuté par le Deno intégré à Quarto : aucune dépendance.
*/

const SOURCE_EXT = /\.(qmd|ipynb|md|rmd)$/i;
const SKIP_DIRS = new Set([".git", ".quarto", ".drawio-cache", "node_modules", "_extensions", "renv", ".venv", "venv"]);

const root = Deno.cwd();
const sep = Deno.build.os === "windows" ? "\\" : "/";
const join = (...p: string[]) => p.join(sep);
const norm = (p: string) => p.replace(/[\\/]+/g, "/").replace(/\/$/, "").toLowerCase();

// Fichiers produits par ce rendu : à ne jamais supprimer.
const produced = new Set(
  (Deno.env.get("QUARTO_PROJECT_OUTPUT_FILES") ?? "")
    .split(/\r?\n/)
    .filter((f) => f.trim() !== "")
    .map((f) => norm(f.startsWith("/") || /^[a-z]:/i.test(f) ? f : join(root, f))),
);

function isProduced(path: string): boolean {
  const p = norm(path);
  for (const f of produced) {
    if (f === p || f.startsWith(p + "/")) return true;
  }
  return false;
}

// Recense les documents sources (nom sans extension) et les dossiers à nettoyer.
const stems = new Set<string>();
const dirs = new Set<string>([root]);

function walk(dir: string) {
  for (const entry of Deno.readDirSync(dir)) {
    if (entry.isDirectory) {
      if (SKIP_DIRS.has(entry.name) || /_(files|html)$/.test(entry.name)) continue;
      walk(join(dir, entry.name));
    } else if (entry.isFile && SOURCE_EXT.test(entry.name)) {
      stems.add(entry.name.replace(SOURCE_EXT, ""));
      dirs.add(dir);
    }
  }
}
walk(root);

const outDir = Deno.env.get("QUARTO_PROJECT_OUTPUT_DIR");
if (outDir) dirs.add(outDir.startsWith("/") || /^[a-z]:/i.test(outDir) ? outDir : join(root, outDir));

let removed = 0;
for (const dir of dirs) {
  for (const stem of stems) {
    // Une sortie HTML produite a besoin de ses ressources (<nom>_files/).
    if (isProduced(join(dir, `${stem}.html`))) continue;
    for (const name of [`${stem}.html`, `${stem}_files`, `${stem}_html`]) {
      const path = join(dir, name);
      if (isProduced(path)) continue;
      try {
        Deno.removeSync(path, { recursive: true });
        removed++;
        console.log(`[cleanup] supprimé : ${path.slice(root.length + 1) || path}`);
      } catch (e) {
        if (!(e instanceof Deno.errors.NotFound)) {
          console.error(`[cleanup] impossible de supprimer ${path} : ${e}`);
        }
      }
    }
  }
}
if (removed === 0) console.log("[cleanup] rien à supprimer");
