# 20|channel的关闭和广播

## 注意事项

1.向关闭的channel发送数据，会导致panic

2.v,ok <- ch;ok 为bool值，true标识正常接收，false表示通道关闭

3.所有的channel接受者都会在channel关闭时，立刻从阻塞等待中返回且上述ok值为false。这个广播机制常被利用，进行向多个订阅者同时发送信号，如：退出信号

## 实战

首先要了解channel广播的必要性以及其他解决方案的缺陷：

1.如果不通知接收者，那么接收者将不知道生产者何时停止数据发送，接收者将一直接收到channel对应数据类型的0值

2.那么如果在生产者结束数据生产后发送一个特殊的flag如-1呢？这种方式的缺点是只能适用于一个接收者的场景，当有多个接收者时，需要一一通知接收者停止接受数据，这样就比较麻烦，所以Go通过广播机制通知所有接收者

```go
package channel_close

import (
	"fmt"
	"sync"
	"testing"
)

//数据生产者
func dataProducer(ch chan int, wg *sync.WaitGroup) {
	go func() {
		for i := 0; i < 10; i++ {
			ch <- i
		}
		close(ch)	//	channel的关闭

		wg.Done()
	}()

}

//数据接受者
func dataReceiver(ch chan int, wg *sync.WaitGroup) {
	go func() {
		for {
			if data, ok := <-ch; ok {	//channel关闭后，ok值将变为false
				fmt.Println(data)
			} else {
				break
			}
		}
		wg.Done()
	}()

}

func TestCloseChannel(t *testing.T) {
	var wg sync.WaitGroup
	ch := make(chan int)
	wg.Add(1)
	dataProducer(ch, &wg)
	wg.Add(1)
	dataReceiver(ch, &wg)
	// wg.Add(1)
	// dataReceiver(ch, &wg)
	wg.Wait()

}
```

