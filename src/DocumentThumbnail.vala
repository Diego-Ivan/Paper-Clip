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
    private Gtk.Image thumbnail_image = new Gtk.Image ();

    const int MAX_SIZE = 175;

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
        child = thumbnail_image;
        thumbnail_image.add_css_class ("icon-dropshadow");
    }

    private async void generate_png () {
        try {
            Gdk.Texture thumbnail_texture = yield create_thumbnail_in_cache ();
            thumbnail_image.paintable = scale_thumbnail (thumbnail_texture);
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    private Gdk.Paintable scale_thumbnail (Gdk.Texture thumbnail_texture) {
        int image_width = thumbnail_texture.width;
        int image_height = thumbnail_texture.height;

        if (image_width == image_height) {
            return thumbnail_texture;
        }

        float size = MAX_SIZE * scale_factor;
        float scaled_height, scaled_width;

        if (image_width > image_height) {
            scaled_height = size;
            scaled_width = image_width * scaled_height / image_height;
        } else if (image_height > image_width) {
            scaled_width = size;
            scaled_height = image_height * scaled_width / image_width;
        } else {
            scaled_width = scaled_height = size;
        }

        var snapshot = new Gtk.Snapshot ();
        Gsk.ScalingFilter filter = LINEAR;
        if (image_width < scaled_width || image_height < scaled_height) {
            filter = TRILINEAR;
        }

        var thumbnail_rectangle = Graphene.Rect ();

        thumbnail_rectangle = thumbnail_rectangle.init (0, 0, scaled_width, scaled_height);
        snapshot.append_scaled_texture (thumbnail_texture, filter, thumbnail_rectangle);
        thumbnail_image.pixel_size = (int) size;

        return snapshot.to_paintable ({scaled_width, scaled_height});
    }

    private async Gdk.Texture? create_thumbnail_in_cache () throws Error {
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

            Idle.add (create_thumbnail_in_cache.callback);
        });

        yield;

        if (status != SUCCESS || cache_path == null || cache_path == "") {
            throw new ThumbnailError.FAILED_EXPORT ("Failed to export PNG file: %s", status.to_string ());
        }

        return Gdk.Texture.from_filename (cache_path);;
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
