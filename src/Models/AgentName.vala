/* AgentName.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AgentName : Object {
    public string organization { get; set; default = ""; }
    public string software_name { get; set; default = ""; }
    public string version { get; set; default = ""; }
    public string tokens { get; set; default = ""; }
    private static Regex? regex = null;

    static construct {
        try {
            regex = new Regex ("""([^\d][^ ][a-zA-Z]+)[ ]([^\d][a-z A-Z])+([\d][.]?)+(.*)?$""");
            debug (@"$(regex.get_pattern ())");
        } catch (Error e) {
            warning ("Failed to create regex pattern: %s", e.message);
        }
    }

    public AgentName (string str) {
        if (regex.match (str)) {
            debug (@"$str matches desired pattern");
            parse (str);
        } else {
            software_name = str;
        }
        debug (@"Organization: $organization");
        debug (@"Software Name: $software_name");
        debug (@"Version: $version");
        debug (@"Tokens: $tokens");
        debug (@"Serialized: $this");
    }

    public string to_string () {
        var builder = new StringBuilder ();
        if (organization[0] != 0) {
            builder.append_printf ("%s ", organization);
        }
        if (software_name[0] != 0) {
            builder.append_printf ("%s ", software_name);
        }
        if (version[0] != 0) {
            builder.append_printf ("%s ", version);
        }
        if (tokens[0] != 0) {
            builder.append_printf ("%s ", tokens);
        }
        return builder.str;
    }

    // This assumes that @str is a valid string
    private void parse (string str) {
        string[] sections = str.split (" ");
        organization = sections[0];
        int i = 1;

        var builder = new StringBuilder ();
        for (i = 1; i < sections.length; i++) {
            if (is_valid_version (sections[i])) {
                version = sections[i];
                i++;
                break;
            } else {
                builder.append_printf ("%s ", sections[i]);
            }
        }
        if (builder.str[builder.len - 1] == ' ') {
            builder.erase (builder.len - 1);
        }
        software_name = builder.str;
        builder.erase ();

        for (; i < sections.length; i++) {
            builder.append_printf ("%s", sections[i]);
            if (i + 1 < sections.length) {
                builder.append_c (' ');
            }
        }
        tokens = builder.str;
    }

    private bool is_valid_version (string section) {
        bool retval = false;
        for (int i = 0; section[i] != 0; i++) {
            char byte = section[i];
            if (byte.isdigit () && i > 0) {
                retval = true;
            }
        }
        return retval;
    }
}
