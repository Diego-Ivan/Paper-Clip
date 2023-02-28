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

[GtkTemplate (ui = "/io/github/diegoivan/pdf_metadata_editor/gtk/document-view.ui")]
public class PaperClip.DocumentView : Adw.Bin {
    [GtkChild]
    private unowned Adw.EntryRow title_row;
    [GtkChild]
    private unowned Adw.EntryRow author_row;
    [GtkChild]
    private unowned Adw.EntryRow creator_row;
    [GtkChild]
    private unowned Adw.EntryRow subject_row;
    [GtkChild]
    private unowned Adw.EntryRow producer_row;
    [GtkChild]
    private unowned DateRow creation_row;
    [GtkChild]
    private unowned DateRow modification_row;
    [GtkChild]
    private unowned Gtk.ListBox keyword_box;
    [GtkChild]
    private unowned Adw.StatusPage document_status;

    private BindingGroup document_bindings = new BindingGroup ();

    private Document _document;
    public Document document {
        get {
            return _document;
        }
        set {
            _document = value;
            document_bindings.source = document;

            unowned var window = (Gtk.Window) get_root ();
            document.bind_property ("title", window, "title", SYNC_CREATE);

            keyword_box.bind_model (document.keywords, create_keyword_row);

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

        setup_bindings ();
    }

    private void setup_bindings () {
        // Bind Rows
        document_bindings.bind ("title", title_row, "text",
                                SYNC_CREATE | BIDIRECTIONAL);
        document_bindings.bind ("author", author_row, "text",
                                SYNC_CREATE | BIDIRECTIONAL);
        document_bindings.bind ("creator", creator_row, "text",
                                SYNC_CREATE | BIDIRECTIONAL);
        document_bindings.bind ("subject", subject_row, "text",
                                SYNC_CREATE | BIDIRECTIONAL);
        document_bindings.bind ("producer", producer_row, "text",
                                SYNC_CREATE | BIDIRECTIONAL);
        document_bindings.bind ("creation-date", creation_row, "date",
                                SYNC_CREATE | BIDIRECTIONAL);
        document_bindings.bind ("modification-date", modification_row, "date",
                                SYNC_CREATE | BIDIRECTIONAL);
    }

    private Gtk.Widget create_keyword_row (Object item) {
        var row = new KeywordRow () {
            title = _("Keyword"),
            document = document,
        };
        item.bind_property ("str", row, "text", SYNC_CREATE | BIDIRECTIONAL);

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
