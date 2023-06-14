/* window.vala
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

namespace PaperClip {
    [GtkTemplate (ui = "/io/github/diegoivan/pdf_metadata_editor/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned DocumentView doc_view;
        [GtkChild]
        private unowned Gtk.Stack view_stack;
        [GtkChild]
        private unowned Gtk.ProgressBar progress_bar;
        [GtkChild]
        private unowned Gtk.MenuButton menu_button;
        [GtkChild]
        private unowned Adw.Clamp welcome_clamp;

        public State state { get; set; default = NONE; }
        private File? dropped_file { get; set; default = null; }

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            ActionEntry[] entries = {
                { "open", on_open_action },
                { "open-with", on_open_with_action },
                { "save", save_file },
                { "quit", quit_save_action  },
                { "save-as", save_file_as_action },
                { "main-menu", on_main_menu_action }
            };

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (entries, this);
            insert_action_group ("win", action_group);

            action_set_enabled ("win.save", false);
            action_set_enabled ("win.save-as", false);
            action_set_enabled ("win.open-with", false);

            // Controller of Drag and Drop
            var drop_target = new Gtk.DropTarget (typeof(File), COPY);

            drop_target.drop.connect (on_file_dropped);
            drop_target.enter.connect (on_enter);
            welcome_clamp.add_controller (drop_target);
        }

        private Gdk.DragAction on_enter () {
            return COPY;
        }

        [GtkCallback]
        private bool on_file_dropped (Value value) {
            var file = (File) value;
            try {
                FileInfo info = file.query_info ("standard;:*", NOFOLLOW_SYMLINKS);
                string? content_type = info.get_content_type ();
                string name = file.get_basename () ?? "";

                if (content_type != "application/pdf" && !name.contains (".pdf")) {
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
            var manager = new Services.DocManager ();
            if (manager.changed) {
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

        private void on_open_action () {
            state = OPENING_FILE;
            var doc_manager = new Services.DocManager ();
            if (doc_manager.changed) {
                show_unsaved_warning.begin ();
            } else {
                open_file.begin ();
            }
        }

        private async void open_file () {
            var file_dialog = new Gtk.FileDialog ();
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
            doc_view.document = yield new Document (file.get_uri ());

            action_set_enabled ("win.save", true);
            action_set_enabled ("win.save-as", true);
            action_set_enabled ("win.open-with", true);

            hide_progress_bar_animation ();
            view_stack.visible_child_name = "editor";
        }

        private void save_file () {
            var manager = new Services.DocManager ();
            if (manager.document == null || !manager.changed) {
                return;
            }

            manager.save (manager.document.original_file.get_uri ());
            file_save_animation ();
            proceed_with_state ();
            state = NONE;
        }

        private void save_file_as_action () {
            save_file_as.begin ();
        }

        private async void save_file_as () {
            var manager = new Services.DocManager ();
            if (manager.document == null) {
                return;
            }

            var file_dialog = new Gtk.FileDialog () {
                initial_name = manager.document.original_file.get_basename ()
            };
            try {
                File file = yield file_dialog.save (this, null);
                manager.save (file.get_uri ());
                file_save_animation ();
                proceed_with_state ();
            }
            catch (Error e) {
                critical (e.message);
            }
            state = NONE;
        }

        private void file_save_animation () {
            var property_target = new Adw.PropertyAnimationTarget (progress_bar, "fraction");

            var animation = new Adw.TimedAnimation (progress_bar, 0, 1, 200, property_target) {
                easing = EASE_IN_OUT_SINE
            };
            animation.done.connect (hide_progress_bar_animation);

            progress_bar.fraction = 0;
            progress_bar.opacity = 1;
            animation.play ();
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
            var property_target = new Adw.PropertyAnimationTarget (progress_bar, "opacity");
            var animation = new Adw.TimedAnimation (progress_bar, 1, 0, 200, property_target) {
                easing = EASE_IN_OUT_SINE
            };

            animation.play ();
        }

        private void pulse_progress_bar () {
            progress_bar.opacity = 1;
            progress_bar.pulse ();
        }

        [GtkCallback]
        private bool on_close_request () {
            quit_and_save.begin ();
            return true;
        }

        private void quit_save_action () {
            quit_and_save.begin ();
        }

        private async void quit_and_save () {
            state = CLOSING;
            var manager = new Services.DocManager ();
            if (manager.changed) {
                yield show_unsaved_warning ();
            }
            else {
                GLib.Application.get_default ().quit ();
            }
        }

        private async void show_unsaved_warning () {
            var message_dialog = new Adw.MessageDialog (this,
                                                        _("Save Changes?"),
                                                        _("Changes that are not saved will be lost permanently"));
            message_dialog.close_response = "cancel";
            message_dialog.default_response = "cancel";

            message_dialog.add_response ("cancel", _("Cancel"));
            message_dialog.add_response ("discard", _("Discard"));
            message_dialog.add_response ("save", _("Save"));

            message_dialog.set_response_appearance ("discard", DESTRUCTIVE);
            message_dialog.set_response_appearance ("save", SUGGESTED);

            string response = yield message_dialog.choose (null);
            if (response == "cancel") {
                state = NONE;
                return;
            }

            if (response == "save") {
                save_file ();
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
                    GLib.Application.get_default ().quit ();
                    break;
            }
        }
    }
}
