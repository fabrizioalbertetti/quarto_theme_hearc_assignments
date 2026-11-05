--[[
drawio.lua — inclut directement des diagrammes draw.io dans un document Quarto.

Usage dans le .qmd :
  ![Légende](images/schema.drawio.svg){#fig-schema width=90%}
  ![Légende](images/schema.drawio){#fig-schema width=90%}

- Sortie PDF/LaTeX : le diagramme est exporté en PDF vectoriel (recadré) via
  le CLI de draw.io Desktop. Plus besoin de rsvg-convert ni d'export manuel.
- Sortie HTML : un .drawio.svg est laissé tel quel ; un .drawio est exporté en SVG.
- Autres sorties (docx, pptx, ...) : export en PNG.

Les exports sont mis en cache dans `.drawio-cache/` (clé = hash du contenu du
fichier source) : un diagramme n'est réexporté que s'il a été modifié.

Emplacement de draw.io : détection automatique, ou variable d'environnement
DRAWIO_CMD (chemin complet vers l'exécutable).
]]

local CACHE_DIR = ".drawio-cache"

local function file_exists(path)
  local f = io.open(path, "rb")
  if f then f:close() return true end
  return false
end

local function read_file(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local content = f:read("a")
  f:close()
  return content
end

local drawio_cmd -- nil = pas encore cherché, false = introuvable

local function find_drawio()
  if drawio_cmd ~= nil then return drawio_cmd end
  local candidates = {}
  local env = os.getenv("DRAWIO_CMD")
  if env and env ~= "" then table.insert(candidates, env) end
  local localappdata = os.getenv("LOCALAPPDATA")
  local programfiles = os.getenv("ProgramFiles")
  if programfiles then
    table.insert(candidates, programfiles .. "\\draw.io\\draw.io.exe")
  end
  if localappdata then
    table.insert(candidates, localappdata .. "\\Programs\\draw.io\\draw.io.exe")
  end
  table.insert(candidates, "/Applications/draw.io.app/Contents/MacOS/draw.io")
  table.insert(candidates, "/usr/bin/drawio")
  table.insert(candidates, "/usr/local/bin/drawio")
  table.insert(candidates, "/snap/bin/drawio")
  table.insert(candidates, "/opt/drawio/drawio")
  for _, c in ipairs(candidates) do
    if file_exists(c) then
      drawio_cmd = c
      return c
    end
  end
  drawio_cmd = false
  return false
end

local function output_extension()
  if quarto.doc.is_format("latex") or quarto.doc.is_format("pdf") then
    return "pdf"
  elseif quarto.doc.is_format("html") then
    return "svg"
  else
    return "png"
  end
end

local function export(src, ext)
  local content = read_file(src)
  if not content then
    quarto.log.warning("[drawio] fichier introuvable : " .. src)
    return nil
  end

  local stem = pandoc.path.filename(src):gsub("%.drawio%.svg$", ""):gsub("%.drawio$", "")
  local hash = pandoc.utils.sha1(content):sub(1, 10)
  -- "/" volontairement (pas le séparateur OS) : LaTeX refuse les "\" dans les chemins.
  local out = CACHE_DIR .. "/" .. stem .. "-" .. hash .. "." .. ext
  if file_exists(out) then return out end

  local cmd = find_drawio()
  if not cmd then
    quarto.log.error(
      "[drawio] draw.io Desktop introuvable (nécessaire pour convertir " .. src .. ").\n" ..
      "Installez-le (https://www.drawio.com) ou définissez DRAWIO_CMD vers l'exécutable.")
    return nil
  end

  pandoc.system.make_directory(CACHE_DIR, true)
  local args = { "--export", "--format", ext, "--crop", "--output", out }
  if ext == "png" then
    table.insert(args, "--scale")
    table.insert(args, "2")
  end
  if pandoc.system.os == "linux" then
    table.insert(args, "--no-sandbox")
  end
  table.insert(args, src)

  quarto.log.output("[drawio] export " .. src .. " -> " .. out)
  local ok, err = pcall(pandoc.pipe, cmd, args, "")
  if not ok or not file_exists(out) then
    quarto.log.error("[drawio] échec de l'export de " .. src .. " : " .. tostring(err))
    return nil
  end
  return out
end

function Image(img)
  local src = img.src
  local is_drawio_svg = src:match("%.drawio%.svg$") ~= nil
  local is_drawio = src:match("%.drawio$") ~= nil
  if not (is_drawio_svg or is_drawio) then return nil end

  local ext = output_extension()
  -- Un .drawio.svg est déjà un SVG valide pour le HTML.
  if ext == "svg" and is_drawio_svg then return nil end

  local out = export(src, ext)
  if out then
    img.src = out
    return img
  end
  return nil
end
