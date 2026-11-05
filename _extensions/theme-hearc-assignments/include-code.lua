--[[
include-code.lua — affiche le contenu d'un fichier source dans un bloc de code.

Usage dans le .qmd (le bloc est laissé vide) :

  ```{.python include="code/exemple.py"}
  ```

  ```{.python include="code/exemple.py" start-line=4 end-line=12 .numberLines}
  ```

Attributs :
- include    : chemin du fichier, relatif au document .qmd ;
- start-line : première ligne à afficher (défaut : 1) ;
- end-line   : dernière ligne à afficher (défaut : fin du fichier).

Le code n'est pas exécuté : il est seulement affiché, avec la coloration
syntaxique correspondant à la classe du bloc (.python, .java, .c, ...).
Avec .numberLines, la numérotation reprend celle du fichier (start-line).
Les attributs habituels de Quarto restent utilisables (filename=, ...).
]]

local function read_lines(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local content = f:read("a")
  f:close()
  -- Normalise les fins de ligne (fichiers Windows) et retire le BOM UTF-8.
  content = content:gsub("^\239\187\191", ""):gsub("\r\n?", "\n")
  local lines = {}
  for line in (content .. "\n"):gmatch("(.-)\n") do
    table.insert(lines, line)
  end
  -- Supprime la dernière ligne vide due au saut de ligne final.
  if #lines > 0 and lines[#lines] == "" then table.remove(lines) end
  return lines
end

function CodeBlock(block)
  local path = block.attributes["include"]
  if not path then return nil end

  local lines = read_lines(path)
  if not lines then
    quarto.log.error("[include-code] fichier introuvable : " .. path)
    return nil
  end

  local first = tonumber(block.attributes["start-line"]) or 1
  local last = tonumber(block.attributes["end-line"]) or #lines
  first = math.max(first, 1)
  last = math.min(last, #lines)
  if first > last then
    quarto.log.warning(string.format(
      "[include-code] plage vide (%d-%d) pour %s", first, last, path))
  end

  local selected = {}
  for i = first, last do table.insert(selected, lines[i]) end
  block.text = table.concat(selected, "\n")

  block.attributes["include"] = nil
  block.attributes["start-line"] = nil
  block.attributes["end-line"] = nil
  if first > 1 and block.attributes["startFrom"] == nil then
    block.attributes["startFrom"] = tostring(first)
  end
  return block
end
