# JUC锁

### ReetrantLock详解
- 什么是可重入，什么是可重入锁？它用来解决什么问题
- ReetrantLock的核心是AQS，那么它怎么来实现的，继承吗，说说类内部结构关系。
- ReentrantLock是如何实现公平锁的
- ReentrantLock是如何实现非公平锁的
- ReentrantLock默认实现的是公平锁还是非公平锁？
- 使用ReentrantLock实现公共锁和非公平锁的实例？
- ReentrantLock和Synchronized的比较？

#### 什么是可重入，什么是可重入锁？它用来解决什么问题
- 当线程A已经获得某个锁，可以多次重复获取该锁而不会出现死锁。
#### ReetrantLock继承关系
- 实现了Lock接口

#### ReentrantLock内部类
内部类：Sync / NonfairSync / FairSync

#### ReentrantLock是如何实现非公平锁的
- ReentrantLock默认是非公平锁
- 首先尝试获取锁，在没有获取到锁后加入同步队列，以独占模式尝试获取对象，忽略中断
- 非公平方式获取锁：当该锁没有被竞争时，设置state，设置当前线程独占。如果已经拥有该锁，重入。

#### ReentrantLock是如何实现公平锁的
- 以独占方式获取对象，忽略中断
- 如果没有获取到锁，加入同步队列中。
- 公平方式获取锁：如果当前锁没有被竞争，同步队列中如果有等待更久的线程，尝试设置状态。如果没有等待更久的线程或者设置状态失败，当前线程独占该锁。如果该锁已经被当前线程独占，重入。

#### ReentrantLock是如何实现加锁的，把AQS里的方法也说一遍

#### ReentrantLock默认实现的是公平锁还是非公平锁
默认是非公平锁

#### ReentrantLock和Synchronized的比较？
- ReentrantLock可实现公平锁和非公平锁，Synchronized只能实现非公平锁。
- ReentrantLock基于api，Synchronized基于JVM
- ReentrantLock在出现异常时可能不会释放锁，但是Synchronized在出现异常时一定会释放锁
- ReentrantLock在等待时可被中断，Synchronized不能被中断
- ReentrantLock可以同时绑定多个Condition对象

### ReetrantReadWriteLock详解
- 为什么有了ReentrantLock还需要ReentrantReadWriteLock？
- ReentrantReadWriteLock底层实现原理？
- ReentrantReadWriteLock底层读写状态如何设计的？高16位读锁，低16位写锁
- 读锁和写锁的最大数量是多少？
- 本地线程计数器ThreadLocalHoldCounter是用来做什么的？
- 缓存计数器HoldCounter是用来做什么的？
- 写锁的获取与释放是怎么实现的？
- 读锁的获取与释放是怎么实现的？
- ReentrantReadWriteLock为什么不支持锁升级？
- 什么是锁的升降级

#### ReentrantReadWriteLock Sync源代码
<details>
  <summary>Sync源代码</summary>

