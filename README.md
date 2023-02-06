<div align="center">

# PDF Metadata Editor

<img src="data/icons/hicolor/scalable/apps/io.github.diegoivan.pdf_metadata_editor.svg" width="160" height="160"></img>

**Edit PDF document metadata**

<a href="https://flathub.org/apps/details/io.github.diegoivan.pdf_metadata_editor">
    <img width="200" src="https://flathub.org/assets/badges/flathub-badge-en.png" alt="Download on Flathub">
</a>

</div>

## Features

Edit:

* Title
* Author
* Creator
* Producer
* Creation Date
* Modification Date
* Keywords

## Flathub

The only official distribution format for PDF Metadata Editor is Flathub. Any other distribution format is unofficial and disencouraged.

## GNOME Builder

PDF Metadata Editor comes with a Flatpak manifest, and it it can be compiled and executed in GNOME Builder just by cloning the repository and clicking on the play button.

## Manual Building

The following are required to build PDF Metadata Editor

```
libpoppler
libportal
libportal-gtk4
libadwaita-1
gtk4
glib-2.0
gio-2.0
gobject-2.0
valac
meson
ninja
```

Clone the repository, and in the directory, run:

```
meson builddir
cd builddir
meson compile
```
