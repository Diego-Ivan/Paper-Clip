/* ThreadManager.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace ThreadManager {
    private static ThreadPool<Task> thread_pool;
    private static bool initiated = false;
    private static bool supported = true;

    public delegate G ThreadFunc<G> () throws Error;
    public delegate void TaskFunc ();

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
            critical ("Thread Creation not supported in this context. Running synchronously...");
            return thread_func ();
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
