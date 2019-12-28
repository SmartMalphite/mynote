# 5.Map的使用

## Map的声明

map的声明方式与列表类似，不过声明时并没有初始化len

```go
//声明方式1
m := map[string]int{"one":1,"two":2}

//方式2
m1 := map[string]int{}

//方式3 make
m2 := make(map[string]int,10)
```

下面用一段代码示例演示map的使用

注意 map通过make方法创建时，只需要指定cap，并不能指定len。且map不能使用cap()方法获取容量

```go
package main

import "fmt"

func main(){
	m1 :=map[int]string{1:"one"}
	fmt.Println(m1[1])		//one
	fmt.Println(len(m1))	//1

	m1[2] = "two"
	fmt.Println(m1[2])		//two
	fmt.Println(len(m1))	//2

	m2 := make(map[int]string,10)
	fmt.Println(len(m2))	//0
	//fmt.Println(cap(m2))	//map不允许这种方式访问

	m2[1] = "qqq"
	fmt.Println(len(m2))	//1

}
```

另外，在go语言中，当访问map中不存在的索引时，会给他一个默认值，这就会导致一个问题，就是无法区分取出来的值真的是0值还是因为不存在分配的默认值，可以通过以下方式解决

```GO
package main

import "fmt"

func main(){	
	m3 := map[int]int{}
	fmt.Println(m3[1])	//0

	m3[2] = 0
	fmt.Println(m3[2])	//0
  
  //解决方式如下
  if v,ok := m3[1];ok{
		fmt.Println("value is ",v)
	}else{
		fmt.Println("not exist")
	}
  
}
```

## Map的遍历

遍历方式与数组和切片相同

```go
m4 :=map[int]string{1:"one",2:"two"}
for k,v := range m4 {
   fmt.Println(k,v)
}
```

## Map元素的删除

```go
delete(m1,"one")
```

## 通过Map实现工厂模式

```Go
package main

import "fmt"

func main(){
   m1 := map[int]func(op int)int{}
   m1[1] = func(op int) int {return op}
   m1[2] = func(op int) int {return op*op}
   m1[3] = func(op int) int {return op*op*op}

   fmt.Println(m1[1](2))
   fmt.Println(m1[2](2))
   fmt.Println(m1[3](2))

}
```

## 也可以通过Map实现一个set

```go
package main

import "fmt"

func main(){
	 //一个set的基本要求
   //可以添加元素且元素不重复
   //判断元素是否存在
   //删除元素
   //元素个数

   set := map[int]bool{}
  
   //添加元素
   set[1] = true
   set[3] = true
   set[1] = true
   fmt.Println(set)
  
	 //判断元素是否存在
   n := 1
   if set[n] {
      fmt.Println("exist")
   }else{
      fmt.Println("not exist")
   }

   //元素数量
   fmt.Println(len(set))
   
   //删除元素
   delete(set,n)
   fmt.Println(set)
```

