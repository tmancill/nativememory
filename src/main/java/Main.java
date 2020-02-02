import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Pointer;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicLong;

public class Main {

    final private static AtomicLong allocated = new AtomicLong(0L);

    public static void main(String[] args) {
        final int threads = Integer.parseInt(args[0]);
        final int chunkSize = Integer.parseInt(args[1]) * 1024 * 1024;
        final int chunkCount = Integer.parseInt(args[2]);

        final ExecutorService pool = Executors.newFixedThreadPool(threads);
        for (int i = 0; i < threads; i++) {
            pool.execute(new MyThread(chunkSize, chunkCount,((i % 2) == 0 ? 30000L : 3600000L) ));
        }

        // give the threads a chance to startup
        try {
            Thread.sleep(2000L);
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("pid " + CLibrary.INSTANCE.getpid()
                + " allocated " + threads + " threads"
                + " x chunkSize " + chunkSize / (1024 * 1024) + "MB"
                + " x chunkCount " + chunkCount + " = "
                + (allocated.get() / (1024 * 1024)) + "MB total");
        System.out.flush();
    }

    private static long allocate(long size) {
        return Native.malloc(size);
    }

    static class MyThread implements Runnable {
        final int chunkSize;
        final int chunkCount;
        final long sleepMs;

        public MyThread(final int chunkSize, final int chunkCount, final long sleepMs) {
            this.chunkSize = chunkSize;
            this.chunkCount = chunkCount;
            this.sleepMs = sleepMs;
        }

        @Override
        public void run() {
            final long[] pointers = new long[chunkCount];
            for (int i = 0; i < chunkCount; i++) {
                pointers[i] = allocate(chunkSize);
                allocated.getAndAdd(chunkSize);
                new Pointer(pointers[i]).setMemory(0, chunkSize / 2, (byte) 0xfe);
            }
            try {
                Thread.sleep(sleepMs);
            } catch (Exception e) {
                e.printStackTrace();
            }
            for (int i = 0; i < chunkCount; i++) {
                Native.free(pointers[i]);
            }
        }
    }

    private interface CLibrary extends Library {
        CLibrary INSTANCE = Native.load("c", CLibrary.class);
        int getpid ();
    }
}
