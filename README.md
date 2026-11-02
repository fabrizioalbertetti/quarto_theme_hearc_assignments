# theme-hearc-handout

Extension de format Quarto pour produire des supports de cours PDF au format
A4 avec la classe LaTeX `scrartcl`, une numérotation des sections et l’en-tête
HE-Arc (logo et pagination).

## Prérequis

- [Quarto](https://quarto.org/docs/get-started/)
- Une distribution LaTeX compatible avec Quarto, par exemple TinyTeX ou MiKTeX
- La classe KOMA-Script (`scrartcl`), généralement fournie avec la distribution
  LaTeX

## Utiliser l’exemple de ce dépôt

Le dépôt contient les sources de l’extension dans
`_extensions/theme-hearc-handout/`. L’exemple
[`example/instructions.qmd`](example/instructions.qmd) utilise cette copie
locale et ses illustrations dans `example/images/`. Depuis la racine du dépôt,
générez son PDF avec :

```sh
quarto render example/instructions.qmd
```

Le résultat est créé dans `_output/example/instructions.pdf`. Le dossier
`_output/` est configuré comme répertoire de rendu dans `_quarto.yml`; Quarto
conserve dans ce dossier le chemin relatif du document source.

## Installer l’extension depuis GitHub

Dans le dossier de votre projet Quarto, installez l’extension publiée dans
ce dépôt GitHub :

```sh
quarto add fabrizioalbertetti/quarto_theme_hearc_handout
```

Cette commande télécharge l’extension dans le dossier `_extensions` du
projet. Elle doit être exécutée une fois par projet, puis à nouveau pour
mettre à jour l’extension. Sélectionnez ensuite le format
`theme-hearc-handout-pdf` dans le front matter de votre document :

```yaml
---
title: "Titre du cours"
subtitle: "Sous-titre"
author: "Nom de l’enseignant·e"
date: today
lang: fr
format:
  theme-hearc-handout-pdf:
    toc: true
    toc-depth: 2
---
```

Rendez ensuite le document avec :

```sh
quarto render mon-cours.qmd
```

La date et les options du format peuvent être adaptées dans le front matter.
Les options Quarto définies sur le document remplacent les valeurs par défaut
de l’extension.

Pour enregistrer également le rendu d’un projet utilisant l’extension dans un
dossier `_output`, définissez ce dossier dans le `_quarto.yml` du projet :

```yaml
project:
  output-dir: _output
```

## Contenu de l’extension

- `_extension.yml` définit le format PDF et ses options par défaut.
- `header.tex` configure l’en-tête et le pied de page avec `scrlayer-scrpage`.
- `logo-he-arc-ing.jpg` est copié dans le dossier du document lors du rendu,
  afin que le PDF puisse utiliser le logo.

Le format conserve les fonctionnalités PDF de Quarto, notamment les tables,
les images, les références croisées et les bibliographies.
