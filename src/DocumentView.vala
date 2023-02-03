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
    [GtkChild]
    private unowned Adw.StatusPage document_status;

    private Document _document;
    public Document document {
        get {
            return _document;
        }
        set {
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
            document.bind_property ("title", window, "title", SYNC_CREATE);

            var manager = new Services.DocManager ();
            manager.document = document;

            document_status.title = document.original_file.get_basename ();
        }
    }

    construct {
        ActionEntry[] entries = {
            { "details", details_action },
            { "open-app", open_app_action },
        };

        var action_group = new SimpleActionGroup ();
        action_group.add_action_entries (entries, this);
        insert_action_group ("editor", action_group);
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

    private void details_action () {
        var details_window = new DetailsWindow (document) {
            transient_for = (Gtk.Window) get_root ()
        };
        details_window.show ();
    }

    private void open_app_action () {
        open_on_app.begin ();
    }

    private async void open_on_app () {
        var portal = new Xdp.Portal ();
        var parent = Xdp.parent_new_gtk ((Gtk.Window) get_root ());

        try {
            bool result = yield portal.open_uri (parent, document.original_file.get_uri (),
                                                 ASK, null);
            if (!result) {
                debug ("File was not opened by the user");
            }
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    [GtkCallback]
    private void on_add_button_clicked () {
        document.add_keyword ("");
    }
}
