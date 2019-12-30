# 08|可变参数和defer

1. Defer 被用来确保一个函数调用在程序执行结束前执行。同样用来执行一些清理工作。defer 用在像其他语言中的 ensure 和 finally用到的地方。
2. 关键字 defer 允许我们推迟到函数返回之前（或任意位置执行 return 语句之后）一刻才执行某个语句或函数（为什么要在返回之后才执行这些语句？因为 return 语句同样可以包含一些操作，而不是单纯地返回某个值）。
3. 推迟的函数调用会被压入一个栈中。当外层函数返回时，被推迟的函数会按照

## 可变长参数

```go
package main

import "fmt"

func sum(ops ...int) int{
	s := 0
	for _,op := range ops{
		s += op
	}
	return s
}

func main(){
	fmt.Println(sum(1,2,3))
	fmt.Println(sum(1,2,3,4,5))
}

```

## 延时执行函数defer

```go
package main

import "fmt"

func main(){
	//延时函数，在函数最后返回前执行，可用于执行环境清理，及时报错也会执行
	defer func(){	//匿名函数
		fmt.Println("this is the end")	//这个函数依然会被执行
	}()
	fmt.Println("started")
	panic("error")

}
```

