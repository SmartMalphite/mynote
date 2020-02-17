# 21|context与任务取消

编程中往往需要通知子任务进行取消，常用方法有如下两种

### 1.基于channel关闭实现对任务取消的通知

利用上节中说道的channel关闭的广播机制通知所有任务进行取消

```go
package cancel_by_close

import (
	"fmt"
	"testing"
	"time"
)

func isCancelled(cancelChan chan struct{}) bool {
	select{
	case <-cancelChan:
		return true
	default :
		return false
	}
}

func TestCancel(t *testing.T){
	cancelChan := make(chan struct{},0)
	for i:=0;i<5;i++{
		go func(i int,cancelCH chan struct{}) {
			for {
				if isCancelled(cancelChan) {
					break
				}
				time.Sleep(time.Millisecond * 5)
			}
			fmt.Println(i,"Cancelled")
		}(i,cancelChan)
	}
	close(cancelChan)
	time.Sleep(time.Second * 1)
}

```

运行结果

```
=== RUN   TestCancel
3 Cancelled
1 Cancelled
4 Cancelled
2 Cancelled
0 Cancelled
--- PASS: TestCancel (1.00s)
PASS
```

### 2.通过Context实现任务取消

使用Go语言的上下文机制进行消息的传递，这里只介绍了Context中WithCancel的使用

```go
package cancel_by_close

import (
	"context"
	"fmt"
	"testing"
	"time"
)

func isCancelled(ctx context.Context) bool {
	select{
	case <-ctx.Done():	//通过ctx.Done 判断任务是否取消
		return true
	default :
		return false
	}
}

func TestCancel(t *testing.T){
	ctx,cancel := context.WithCancel(context.Background())	//创建context
	for i:=0;i<5;i++{
		go func(i int,ctx context.Context) {	//将context传入每个协程中
			for {
				if isCancelled(ctx) {
					break
				}
				time.Sleep(time.Millisecond * 5)
			}
			fmt.Println(i,"Cancelled")
		}(i,ctx)
	}
	cancel()	//发送cancel通知
	time.Sleep(time.Second * 1)
}

```

执行结果

```
=== RUN   TestCancel
3 Cancelled
2 Cancelled
0 Cancelled
1 Cancelled
4 Cancelled
--- PASS: TestCancel (1.00s)
PASS
```

