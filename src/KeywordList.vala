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

[GtkTemplate (ui = "/io/github/diegoivan/pdf_metadata_editor/gtk/keyword-list.ui")]
public class PaperClip.KeywordList : Adw.PreferencesGroup {
    [GtkChild]
    private unowned Gtk.ListBox listbox;

    public bool is_empty { get; private set; }

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
            is_empty = true;
            return;
        }

        int i = 0;
        Gtk.ListBoxRow? current_row;
        while ((current_row = listbox.get_row_at_index (i)) != null) {
            if (current_row == empty_state_row) {
                listbox.remove (empty_state_row);
                is_empty = false;
                break;
            }
            if (listbox.get_row_at_index (i+1) == null) {
                current_row.grab_focus ();
            }
            i++;
        }

        if (document.keywords.get_n_items () == 1) {
            listbox.get_first_child ().grab_focus ();
        }
    }

    private void create_default_row () {
        var center_box = new Gtk.CenterBox ();

        var label = new Gtk.Label (_("Add Keyword")) {
            justify = CENTER,
            wrap = true,
            margin_top = 12,
            margin_bottom = 12
        };

        center_box.center_widget = label;
        center_box.start_widget = new Gtk.Image.from_icon_name ("list-add-symbolic") {
            halign = END,
            hexpand = true,
            margin_end = 12
        };

        empty_state_row = new Adw.PreferencesRow () {
            child = center_box,
            activatable = true,
            selectable = false
        };

        listbox.append (empty_state_row);
    }

    [GtkCallback]
    private void on_row_activated (Gtk.ListBoxRow selected_row) {
        if (selected_row != empty_state_row) {
            return;
        }
        document.add_keyword ("");
    }

    [GtkCallback]
    private void on_add_button_clicked () {
        document.add_keyword ("");
    }
}
