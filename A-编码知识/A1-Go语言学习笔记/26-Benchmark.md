# 26|Benchmark

单元测试更多的倾向于代码验证逻辑的正确性，当需要验证代码改动的性能影响时我们可以使用Benchmark来进行测试

代码如下，比较了两种字符串拼接方式的性能差异

```go
package benchmark_test

import (
	"bytes"
	"testing"
)

func BenchmarkConcatStringByAdd(b *testing.B){
	elems := []string{"1","2","3","4","5"}
	b.ResetTimer()
	for i:=0;i<b.N;i++{
		ret := ""
		for _,elem := range elems{
			ret += elem
		}
	}
	b.StopTimer()
}

func BenchmarkConcatStringByBytesBuffer(b *testing.B){
	elems := []string{"1","2","3","4","5"}
	b.ResetTimer()
	for i:=0;i<b.N;i++{
		var buf bytes.Buffer
		for _,elem := range elems{
			buf.WriteString(elem)
		}
	}
	b.StopTimer()
}
```

运行结果

```
➜  go test -bench=.
goos: darwin
goarch: amd64
pkg: golearning/src/ch26/benchmark_test
BenchmarkConcatStringByAdd-12                   10000000               124 ns/op
BenchmarkConcatStringByBytesBuffer-12           20000000                60.1 ns/op
PASS
ok      golearning/src/ch26/benchmark_test      4.476s

```

可以看出，第二种方式性能比第一种提高了一被左右

当我们想分析下性能差距的原因的时候，可以使用如下参数

```
➜  benchmark_test go test -bench=. -benchmem
goos: darwin
goarch: amd64
pkg: golearning/src/ch26/benchmark_test
BenchmarkConcatStringByAdd-12                   10000000               125 ns/op              16 B/op          4 allocs/op
BenchmarkConcatStringByBytesBuffer-12           20000000                61.1 ns/op            64 B/op          1 allocs/op
PASS
ok      golearning/src/ch26/benchmark_test      2.903s
```

可见第一种方法进行了四次内存相关操作，而第二种方式只进行了一次操作，所以性能优于第一种方式