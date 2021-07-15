# JUC工具类

### CountDownLatch
#### 什么是CountDownLatch? 
将一个程序分为n个互相独立的可解决任务，并创建值为CountDownLatch。当每一个任务完成时，都会在这个锁存器上调用countDown，等待问题被解决的任务调用这个锁存器的await，阻塞自己，知道锁存器计数结束。
#### CountDownLatch底层实现原理? 
- 基于AQS，AQS是通过内部类Sync来实现的
#### CountDownLatch一次可以唤醒几个任务? 多个 
#### CountDownLatch有哪些主要方法? await(),countDown() 
#### CountDownLatch适用于什么场景? 
#### 写道题：实现一个容器，提供两个方法，add，size 写两个线程，线程1添加10个元素到容器中，线程2实现监控元素的个数，当个数到5个时，线程2给出提示并结束? 
```java
public class T3 {

	volatile List<Integer> list = new ArrayList<>();

	public void add(int i) {
		list.add(i);
	}

	public int getSize() {
		return list.size();
	}

	public static void main(String[] args) {

		T3 t3 = new T3();
		CountDownLatch countDownLatch = new CountDownLatch(1);

		new Thread(() -> {
			System.out.println("t2 启动");
			if(t3.getSize()!=5){
				try {
					countDownLatch.await();
					System.out.println("t2 结束");
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}, "t2").start();

		new Thread(() -> {
			System.out.println("t1 启动");
			for(int i = 0;i<10;i++){
				t3.add(i+1);
				if(t3.getSize() == 5){
					System.out.println("CountDown is open");
					countDownLatch.countDown();
				}
			}
			System.out.println("t1 结束");
		}, "t1").start();
	}
}
```
#### 使用CountDownLatch 代替wait notify 好处。

### CyclicBarrier
#### 什么是CyclicBarrier? 
#### CyclicBarrier底层实现原理? 
#### CountDownLatch和CyclicBarrier对比? 
- CountDownLatch 减计数，CyclicBarrier加计数
- CountDownLatch 是一次性的，CyclicBarrier可以重复使用
- CountDownLatch 和CyclicBarrier都有让多个线程等待然后再开始进行下一步的意思，但是CountDownLatch的下一步执行者是主线程，CyclicBarrier的下一个动作实施者是其他线程本身，具有往复多次实施动作的特点。
#### CyclicBarrier的核心函数有哪些? 
#### CyclicBarrier适用于什么场景?
### Semaphore

### Phaser

### Exchanger