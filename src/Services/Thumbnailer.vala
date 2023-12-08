/* Thumbnailer.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class PaperClip.Services.Thumbnailer {
    private float area_threshold = 2.5f;

    private int _max_size;
    public int max_size {
        get {
            return _max_size;
        } set {
            _max_size = value;
        }
    }
    private Gdk.MemoryFormat? _default_format = null;
    private Gdk.MemoryFormat default_format {
        get {
            if (_default_format == null) {
                if (BYTE_ORDER == LITTLE_ENDIAN) {
                    _default_format = B8G8R8A8_PREMULTIPLIED;
                } else {
                    _default_format = A8R8G8B8_PREMULTIPLIED;
                }
            }
            return _default_format;
        }
    }

    protected static Thumbnailer? instance = null;
    public static Thumbnailer get_default () {
        if (instance == null) {
            instance = new Thumbnailer ();
        }
        return instance;
    }

    [CCode (has_construct_function = false)]
    protected Thumbnailer () {
    }

    public async Gdk.Texture create_thumbnail (Poppler.Page page, string basename) throws Error {
        float max_area = max_size * max_size * area_threshold;
        double height, width, image_area;
        page.get_size (out width, out height);
        image_area = width * height;

        var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, (int) width, (int) height);
        var context = new Cairo.Context (surface);
        // Lets render in a separate thread, it is expensive.
        yield ThreadManager.run_in_thread<void> (() => page.render (context));

        Gdk.Texture retval;
        if (image_area >= max_area) {
            debug ("Image is too big! Loading it in a reduced size");
            retval = yield ThreadManager.run_in_thread<Gdk.Texture> (
                    () => load_scaled (surface, basename));
        } else {
            debug ("Loading image in its default size");
            retval = yield ThreadManager.run_in_thread<Gdk.Texture> (() => load_memory (surface));
        }

        return retval;
    }

    private Gdk.Texture load_scaled (Cairo.ImageSurface surface, string basename) throws Error {
        float max_area = max_size * max_size * area_threshold;
        int width = surface.get_width (), height = surface.get_height ();
        string save_path = create_cache_file (basename);
        Cairo.Status status = surface.write_to_png (save_path);

        if (status != SUCCESS) {
            throw new ThumbnailError.FAILED_EXPORT (@"Failed to export $save_path: $status");
        }

        float scale_factor = 0.1f;
        for (; scale_factor < 0.8f; scale_factor+=0.1f) {
            float scaled_area = height * width * scale_factor;
            if (scaled_area >= max_area) {
                break;
            }
        }

        debug (@"Loading image at scale $scale_factor");
        float scaled_height = height * scale_factor, scaled_width = width * scale_factor;
        debug (@"Height: $height -> $scaled_height. Width: $width -> $scaled_width");

        var pixbuf = new Gdk.Pixbuf.from_file_at_size (save_path, (int) scaled_width, (int) scaled_height);
        var texture = Gdk.Texture.for_pixbuf (pixbuf);
        return texture;
    }

    private string? create_cache_file (string basename) throws Error {
        string destination_path = Path.build_path (Path.DIR_SEPARATOR_S,
                                                   Environment.get_tmp_dir (),
                                                   "thumbnails");
        int result = DirUtils.create_with_parents (destination_path, 0777);
        if (result < 0) {
            throw new ThumbnailError.FAILED_TO_CACHE (@"Unable to create tmp path $destination_path");
        }

        string destination_file = Path.build_filename (destination_path,
                                                       "%s.png".printf (basename));

        var file = File.new_for_path (destination_file);
        if (!file.query_exists ()) {
            file.create (NONE);
        }
        return destination_file;
    }

    private Gdk.Texture load_memory (Cairo.ImageSurface surface) throws Error {
        int height = surface.get_height (), width = surface.get_width ();
        size_t size = height * width * 4;
        var bytes = new Bytes.take (create_sized_copy (surface.get_data (), size));
        var memory_texture = new Gdk.MemoryTexture (width, height, default_format, bytes,
                                                    surface.get_stride ());
        return memory_texture;
    }

    private uint8[] create_sized_copy ([CCode (array_length = false)]uint8[] data, size_t size) {
        uint8[] copy = new uint8[size];
        for (size_t i = 0; i < size; i++) {
            copy[i] = data[i];
        }
        return copy;
    }
}

public errordomain PaperClip.ThumbnailError {
    FAILED_EXPORT,
    FAILED_TO_CACHE
}
