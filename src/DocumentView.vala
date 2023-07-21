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
    private unowned KeywordList keyword_list;
    [GtkChild]
    private unowned Gtk.Label title_label;
    [GtkChild]
    private unowned DetailsList details_list;
    [GtkChild]
    private unowned DocumentThumbnail document_thumbnail;
    [GtkChild]
    private unowned Gtk.ScrolledWindow scrolled_window;

    private BindingGroup document_bindings = new BindingGroup ();

    private Document _document;
    public Document document {
        get {
            return _document;
        }
        set {
            _document = value;
            document_bindings.source = document;
            details_list.document = document;
            document_thumbnail.document = document;
            keyword_list.document = document;

            document.bind_property ("title", root, "title", SYNC_CREATE);

            var manager = new Services.DocManager ();
            manager.document = document;

            measure_filename ();
            title_label.label = document.original_file.get_basename ();

            title_row.grab_focus_without_selecting ();
            scrolled_window.vadjustment.value = 0;
        }
    }

    construct {
        var action_group = new SimpleActionGroup ();
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

    private void measure_filename () {
        string? basename = document.original_file.get_basename ();
        if (basename == null) {
            return;
        }

        title_label.remove_css_class ("long-filename");
        title_label.ellipsize = NONE;

        // A long file name that does contain spaces in the name, we will assign an special
        // class that will reduce the size of the label
        if (basename.length > 45 && " " in basename) {
            title_label.add_css_class ("long-filename");
            return;
        }

        // Now, we have to check for files with long filenames but that do not have any spaces
        if (basename.length > 21 && !(" " in basename)) {
            title_label.ellipsize = END;
        }
    }

    public async void open_on_app () {
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
}
