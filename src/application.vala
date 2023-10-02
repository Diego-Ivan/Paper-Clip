/* application.vala
 *
 * Copyright 2023 Diego Iván
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

public class PaperClip.Application : Adw.Application {
    private Window main_window;

    public Application () {
        Object (application_id: "io.github.diegoivan.pdf_metadata_editor",
                flags: ApplicationFlags.HANDLES_OPEN);

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
        Intl.textdomain (Config.GETTEXT_PACKAGE);
    }

    construct {
        ActionEntry[] action_entries = {
            { "about", this.on_about_action },
            { "shortcuts", shortcuts_action },
            { "query-quit", on_query_quit_action },
            { "new-window", on_new_window_action }
        };
        this.add_action_entries (action_entries, this);
        set_accels_for_action ("app.shortcuts", { "<Ctrl>question" });
        set_accels_for_action ("app.query-quit", { "<Ctrl>q" });
        set_accels_for_action ("app.new-window", { "<Ctrl>n" });
    }

    public override void activate () {
        base.activate ();
        if (main_window == null) {
            main_window = new PaperClip.Window (this);
        }
        main_window.present ();
    }

    public override void open (File[] files, string hint) {
        activate ();
        if (files.length < 1) {
            return;
        }

        foreach (File file in files) {
            try {
                FileInfo info = file.query_info ("standard::*",
                                                 NOFOLLOW_SYMLINKS);
                string? content_type = info.get_content_type ();

                if (content_type != "application/pdf") {
                    critical (@"File $(file.get_path ()) is not a PDF");
                    continue;
                }

                var window = new Window (this);
                window.open_command_line_file (file);
                window.present ();
            } catch (Error e) {
                critical (e.message);
            }
        }
    }

    private void shortcuts_action () {
        var window = (Window) active_window;
        window.shortcuts ();
    }

    private void on_new_window_action () {
        var window = new PaperClip.Window (this);
        window.present ();
    }

    private void on_query_quit_action () {
        on_query_quit_action_async.begin ();
    }

    private async void on_query_quit_action_async () {
        Services.DocumentManager[] managers = {};

        foreach (unowned Gtk.Window toplevel in Gtk.Window.list_toplevels ()) {
            var window = toplevel as Window;
            if (window == null || !window.document_manager.changed) {
                continue;
            }
            managers += window.document_manager;
        }

        if (managers.length < 1) {
            quit ();
            return;
        }

        var changes_dialog = new SaveChangesDialog () {
            transient_for = active_window,
            modal = true
        };

        SaveChangesResponse response = yield changes_dialog.ask (managers, null);
        switch (response) {
            case SAVE:
                save_unsaved_managers (changes_dialog);
                break;
            case DISCARD:
                quit ();
                break;
            case CANCEL:
            default:
                return;
        }
    }

    private void save_unsaved_managers (SaveChangesDialog changes_dialog) {
        ListModel unsaved_documents = changes_dialog.selected_documents;
        for (int i = 0; i < unsaved_documents.get_n_items (); i++) {
            var unsaved_manager = (Services.DocumentManager) unsaved_documents.get_item (i);
            unsaved_manager.save ();
        }
        quit ();
    }

    private void on_about_action () {
        string[] developers = { "Diego Iván M.E" };
        string[] artists = { "Brage Fuglseth" };
        var about = new Adw.AboutWindow () {
            application_icon = Config.APP_ID,
            application_name = "Paper Clip",
            copyright = "© 2023 Diego Iván M.E",
            developer_name = "Diego Iván M.E",
            developers = developers,
            artists = artists,
            issue_url = "https://github.com/Diego-Ivan/Paper-Clip/issues",
            license_type = GPL_3_0,
            transient_for = this.active_window,
            // translators: Write your name<email> here :D
            translator_credits = _("translator_credits"),
            version = Config.VERSION,
            website = "https://github.com/Diego-Ivan/Paper-Clip",
        };

        about.present ();
    }
}
