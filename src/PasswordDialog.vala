/* PasswordDialog.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


public errordomain PaperClip.PasswordDialogError {
    CANCELLED
}

[GtkTemplate (ui = "/io/github/diegoivan/pdf_metadata_editor/gtk/password-dialog.ui")]
public class PaperClip.PasswordDialog : Adw.Dialog {
    [GtkChild]
    private unowned Adw.PasswordEntryRow password_entry;
    [GtkChild]
    private unowned Adw.StatusPage status_page;

    private AsyncTask? task = null;

    construct {
        ActionEntry[] action_entries = {
            { "success", success_task },
            { "cancel", cancel_task }
        };
        var action_group = new SimpleActionGroup ();
        action_group.add_action_entries (action_entries, this);
        this.insert_action_group ("dialog", action_group);
    }

    public async Document decrypt (File file, Gtk.Window? parent, Cancellable? cancellable = null) throws Error {
        status_page.description = file.get_basename () ?? "";
        task = new AsyncTask (decrypt.callback);
        if (cancellable != null) {
            cancellable.cancelled.connect (cancel_task);
        }
        present (parent);
        yield;
        close ();

        if (task.status == CANCELLED) {
            throw new PasswordDialogError.CANCELLED ("Use cancelled the operation");
        }

        return yield new Document (file, password_entry.text);
    }

    [GtkCallback]
    private void on_closed () 
    requires (task != null)
    requires (task.status == RUNNING) {
        cancel_task ();
    }

    [GtkCallback]
    private void success_task ()
    requires (task != null)
    requires (task.status == RUNNING) {
        task.status = SUCCEEDED;
        Idle.add ((owned) task.callback);
    }

    private void cancel_task ()
    requires (task != null)
    requires (task.status == RUNNING) {
        task.status = CANCELLED;
        Idle.add ((owned) task.callback);
    }
}
