# 24|sync.Pool对象缓存

Sync.Pool总结

1. 适用于通过复用，降低复杂对象的创建和GC代价
2. 协程安全，会有锁的开销
3. 生命周期受GC影响，不适用与做连接池等，需自己管理生命周期的资源的池化

```go
package obj_cache

import (
	"fmt"
	"runtime"
	"sync"
	"testing"
)

//基本使用
func TestSyncPool(t *testing.T){
	pool := &sync.Pool{
		New: func() interface{} {
			fmt.Println("Create a new object")
			return 100
		},
	}

	v := pool.Get()
	fmt.Println(v)
	pool.Put(3)
	runtime.GC()	//GC 会清除sync.pool中缓存的对象
	v1 := pool.Get()
	fmt.Println(v1)

}

//在多协程中的应用
func TestSyncPoolMultiGroutine(t *testing.T) {
	pool := &sync.Pool{
		New:func() interface{} {
			fmt.Println("Create a new object")
			return 10
		},
	}
	pool.Put(100)
	pool.Put(101)
	pool.Put(102)

	var wg sync.WaitGroup
	for i:=0;i<10;i++{
		wg.Add(1)
		go func(id int){
			fmt.Println(id)
			fmt.Println(pool.Get())
			wg.Done()
		}(i)
	}
	wg.Wait()
}
```

注意，使用这种方式或者连接池，并不一定能优化性能，因为增加了其他性能开销(如锁等)，需要权衡利弊，对于简单对象就没必要使用这些方式了