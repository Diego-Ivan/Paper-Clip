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

namespace HiddenScribe {
    [GtkTemplate (ui = "/io/github/diegoivan/hidden_scribe/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned DocumentView doc_view;
        [GtkChild]
        private unowned Gtk.Stack view_stack;
        [GtkChild]
        private unowned Adw.WindowTitle window_title;

        public State state { get; set; default = NONE; }
        private File? dropped_file { get; set; default = null; }

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        public new string title {
            get {
                return window_title.title;
            }
            set {
                window_title.title = value;
            }
        }

        public string subtitle {
            get {
                return window_title.subtitle;
            }
            set {
                window_title.subtitle = value;
            }
        }

        construct {
            ActionEntry[] entries = {
                { "open", on_open_action },
                { "save", save_file },
                { "quit", quit_and_save  },
                { "save-as", save_file_as }
            };

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (entries, this);
            insert_action_group ("win", action_group);

            // Controller of Drag and Drop
            var drop_target = new Gtk.DropTarget (typeof(File), COPY);

            drop_target.on_drop.connect (on_file_dropped);
            drop_target.enter.connect (on_enter);
            view_stack.add_controller (drop_target);
        }

        private Gdk.DragAction on_enter () {
            return COPY;
        }

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
                show_unsaved_warning ();
            }
            else {
                message ("Loading dropped file to view");
                yield load_document_to_view (dropped_file);
                dropped_file = null;
                state = NONE;
            }
        }

        private void on_open_action () {
            state = OPENING_FILE;
            var doc_manager = new Services.DocManager ();
            if (doc_manager.changed) {
                show_unsaved_warning ();
            } else {
                open_file ();
            }
        }

        private void open_file () {
            view_stack.visible_child_name = "empty";
            var filter = new Gtk.FileFilter ();
            filter.add_mime_type ("application/pdf");

            var filechooser = new Gtk.FileChooserNative ("Select a PDF file", this,
                                                         OPEN, null, null);
            filechooser.add_filter (filter);

            filechooser.response.connect (on_file_opened);
            filechooser.show ();
        }

        private void on_file_opened (Gtk.NativeDialog source, int response) {
            var file_dialog = (Gtk.FileChooser) source;

            if (response == Gtk.ResponseType.ACCEPT) {
                load_document_to_view.begin (file_dialog.get_file ());
            }
            state = NONE;
        }

        private async void load_document_to_view (File file) {
            doc_view.document = yield new Document (file.get_uri ());
            view_stack.visible_child_name = "editor";
        }

        private void save_file () {
            var manager = new Services.DocManager ();
            if (manager.document == null) {
                return;
            }

            manager.save (manager.document.original_file.get_uri ());
            proceed_with_state ();
            state = NONE;
        }

        private void save_file_as () {
            var filter = new Gtk.FileFilter ();
            filter.add_mime_type ("application/pdf");

            var filechooser = new Gtk.FileChooserNative (null, this,
                                                         SAVE, null, null);
            filechooser.add_filter (filter);

            filechooser.response.connect (on_file_saved);
            filechooser.show ();
        }

        private void on_file_saved (Gtk.NativeDialog source, int response) {
            var file_dialog = (Gtk.FileChooser) source;
            if (response == Gtk.ResponseType.ACCEPT) {
                var file = file_dialog.get_file ();

                var manager = new Services.DocManager ();
                manager.save (file.get_uri ());

                proceed_with_state ();
            }
            state = NONE;
        }

        [GtkCallback]
        private bool on_close_request () {
            quit_and_save ();
            return true;
        }

        private void quit_and_save () {
            state = CLOSING;
            var manager = new Services.DocManager ();
            if (manager.changed) {
                show_unsaved_warning ();
            }
            else {
                GLib.Application.get_default ().quit ();
            }
        }

        private void show_unsaved_warning () {
            var message_dialog = new Adw.MessageDialog (this,
                                                        _("Do you want to save the changes?"),
                                                        _("Changes that are not saved will be lost permanently"));
            message_dialog.close_response = "cancel";
            message_dialog.default_response = "cancel";

            message_dialog.add_response ("cancel", _("Cancel"));
            message_dialog.add_response ("discard", _("Discard"));
            message_dialog.add_response ("save", _("Save"));

            message_dialog.set_response_appearance ("discard", DESTRUCTIVE);
            message_dialog.set_response_appearance ("save", SUGGESTED);

            message_dialog.response.connect (on_warning_response);
            message_dialog.show ();
        }

        private void on_warning_response (Adw.MessageDialog sender, string response) {
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
                    open_file ();
                    break;
                case OPENING_DROPPED:
                    open_dropped_file.begin ();
                    break;
                case CLOSING:
                    GLib.Application.get_default ().quit ();
                    break;
            }
        }
    }
}
