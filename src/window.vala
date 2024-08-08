/* window.vala
 *
 * Copyright 2023-2024 Diego Iván
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

namespace PaperClip {
    [GtkTemplate (ui = "/io/github/diegoivan/pdf_metadata_editor/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned DocumentView doc_view;
        [GtkChild]
        private unowned Gtk.Stack view_stack;
        [GtkChild]
        private unowned Gtk.MenuButton menu_button;
        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;
        [GtkChild]
        private unowned DropOverlay drop_overlay;

        public WindowState state { get; set; default = NONE; }

        public Services.DocumentManager document_manager {
            get;
            default = new Services.DocumentManager ();
        }

        private File? dropped_file { get; set; default = null; }

        public Window (Gtk.Application app) {
            Object (application: app);

            action_set_enabled ("win.save", false);
            action_set_enabled ("win.save-as", false);
            action_set_enabled ("win.open-with", false);
        }

        static construct {
            typeof (DropOverlay).ensure ();
        }

        construct {
            ActionEntry[] entries = {
                { "open", on_open_action },
                { "open-with", on_open_with_action },
                { "save", save_file_action },
                { "save-as", save_file_as_action },
                { "main-menu", on_main_menu_action }
            };

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (entries, this);
            insert_action_group ("win", action_group);

            // Controller of Drag and Drop
            var drop_target = new Gtk.DropTarget (typeof(File), COPY);

            drop_target.drop.connect (on_file_dropped);
            view_stack.add_controller (drop_target);
            drop_overlay.drop_target = drop_target;
        }

        private bool on_file_dropped (Value value) {
            var file = (File) value;
            try {
                FileInfo info = file.query_info ("standard::*", NOFOLLOW_SYMLINKS);
                string? content_type = info.get_content_type ();

                if (content_type != "application/pdf") {
                    critical ("File is not a PDF");
                    return false;
                }

                dropped_file = file;
                state = OPENING_DROPPED;
                open_dropped_file.begin ();
            }
            catch (Error e) {
                critical (e.message);
                return false;
            }
            return true;
        }

        private async void open_dropped_file () {
            if (document_manager.changed) {
                show_unsaved_warning.begin ();
            }
            else {
                load_dropped_file.begin ();
            }
        }

        private async void load_dropped_file () {
            pulse_progress_bar ();
            yield load_document_to_view (dropped_file);

            hide_progress_bar_animation ();
            dropped_file = null;
            state = NONE;
        }

        public void open_command_line_file (File file)
            requires (file.query_exists ())
        {
            state = OPENING_FILE;
            dropped_file = file;
            open_dropped_file.begin ();
        }

        private void on_open_action () {
            state = OPENING_FILE;
            if (document_manager.changed) {
                show_unsaved_warning.begin ();
            } else {
                open_file.begin ();
            }
        }

        private async void open_file () {
            var file_dialog = new Gtk.FileDialog ();

            var pdf_filter = new Gtk.FileFilter () {
               name = "PDF"
            };
            pdf_filter.add_mime_type ("application/pdf");

            var filters = new ListStore (typeof (Gtk.FileFilter));
            filters.append (pdf_filter);

            file_dialog.filters = filters;

            try {
                File opened_file = yield file_dialog.open (this, null);
                pulse_progress_bar ();
                yield load_document_to_view (opened_file);
            }
            catch (Error e) {
                critical (e.message);
            }
            state = NONE;
        }

        private void on_open_with_action () {
            doc_view.open_on_app.begin ();
        }

        private async void load_document_to_view (File file) {
            try {
                var doc = yield create_document (file);
                document_manager.document = doc_view.document = doc;
                action_set_enabled ("win.save", true);
                action_set_enabled ("win.save-as", true);
                action_set_enabled ("win.open-with", true);

                view_stack.visible_child_name = "editor";
            } catch (Error e) {
                if (e is Poppler.Error.ENCRYPTED) {
                    var toast = new Adw.Toast ( _("Failed to open the document. The provided password is incorrect.") );
                    toast_overlay.add_toast (toast);
                }
                critical (e.message);
            }
            hide_progress_bar_animation ();
        }

        private async Document create_document (File file) throws Error {
            Document? doc = null;
            try {
                doc = yield new Document (file);
            } catch (Error e) {
                if (!(e is Poppler.Error.ENCRYPTED)) {
                    throw e;
                }
            }

            if (doc != null) {
                return doc;
            }

            var dialog = new PasswordDialog ();
            return yield dialog.decrypt (file, this, null);
        }

        private void save_file_action () {
            save_file.begin ();
        }

        private async void save_file () {
            if (document_manager.document == null || !document_manager.changed) {
                return;
            }

            file_save_animation ();
            yield document_manager.save (document_manager.document.original_file.get_uri ());
            proceed_with_state ();
            state = NONE;
        }

        private void save_file_as_action () {
            save_file_as.begin ();
        }

        private async void save_file_as () {
            if (document_manager.document == null) {
                return;
            }

            var file_dialog = new Gtk.FileDialog () {
                initial_name = document_manager.document.original_file.get_basename ()
            };

            var pdf_filter = new Gtk.FileFilter () {
               name = "PDF"
            };
            pdf_filter.add_mime_type ("application/pdf");

            var filters = new ListStore (typeof (Gtk.FileFilter));
            filters.append (pdf_filter);

            file_dialog.filters = filters;

            try {
                File file = yield file_dialog.save (this, null);
                file_save_animation ();
                yield document_manager.save (file.get_uri ());
                proceed_with_state ();
            }
            catch (Error e) {
                critical (e.message);
            }
            state = NONE;
        }

        private void file_save_animation () {
            // var property_target = new Adw.PropertyAnimationTarget (progress_bar, "fraction");

            // var animation = new Adw.TimedAnimation (progress_bar, 0, 1, 200, property_target) {
            //     easing = EASE_IN_OUT_SINE
            // };
            // animation.done.connect (hide_progress_bar_animation);

            // progress_bar.fraction = 0;
            // progress_bar.opacity = 1;
            // animation.play ();
        }

        public void shortcuts () {
            var builder = new Gtk.Builder.from_resource ("/io/github/diegoivan/pdf_metadata_editor/gtk/shortcut-window.ui");
            var shortcuts_window = builder.get_object ("shortcut_window") as Gtk.ShortcutsWindow;
            if (shortcuts_window == null) {
                critical ("Failed to load shortcuts");
                return;
            }

            shortcuts_window.transient_for = this;
            shortcuts_window.show ();
        }

        private void on_main_menu_action () {
            menu_button.popup ();
        }

        private void hide_progress_bar_animation () {
            // var property_target = new Adw.PropertyAnimationTarget (progress_bar, "opacity");
            // var animation = new Adw.TimedAnimation (progress_bar, 1, 0, 200, property_target) {
            //     easing = EASE_IN_OUT_SINE
            // };

            // animation.play ();
        }

        private void pulse_progress_bar () {
            // progress_bar.opacity = 1;
            // progress_bar.pulse ();
        }

        [GtkCallback]
        private bool on_close_request () {
            if (!document_manager.changed || state == CLOSING) {
                state = NONE;
                return false;
            }

            quit_and_save.begin ();
            return true;
        }

        private async void quit_and_save () {
            state = CLOSING;
            yield show_unsaved_warning ();
        }

        private async void show_unsaved_warning () {
            var save_changes_dialog = new SaveChangesDialog () {
                transient_for = this,
                modal = true
            };
            SaveChangesResponse response = yield save_changes_dialog.ask ({document_manager}, null);

            if (response == CANCEL) {
                state = NONE;
                return;
            }

            if (response == SAVE) {
                yield save_file ();
                return;
            }

            proceed_with_state ();
        }

        private void proceed_with_state () {
            switch (state) {
                case NONE:
                    return;
                case OPENING_FILE:
                    open_file.begin ();
                    break;
                case OPENING_DROPPED:
                    load_dropped_file.begin ();
                    break;
                case CLOSING:
                    this.close ();
                    break;
            }
        }
    }
}

public enum PaperClip.WindowState {
    NONE,
    OPENING_FILE,
    CLOSING,
    OPENING_DROPPED
}
