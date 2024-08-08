/* DropOverlay.vala
 *
 * Copyright 2024 Diego Iván M.E <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class PaperClip.DropOverlay : Adw.Bin {
    private Gtk.Overlay internal_overlay = new Gtk.Overlay ();
    private Gtk.Revealer internal_revealer = new Gtk.Revealer ();

    private Gtk.DropTarget _drop_target;
    public Gtk.DropTarget drop_target {
        get {
            return _drop_target;
        }
        set {
            _drop_target = value;
            _drop_target.notify["current-drop"].connect (on_current_drop_notify);
        }
    }

    public Gtk.Widget overlayed {
        get {
            return internal_revealer.child;
        }
        set {
            internal_revealer.child = value;
        }
    }

    public new Gtk.Widget child {
        get {
            return internal_overlay.child;
        }
        set {
            internal_overlay.child = value;
        }
    }

    construct {
        ((Adw.Bin) this).child = internal_overlay;
        internal_overlay.add_overlay (internal_revealer);
        internal_revealer.can_target = false;
        internal_revealer.visible = false;
        internal_revealer.transition_type = CROSSFADE;
    }

    private void on_current_drop_notify () {
        Gdk.Drop drop = drop_target.current_drop;

        if (drop != null) {
            internal_revealer.reveal_child = true;
            internal_revealer.visible = true;
            overlayed.add_css_class ("overlay-drag-area");
        } else {
            internal_revealer.reveal_child = false;
            internal_revealer.visible = false;
            overlayed.remove_css_class ("overlay-drag-area");
        }
    }
}
