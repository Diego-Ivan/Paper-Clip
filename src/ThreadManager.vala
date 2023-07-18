/* ThreadManager.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace ThreadManager {
    private static ThreadPool<Task> thread_pool;
    private static bool initiated;
    private static bool supported;

    public delegate G ThreadFunc<G> () throws Error;
    public delegate void TaskFunc ();

    public errordomain ThreadManagerError {
        NOT_SUPPORTED;
    }

    [Compact]
    private class Task {
        public TaskFunc task_func;

        public Task (owned TaskFunc task_func_) {
            task_func = (owned) task_func_;
        }

        public void run () {
            task_func ();
        }
    }

    private void init () {
        if (initiated) {
            return;
        }

        try {
            thread_pool = new ThreadPool<Task>.with_owned_data (run_task, 1, false);
        }
        catch (Error e) {
            supported = false;
            critical (e.message);
        }

        initiated = true;
    }

    private void run_task (owned Task task) {
        task.run ();
    }

    public async G run_in_thread<G> (owned ThreadFunc<G> thread_func) throws Error {
        if (!initiated) {
            init ();
        }

        if (!supported) {
            throw new ThreadManagerError.NOT_SUPPORTED ("Thread creation is not supported");
        }

        Error? error = null;
        G retval = null;

        thread_pool.add (new Task (() => {
            try {
                retval = thread_func ();
            }
            catch (Error e) {
                error = e;
            }
            Idle.add (run_in_thread.callback);
        }));

        yield;

        if (error != null) {
            throw error;
        }

        return retval;
    }
}
