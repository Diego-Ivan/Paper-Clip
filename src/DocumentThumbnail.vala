/* DocumentThumbnail.vala
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

public class PaperClip.DocumentThumbnail : Adw.Bin {
    private Gtk.Picture thumbnail_image = new Gtk.Picture ();

    private unowned Document _document;
    public unowned Document document {
        get {
            return _document;
        }
        set {
            _document = value;
            generate_png.begin ();
        }
    }

    construct {
        thumbnail_image.width_request = 100;
        thumbnail_image.height_request = 125;

        child = thumbnail_image;
    }

    private async void generate_png () {
        try {
            string image_uri = yield save_thumbnail_to_cache ();
            var texture = Gdk.Texture.from_filename (image_uri);
            thumbnail_image.paintable = texture;
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    private async string? save_thumbnail_to_cache () throws Error {
        Cairo.Status status = NULL_POINTER;
        string? cache_path = "";

        new Thread<void>("image-renderer", () => {
            Poppler.Page first_page = document.get_page_for_index (0);
            double width, height;

            first_page.get_size (out width, out height);

            var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, (int) width, (int) height);
            var context = new Cairo.Context (surface);

            first_page.render (context);

            cache_path = create_cache_file ();

            if (cache_path == null) {
                status = INVALID_PATH_DATA;
                return;
            }

            status = surface.write_to_png (create_cache_file ());

            Idle.add (save_thumbnail_to_cache.callback);
        });

        yield;

        if (status != SUCCESS || cache_path == null || cache_path == "") {
            throw new ThumbnailError.FAILED_EXPORT ("Failed to export PNG file: %s", status.to_string ());
        }

        return cache_path;
    }

    private string? create_cache_file () {
        string destination_path = Path.build_path (Path.DIR_SEPARATOR_S,
                                                   Environment.get_user_cache_dir (),
                                                   "thumbnails");
        int result = DirUtils.create_with_parents (destination_path, 0777);
        return_if_fail (result > -1);

        string destination_file = Path.build_filename (destination_path,
                                                       "%s.png".printf (document.original_file.get_basename ()));

        var file = File.new_for_path (destination_file);

        if (!file.query_exists ()) {
            try {
                file.create (NONE);
            }
            catch (Error e) {
                critical (e.message);
                return null;
            }
        }

        return destination_file;
    }
}

public errordomain PaperClip.ThumbnailError {
    FAILED_EXPORT
}
