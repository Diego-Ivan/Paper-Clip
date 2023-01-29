/* DocumentView.vala
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

[GtkTemplate (ui = "/io/github/diegoivan/hidden_scribe/gtk/document-view.ui")]
public class HiddenScribe.DocumentView : Adw.Bin {
    [GtkChild]
    private unowned EntryRow title_row;
    [GtkChild]
    private unowned EntryRow author_row;
    [GtkChild]
    private unowned EntryRow creator_row;
    [GtkChild]
    private unowned EntryRow subject_row;
    [GtkChild]
    private unowned EntryRow producer_row;
    [GtkChild]
    private unowned DateRow creation_row;
    [GtkChild]
    private unowned DateRow modification_row;
    [GtkChild]
    private unowned Gtk.ListBox keyword_box;

    private Binding doc_to_win;
    private Document _document;
    public Document document {
        get {
            return _document;
        }
        set {
            unbind_doc ();
            _document = value;

            title_row.object = document;
            author_row.object = document;
            creator_row.object = document;
            subject_row.object = document;
            producer_row.object = document;
            creation_row.object = document;
            modification_row.object = document;
            keyword_box.bind_model (document.keywords, create_keyword_row);

            unowned var window = (Window) get_root ();
            doc_to_win = document.bind_property ("title", window, "title", SYNC_CREATE);

            var manager = new Services.DocManager ();
            manager.document = document;
        }
    }

    private Gtk.Widget create_keyword_row (Object item) {
        var row = new KeywordRow () {
            property_name = "str",
            title = "Keyword",
            object = item,
            document = document,
        };

        return row;
    }

    [GtkCallback]
    private void on_add_button_clicked () {
        document.add_keyword ("");
    }

    private void unbind_doc () {
        if (doc_to_win == null) {
            return;
        }
        doc_to_win.unbind ();
    }
}
