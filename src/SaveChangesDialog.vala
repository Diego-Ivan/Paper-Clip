/* SaveChangesDialog.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/io/github/diegoivan/pdf_metadata_editor/gtk/save-changes-dialog.ui")]
public class PaperClip.SaveChangesDialog : Adw.MessageDialog {
    [GtkChild]
    private unowned Gtk.ListBox documents_listbox;

    public ListModel selected_documents {
        owned get {
            var list_store = new ListStore (typeof (Services.DocumentManager));
            for (unowned Gtk.Widget? row = documents_listbox.get_first_child ();
                 row != null;
                 row = row.get_next_sibling ()) {
                var document_row = (DocumentRow) row;

                if (document_row.selected) {
                    list_store.append (document_row.document_manager);
                }
            }

            return list_store;
        }
    }

    public async SaveChangesResponse ask (
        Services.DocumentManager[] document_managers,
        Cancellable? cancellable = null
    ) {
        foreach (Services.DocumentManager manager in document_managers) {
            if (!manager.changed) {
                continue;
            }

            var document_row = new DocumentRow () {
                document_manager = manager
            };
            documents_listbox.append (document_row);
        }

        unowned string dialog_response = yield choose (cancellable);
        switch (dialog_response) {
            case "save":
                return SAVE;
            case "discard":
                return DISCARD;
            case "cancel":
            default:
                return CANCEL;
        }
    }
}

public class PaperClip.DocumentRow : Adw.ActionRow {
    private Services.DocumentManager _document;
    public Services.DocumentManager document_manager {
        get {
            return _document;
        }
        set {
            _document = value;

            title = document_manager.document.title;
            subtitle = document_manager.document.original_file.get_basename () ?? "";
            check_button.active = true;
        }
    }

    public bool selected { get; set; }

    private Gtk.CheckButton check_button = new Gtk.CheckButton ();

    construct {
        check_button.valign = CENTER;
        check_button.bind_property ("active", this, "selected", SYNC_CREATE | BIDIRECTIONAL);
        add_prefix (check_button);
    }
}

public enum PaperClip.SaveChangesResponse {
    CANCEL,
    DISCARD,
    SAVE;
}
