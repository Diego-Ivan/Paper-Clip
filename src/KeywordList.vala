/* KeywordList.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class PaperClip.KeywordList : Adw.PreferencesGroup {
    private Gtk.ListBox listbox = new Gtk.ListBox ();
    private Gtk.Widget? empty_state_row = null;

    private unowned Document _document;
    public unowned Document document {
        get {
            return _document;
        }
        set {
            _document = value;
            listbox.bind_model (document.keywords, create_keyword_row);
            document.keywords.items_changed.connect (on_items_changed);
            on_items_changed ();
        }
    }

    construct {
        title = _("Keywords");

        var label = new Gtk.Label (_("Press the “+” button to add a keyword")) {
            justify = CENTER,
            hexpand = true,
            wrap = true
        };
        label.add_css_class ("dim-label");

        listbox.add_css_class ("boxed-list");
        add (listbox);

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            tooltip_text = _("Add a keyword")
        };

        add_button.clicked.connect (() => {
            document.add_keyword ("");
        });

        header_suffix = add_button;
    }

    private Gtk.Widget create_keyword_row (Object item) {
        var row = new KeywordRow () {
            title = _("Keyword"),
            document = document,
        };
        item.bind_property ("str", row, "text", SYNC_CREATE | BIDIRECTIONAL);

        return row;
    }

    private void on_items_changed () {
        if (document.keywords.get_n_items () == 0) {
            create_default_row ();
            return;
        }

        int i = 0;
        Gtk.Widget? current_row;
        while ((current_row = listbox.get_row_at_index (i)) != null) {
            if (current_row == empty_state_row) {
                listbox.remove (empty_state_row);
                break;
            }
            i++;
        }
    }

    private void create_default_row () {
        var label = new Gtk.Label (_("Press the “+” button to add a keyword")) {
            justify = CENTER,
            hexpand = true,
            wrap = true,
            margin_top = 12,
            margin_bottom = 12
        };
        label.add_css_class ("dim-label");

        empty_state_row = new Adw.PreferencesRow () {
            child = label,
            activatable = true
        };

        unowned var row = (Gtk.ListBoxRow) empty_state_row;
        row.activate.connect (() => {
            message ("Clicked");
        });

        listbox.append (empty_state_row);
    }
}
