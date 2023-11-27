/* DateRow.vala
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

[GtkTemplate (ui = "/io/github/diegoivan/pdf_metadata_editor/gtk/date-row.ui")]
public class PaperClip.DateRow : Adw.ActionRow {
    [GtkChild]
    private unowned Gtk.Calendar calendar;

    private DateTime? _date;
    public DateTime? date {
        get {
            return _date;
        }
        set {
            _date = value;
            if (date == null) {
                subtitle = _("No date set");
            } else {
                subtitle = date.format ("%x");
                datetime_to_calendar (date);
            }
        }
    }

    [GtkCallback]
    private void on_clear_button_clicked () {
        date = null;
    }

    [GtkCallback]
    private void on_day_selected () {
        date = calendar.get_date ();
    }

    [GtkCallback]
    private void on_today_button_clicked () {
        var today_time = new DateTime.now_local ();

        datetime_to_calendar (today_time);
        date = today_time;
    }

    [GtkCallback]
    private void on_tomorrow_button_clicked () {
        var tomorrow_time = new DateTime.now_local ();
        tomorrow_time = tomorrow_time.add_days (1);

        datetime_to_calendar (tomorrow_time);
        date = tomorrow_time;
    }

    private void datetime_to_calendar (DateTime date_time) {
        int year, month, day;
        date_time.get_ymd (out year, out month, out day);

        calendar.year = year;
        calendar.month = month - 1;
        calendar.day = day;
    }
}
