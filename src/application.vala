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

namespace HiddenScribe {
    public class Application : Adw.Application {
        public Application () {
            Object (application_id: "io.github.diegoivan.hidden_scribe",
                    flags: ApplicationFlags.FLAGS_NONE);

            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.textdomain (Config.GETTEXT_PACKAGE);
        }

        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
            };
            this.add_action_entries (action_entries, this);
        }

        public override void activate () {
            base.activate ();
            var win = this.active_window;
            if (win == null) {
                win = new HiddenScribe.Window (this);
            }
            win.present ();
        }

        private void on_about_action () {
            string[] developers = { "Diego Iván" };
            var about = new Adw.AboutWindow () {
                application_icon = Config.APP_ID,
                application_name = "Hidden Scribe",
                copyright = "© 2023 Diego Iván",
                developer_name = "Diego Iván",
                developers = developers,
                issue_url = "https://github.com/Diego-Ivan/HiddenScribe/issues",
                license_type = GPL_3_0,
                transient_for = this.active_window,
                translator_credits = _("translator_credits"),
                version = "0.1.0",
                website = "https://github.com/Diego-Ivan/HiddenScribe",
            };

            about.present ();
        }
    }
}
