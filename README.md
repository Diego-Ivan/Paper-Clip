<div align="center">
# Hidden Scribe

A PDF metadata editor, written in Vala and GTK
</div>

## GNOME Builder

Hidden Scribe comes with a Flatpak manifest, and it it can be compiled and executed in GNOME Builder just by cloning the repository and clicking on the play button.

## Manual Building

The following are required to build Hidden Scribe


```
libpoppler
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