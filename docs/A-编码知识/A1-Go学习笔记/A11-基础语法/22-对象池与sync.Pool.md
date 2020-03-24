# 22|对象池与sync.Pool

## 对象池

当服务中有一些比较难以创建的对象时(如数据库连接等)，可以使用对象池将这些对象保存起来

### 使用buffer channel

对象以及方法的定义

```go
package pool

import (
	"github.com/pkg/errors"
	"time"
)

type ReusableObj struct {

}

type ObjPool struct {
	bufChan chan *ReusableObj	//用于缓冲可重用对象
}

func NewPool(num int) *ObjPool {
	objPool := ObjPool{}
	objPool.bufChan = make(chan *ReusableObj,num)
	for i := 0;i < num; i++{
		objPool.bufChan <- &ReusableObj{}
	}
	return &objPool
}

func (p *ObjPool) GetObj(timeout time.Duration) (*ReusableObj,error) {
	select {
	case ret := <-p.bufChan:
		return ret,nil
	case <-time.After(timeout):
		return nil,errors.New("time out")
	}
}

func (p *ObjPool) ReleaseObj(obj *ReusableObj) error {
	select {
	case p.bufChan <- obj:
		return nil
	default:
		return errors.New("overflow")
	}
}
```

测试程序

```go
package pool

import (
	"fmt"
	"testing"
	"time"
)

func TestObjPool(t *testing.T) {
	pool := NewPool(10)
	for i:=0;i<11;i++{
		if v,err := pool.GetObj(time.Second * 1);err != nil{
			t.Error(err)
		} else {
			fmt.Printf("%T\n",v)
			if err := pool.ReleaseObj(v);err != nil {
				t.Error(err)
			}
		}
	}
	fmt.Println("Done")
}
```

运行结果

```
=== RUN   TestObjPool
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
*pool.ReusableObj
Done
--- PASS: TestObjPool (0.00s)
```

## sync.Pool对象缓存

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