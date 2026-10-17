# Identité visuelle LyraMusic

Source : les fichiers fournis dans `assets/logo/` à la racine du dépôt.

- **Logo** : `logo_concept_1.png`. Le logo global « LYRA / MUSIC » (le R est un vinyle) est utilisé
  pour l'écran de démarrage animé. Le symbole R-vinyle sert d'icône d'application.
- **Charte** : `charte_graphique.png` (noir profond #111111, crème #F3EBD8, composants, icônes
  arrondies). Les couleurs sable, taupe et sauge viennent de `charte_graphique_2.png` et sont
  proposées comme couleur principale au choix.
- **Polices** : Nunito (titres, proche de la « Poppins Rounded » de la charte) et Inter (texte),
  dans `assets/fonts/`, licence SIL OFL 1.1.

## Fichiers (`logo/`)

| Fichier | Usage |
|---|---|
| `lyra-logo-clair.svg/.png` | Logo global, noir sur crème |
| `lyra-logo-sombre.svg/.png` | Logo global, crème sur noir |
| `lyra-logo-transparent.svg` | Logo global sans fond |
| `lyra-symbole-sombre.svg`, `-1024.png` | Icône d'application (fond noir) |
| `lyra-symbole-clair.svg`, `-1024.png` | Icône d'application (fond crème) |

Icônes de stores : `../icon/app-icon-1024.png`, `../icon/app-icon-store-512.png`.

## Régénérer

Le logo a été vectorisé (potrace) depuis `logo_concept_1.png`. Les scripts sont dans `source/` :

```bash
pip install potracer pillow numpy
python assets/brand/source/trace.py   # vectorise le logo → wm.json
python assets/brand/source/gen.py     # génère lib/ui/brand/logo_paths.dart, les SVG et les vecteurs Android
```

`gen.py` produit aussi les icônes Android (`ic_launcher_foreground`, `ic_launcher_monochrome`,
`ic_stat_lyra`, `splash_logo`). Le vinyle du R est une forme séparée : c'est ce qui permet de le
faire tourner dans l'animation de démarrage et dans l'application.
