# 17| CSP并发

Go语言除了传统的共享内存机制外，还提供了一种基于channel的通信机制，即CSP机制

```go
package concurrency

import (
	"fmt"
	"testing"
	"time"
)

func service() string {
	time.Sleep(time.Millisecond * 30)
	return "Done"
}

func otherTask() {
	fmt.Println("this is other task")
	time.Sleep(time.Millisecond * 100)
	fmt.Println("Task is done")
}

//串行执行
func TestService(t *testing.T) {
	fmt.Println(service())
	otherTask()
}

//service 使用channel异步执行
func AsyncService() chan string { 
	//retCh := make(chan string,1)	//阻塞模式，即A将信息放进channel直到有人读取，否则将一直阻塞	
	retCh := make(chan string,1) //buffer模式，非阻塞 丢进channel就继续向下执行
	go func () {
		ret := service()
		fmt.Println("service return result")
		retCh <- ret 
		fmt.Println("service exited")
	}()
	return retCh
}

func TestAsynService(t *testing.T) {
	retCh := AsyncService()
	otherTask()
	fmt.Println(<-retCh)
	time.Sleep(time.Second * 1)
}

```

阻塞模式执行结果

```
Running tool: /usr/local/bin/go test -timeout 30s -run ^(TestAsynService)$

this is other task
service return result
Task is done
Done
service exited
PASS
ok  	_/Users/enbowang/Documents/my_code/go_learning/src/ch18/csp	2.681s
Success: Tests passed.
```

buffer模式执行结果

```
Running tool: /usr/local/bin/go test -timeout 30s -run ^(TestAsynService)$

this is other task
service return result
service exited
Task is done
Done
PASS
ok  	_/Users/enbowang/Documents/my_code/go_learning/src/ch18/csp	3.001s
Success: Tests passed.
```

