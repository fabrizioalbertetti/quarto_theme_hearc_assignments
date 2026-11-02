# Extension Quarto : thème de séries/devoirs HE-Arc Ingénierie (PDF)


Extension de format Quarto pour produire des supports de cours PDF au format
A4 avec la classe LaTeX `scrartcl`, une numérotation des sections et l’en-tête
avec le logo, la classe et le cours. Le pied de page peut afficher un texte
configurable et conserve la pagination.

## Prérequis

- [Quarto](https://quarto.org/docs/get-started/)
- Une distribution LaTeX compatible avec Quarto, par exemple TinyTeX ou MiKTeX
- La classe KOMA-Script (`scrartcl`), généralement fournie avec la distribution
  LaTeX

## Utiliser l’exemple de ce dépôt

Le dépôt contient les sources de l’extension dans
`_extensions/theme-hearc-assignment/`. L’exemple
[`example/serie_01.qmd`](example/serie_01.qmd) utilise cette copie
locale et ses illustrations dans `example/images/`. Depuis la racine du dépôt,
générez son PDF avec :

```sh
quarto render example/serie_01.qmd
```

Le résultat est créé dans `_output/example/serie_01.pdf`. Le dossier
`_output/` est configuré comme répertoire de rendu dans `_quarto.yml`; Quarto
conserve dans ce dossier le chemin relatif du document source.

## Installer l’extension depuis GitHub

Dans le dossier de votre projet Quarto, installez l’extension publiée dans
ce dépôt GitHub :

```sh
quarto add fabrizioalbertetti/quarto_theme_hearc_assignment/extension
```

Cette commande télécharge l’extension dans le dossier `_extensions` du
projet. Elle doit être exécutée une fois par projet, puis à nouveau pour
mettre à jour l’extension. Sélectionnez ensuite le format
`theme-hearc-assignment-pdf` dans le front matter de votre document :

```yaml
---
course:
  class: "ISC3"
  short: "IA"
  footer: "Support de cours"

title: "Titre du cours"
subtitle: "Sous-titre"
author: "Nom de l’enseignant·e"
date: today
lang: fr
format:
  theme-hearc-assignment-pdf:
    toc: true
    toc-depth: 2
---
```

Le format affiche `course.class - course.short` dans l’en-tête et `course.footer`
dans le pied de page. Ces valeurs doivent être définies dans le `_quarto.yml`
du projet ou les métadonnées du document.

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

- `_extension.yml` définit le format PDF `theme-hearc-assignment-pdf` et ses
  options par défaut.
- `before-title.tex` configure l’en-tête et le pied de page avec
  `scrlayer-scrpage` et les métadonnées du cours.
- `logo-he-arc-ing.jpg` est copié dans le dossier du document lors du rendu,
  afin que le PDF puisse utiliser le logo.

Le format conserve les fonctionnalités PDF de Quarto, notamment les tables,
les images, les références croisées et les bibliographies.