```java
abstract static class Sync extends AbstractQueuedSynchronizer {
	private static final long serialVersionUID = 6317671515068378041L;

	/*
	 * Read vs write count extraction constants and functions.
	 * Lock state is logically divided into two unsigned shorts:
	 * The lower one representing the exclusive (writer) lock hold count,
	 * and the upper the shared (reader) hold count.
	 */
	// 高16位读锁，低16位写锁
	static final int SHARED_SHIFT   = 16;
	static final int SHARED_UNIT    = (1 << SHARED_SHIFT);
	static final int MAX_COUNT      = (1 << SHARED_SHIFT) - 1;
	static final int EXCLUSIVE_MASK = (1 << SHARED_SHIFT) - 1;

	/** Returns the number of shared holds represented in count  */
	static int sharedCount(int c)    { return c >>> SHARED_SHIFT; }
	/** Returns the number of exclusive holds represented in count  */
	static int exclusiveCount(int c) { return c & EXCLUSIVE_MASK; }

	/**
	 * A counter for per-thread read hold counts.
	 * Maintained as a ThreadLocal; cached in cachedHoldCounter
	 * 和读锁配套使用，计数器
	 * 两个属性，count，tid。
	 * count表示某个读线程可重入次数。
	 * tid表示该线程的字段的值，可以用来唯一表示一个线程
	 */
	static final class HoldCounter {
		int count = 0;
		// Use id, not reference, to avoid garbage retention
		final long tid = getThreadId(Thread.currentThread());
	}

	/**
	 * ThreadLocal subclass. Easiest to explicitly define for sake
	 * of deserialization mechanics.
	 */
	static final class ThreadLocalHoldCounter
		extends ThreadLocal<HoldCounter> {
		public HoldCounter initialValue() {
			return new HoldCounter();
		}
	}

	/**
	 * The number of reentrant read locks held by current thread.
	 * Initialized only in constructor and readObject.
	 * Removed whenever a thread's read hold count drops to 0.
	 */
	private transient ThreadLocalHoldCounter readHolds;

	/**
	 * The hold count of the last thread to successfully acquire
	 * readLock. This saves ThreadLocal lookup in the common case
	 * where the next thread to release is the last one to
	 * acquire. This is non-volatile since it is just used
	 * as a heuristic, and would be great for threads to cache.
	 *
	 * <p>Can outlive the Thread for which it is caching the read
	 * hold count, but avoids garbage retention by not retaining a
	 * reference to the Thread.
	 *
	 * <p>Accessed via a benign data race; relies on the memory
	 * model's final field and out-of-thin-air guarantees.
	 */
	private transient HoldCounter cachedHoldCounter;

	/**
	 * firstReader is the first thread to have acquired the read lock.
	 * firstReaderHoldCount is firstReader's hold count.
	 *
	 * <p>More precisely, firstReader is the unique thread that last
	 * changed the shared count from 0 to 1, and has not released the
	 * read lock since then; null if there is no such thread.
	 *
	 * <p>Cannot cause garbage retention unless the thread terminated
	 * without relinquishing its read locks, since tryReleaseShared
	 * sets it to null.
	 *
	 * <p>Accessed via a benign data race; relies on the memory
	 * model's out-of-thin-air guarantees for references.
	 *
	 * <p>This allows tracking of read holds for uncontended read
	 * locks to be very cheap.
	 */
	private transient Thread firstReader = null;
	private transient int firstReaderHoldCount;

	Sync() {
		readHolds = new ThreadLocalHoldCounter();
		setState(getState()); // ensures visibility of readHolds
	}

	/*
	 * Acquires and releases use the same code for fair and
	 * nonfair locks, but differ in whether/how they allow barging
	 * when queues are non-empty.
	 */

	/**
	 * Returns true if the current thread, when trying to acquire
	 * the read lock, and otherwise eligible to do so, should block
	 * because of policy for overtaking other waiting threads.
	 */
	abstract boolean readerShouldBlock();

	/**
	 * Returns true if the current thread, when trying to acquire
	 * the write lock, and otherwise eligible to do so, should block
	 * because of policy for overtaking other waiting threads.
	 */
	abstract boolean writerShouldBlock();

	/*
	 * Note that tryRelease and tryAcquire can be called by
	 * Conditions. So it is possible that their arguments contain
	 * both read and write holds that are all released during a
	 * condition wait and re-established in tryAcquire.
	 */

	protected final boolean tryRelease(int releases) {
		if (!isHeldExclusively())
			throw new IllegalMonitorStateException();
		int nextc = getState() - releases;
		boolean free = exclusiveCount(nextc) == 0;
		if (free)
			setExclusiveOwnerThread(null);
		setState(nextc);
		return free;
	}

	/**
	 * 获取写锁
	 *  
	 **/
	protected final boolean tryAcquire(int acquires) {
		/*
		 * Walkthrough:
		 * 1. If read count nonzero or write count nonzero
		 *    and owner is a different thread, fail.
		 * 2. If count would saturate, fail. (This can only
		 *    happen if count is already nonzero.)
		 * 3. Otherwise, this thread is eligible for lock if
		 *    it is either a reentrant acquire or
		 *    queue policy allows it. If so, update state
		 *    and set owner.
		 */
		Thread current = Thread.currentThread();
		int c = getState();
		int w = exclusiveCount(c);
		if (c != 0) {
			// (Note: if c != 0 and w == 0 then shared count != 0)
			if (w == 0 || current != getExclusiveOwnerThread())
				return false;
			if (w + exclusiveCount(acquires) > MAX_COUNT)
				throw new Error("Maximum lock count exceeded");
			// Reentrant acquire
			setState(c + acquires);
			return true;
		}
		if (writerShouldBlock() ||
		        !compareAndSetState(c, c + acquires))
			return false;
		setExclusiveOwnerThread(current);
		return true;
	}

	/**
	 * 读线程释放锁
	 *  
	 **/
	protected final boolean tryReleaseShared(int unused) {
		Thread current = Thread.currentThread();
		if (firstReader == current) {
			// assert firstReaderHoldCount > 0;
			if (firstReaderHoldCount == 1)
				firstReader = null;
			else
				firstReaderHoldCount--;
		} else {
			HoldCounter rh = cachedHoldCounter;
			if (rh == null || rh.tid != getThreadId(current))
				rh = readHolds.get();
			int count = rh.count;
			if (count <= 1) {
				readHolds.remove();
				if (count <= 0)
					throw unmatchedUnlockException();
			}
			--rh.count;
		}
		for (;;) {
			int c = getState();
			int nextc = c - SHARED_UNIT;
			if (compareAndSetState(c, nextc))
				// Releasing the read lock has no effect on readers,
				// but it may allow waiting writers to proceed if
				// both read and write locks are now free.
				return nextc == 0;
		}
	}

	private IllegalMonitorStateException unmatchedUnlockException() {
		return new IllegalMonitorStateException(
		           "attempt to unlock read lock, not locked by current thread");
	}

	/**
	 * 获取读锁 
	 **/
	protected final int tryAcquireShared(int unused) {
		/*
		 * Walkthrough:
		 * 1. If write lock held by another thread, fail.
		 * 2. Otherwise, this thread is eligible for
		 *    lock wrt state, so ask if it should block
		 *    because of queue policy. If not, try
		 *    to grant by CASing state and updating count.
		 *    Note that step does not check for reentrant
		 *    acquires, which is postponed to full version
		 *    to avoid having to check hold count in
		 *    the more typical non-reentrant case.
		 * 3. If step 2 fails either because thread
		 *    apparently not eligible or CAS fails or count
		 *    saturated, chain to version with full retry loop.
		 */
		Thread current = Thread.currentThread();
		int c = getState();
		if (exclusiveCount(c) != 0 &&
		        getExclusiveOwnerThread() != current)
			return -1;
		int r = sharedCount(c);
		// 读线程是否应该阻塞，并且小于最大值，并且比较设置成功
		if (!readerShouldBlock() &&
		        r < MAX_COUNT &&
		        compareAndSetState(c, c + SHARED_UNIT)) {
			if (r == 0) {
				firstReader = current;
				firstReaderHoldCount = 1;
			} else if (firstReader == current) {
				firstReaderHoldCount++;
			} else {
				HoldCounter rh = cachedHoldCounter;
				if (rh == null || rh.tid != getThreadId(current))
					cachedHoldCounter = rh = readHolds.get();
				else if (rh.count == 0)
					readHolds.set(rh);
				rh.count++;
			}
			return 1;
		}
		return fullTryAcquireShared(current);
	}

	/**
	 * Full version of acquire for reads, that handles CAS misses
	 * and reentrant reads not dealt with in tryAcquireShared.
	 * 用来保证上面函数操作可以成功
	 */
	final int fullTryAcquireShared(Thread current) {
		/*
		 * This code is in part redundant with that in
		 * tryAcquireShared but is simpler overall by not
		 * complicating tryAcquireShared with interactions between
		 * retries and lazily reading hold counts.
		 */
		HoldCounter rh = null;
		for (;;) {
			int c = getState();
			if (exclusiveCount(c) != 0) {
				if (getExclusiveOwnerThread() != current)
					return -1;
				// else we hold the exclusive lock; blocking here
				// would cause deadlock.
			} else if (readerShouldBlock()) {
				// Make sure we're not acquiring read lock reentrantly
				if (firstReader == current) {
					// assert firstReaderHoldCount > 0;
				} else {
					if (rh == null) {
						rh = cachedHoldCounter;
						if (rh == null || rh.tid != getThreadId(current)) {
							rh = readHolds.get();
							if (rh.count == 0)
								readHolds.remove();
						}
					}
					if (rh.count == 0)
						return -1;
				}
			}
			if (sharedCount(c) == MAX_COUNT)
				throw new Error("Maximum lock count exceeded");
			if (compareAndSetState(c, c + SHARED_UNIT)) {
				if (sharedCount(c) == 0) {
					firstReader = current;
					firstReaderHoldCount = 1;
				} else if (firstReader == current) {
					firstReaderHoldCount++;
				} else {
					if (rh == null)
						rh = cachedHoldCounter;
					if (rh == null || rh.tid != getThreadId(current))
						rh = readHolds.get();
					else if (rh.count == 0)
						readHolds.set(rh);
					rh.count++;
					cachedHoldCounter = rh; // cache for release
				}
				return 1;
			}
		}
	}

	/**
	 * Performs tryLock for write, enabling barging in both modes.
	 * This is identical in effect to tryAcquire except for lack
	 * of calls to writerShouldBlock.
	 */
	final boolean tryWriteLock() {
		Thread current = Thread.currentThread();
		int c = getState();
		if (c != 0) {
			int w = exclusiveCount(c);
			if (w == 0 || current != getExclusiveOwnerThread())
				return false;
			if (w == MAX_COUNT)
				throw new Error("Maximum lock count exceeded");
		}
		if (!compareAndSetState(c, c + 1))
			return false;
		setExclusiveOwnerThread(current);
		return true;
	}

	/**
	 * Performs tryLock for read, enabling barging in both modes.
	 * This is identical in effect to tryAcquireShared except for
	 * lack of calls to readerShouldBlock.
	 */
	final boolean tryReadLock() {
		Thread current = Thread.currentThread();
		for (;;) {
			int c = getState();
			if (exclusiveCount(c) != 0 &&
			        getExclusiveOwnerThread() != current)
				return false;
			int r = sharedCount(c);
			if (r == MAX_COUNT)
				throw new Error("Maximum lock count exceeded");
			if (compareAndSetState(c, c + SHARED_UNIT)) {
				if (r == 0) {
					firstReader = current;
					firstReaderHoldCount = 1;
				} else if (firstReader == current) {
					firstReaderHoldCount++;
				} else {
					HoldCounter rh = cachedHoldCounter;
					if (rh == null || rh.tid != getThreadId(current))
						cachedHoldCounter = rh = readHolds.get();
					else if (rh.count == 0)
						readHolds.set(rh);
					rh.count++;
				}
				return true;
			}
		}
	}

	protected final boolean isHeldExclusively() {
		// While we must in general read state before owner,
		// we don't need to do so to check if current thread is owner
		return getExclusiveOwnerThread() == Thread.currentThread();
	}

	// Methods relayed to outer class

	final ConditionObject newCondition() {
		return new ConditionObject();
	}

	final Thread getOwner() {
		// Must read state before owner to ensure memory consistency
		return ((exclusiveCount(getState()) == 0) ?
		        null :
		        getExclusiveOwnerThread());
	}

	final int getReadLockCount() {
		return sharedCount(getState());
	}

	final boolean isWriteLocked() {
		return exclusiveCount(getState()) != 0;
	}

	final int getWriteHoldCount() {
		return isHeldExclusively() ? exclusiveCount(getState()) : 0;
	}

	final int getReadHoldCount() {
		if (getReadLockCount() == 0)
			return 0;

		Thread current = Thread.currentThread();
		if (firstReader == current)
			return firstReaderHoldCount;

		HoldCounter rh = cachedHoldCounter;
		if (rh != null && rh.tid == getThreadId(current))
			return rh.count;

		int count = readHolds.get().count;
		if (count == 0) readHolds.remove();
		return count;
	}

	/**
	 * Reconstitutes the instance from a stream (that is, deserializes it).
	 */
	private void readObject(java.io.ObjectInputStream s)
	throws java.io.IOException, ClassNotFoundException {
		s.defaultReadObject();
		readHolds = new ThreadLocalHoldCounter();
		setState(0); // reset to unlocked state
	}

	final int getCount() { return getState(); }
}
```
</details>

