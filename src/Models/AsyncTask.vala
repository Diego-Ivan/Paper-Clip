/* AsyncTask.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[Compact]
public class PaperClip.AsyncTask {
    public TaskStatus status = RUNNING;
    public SourceFunc callback;

    public AsyncTask (owned SourceFunc callback) {
        this.callback = (owned) callback;
    }
}

public enum PaperClip.TaskStatus {
    CANCELLED,
    SUCCEEDED,
    RUNNING
}