#### ReentrantReadWriteLock底层实现原理？
- 实现了ReadWriteLock接口。
- 五个内部类：Sync/NonfairSync/FairSync/ReadLock/WriteLock

#### 读锁和写锁的最大数量是多少？
- 2 ^ 16

#### 本地线程计数器ThreadLocalHoldCounter是用来做什么的？
- 将线程与对象相关联，对象为HoldCounter对象

#### 缓存计数器HoldCounter是用来做什么的？
- 与读锁结合使用，记录某个线程重入的次数
- 两个属性，count，tid。count记录某个线程重入的次数，tid唯一标示一个线程

#### 写锁的获取与释放是怎么实现的？
- 写锁获取：`tryAcquire`获取当前写锁。获取当前线程，读取AQS中的状态值，获取写线程数量。如果state状态值为0，说明没有读线程，判断写线程是否应该被阻塞，非公平策略总是不会被阻塞，公平策略会进行判断，之后在设置state状态，将当前线程设置为独占线程。如果state状态不为0，如果写锁数量为0或者当前线程不是占用写锁资源的线程，返回false。否则设置state状态，返回true。

- 写锁释放：`tryRelease`释放写锁。如果不是独占线程，抛出异常。计算释放资源后的写锁数量，查看是否释放成功，如果释放成功，设置独占线程为空，设置状态。


#### 读锁的获取与释放是怎么实现的？
- 读锁获取：`tryAcquireShared`获取当前读锁。获得当前AQS中的状态值。如果写线程不为0，且获取锁线程不为当前线程，返回false。如果写线程为0或者当前线程为获取锁线程，获得读锁数量，如果读线程没有被阻塞，并且读线程没有大于最大数量，并且CAS设置写锁数量设置成功，如果读锁数量为0，将当前线程设置为第一个读者，占用资源数为1。如果读锁数量不为0并且当前线程是第一个读者，占用资源数加一。如果当前线程不是第一个读者并且读锁数量不为0，获得与读锁相关联的HolderCount，如果计数器中关联的线程不是当前线程或者HolderCount没有初始化，
获取当前线程的计数器，计数器加1。如果HolderCount中计数器为0，将当前线程计数器，计数加1。

- 读锁释放：`tryReleaseShared`读锁释放。获取当前线程，如果当前线程为读锁的第一个读者，如果第一个读者占用资源数为1，将读者置为空，否则占用资源减1。如果不是第一个读者，获取缓存的计数器。如果计数器为空或者计数器的tid不是当前运行线程的tid，获取当前线程的tid。获得计数器中的个数，如果占用资源个数小于等于1，移除计数器。否则占用资源数减1。最后通过CAS设置state的状态值。


#### ReentrantReadWriteLock为什么不支持锁升级？
- 为了保证数据的可见性，当读锁已经被多个线程获取，其中有一个线程获取了写锁并更新了数据，则数据的更改对其他线程来说是不可见的。
#### 什么是锁的升降级
- 锁的升级：保持住读锁，获取写锁，最后释放读锁。
- 锁的降级：保持住写锁，获取读锁，最后释放写锁。