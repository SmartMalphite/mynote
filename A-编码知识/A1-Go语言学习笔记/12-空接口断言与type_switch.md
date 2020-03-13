# 12|空接口断言与type switch

## 空接口的使用

可以用来判断数据类型

## Type Switch 的基本用法
Type Switch 是 Go 语言中一种特殊的 switch 语句，它比较的是类型而不是具体的值。它判断某个接口变量的类型，然后根据具体类型再做相应处理。注意，在 Type Switch 语句的 case 子句中不能使用fallthrough。

```go
package main

import "fmt"

//空接口断言
func doSomething(p interface{}) {
   if i,ok := p.(int);ok {
      fmt.Println("int")
      fmt.Println(i)
   }
   if i,ok := p.(string);ok {
      fmt.Println("string")
      fmt.Println(i)
   }
}

//GO语言的特殊switch--type switch
func doSomethingV2(p interface{}){
   switch v:=p.(type){
   case int:
      fmt.Println("int")
      fmt.Println(v)
   case string:
      fmt.Println("string")
      fmt.Println(v)
   default:
      fmt.Println("Unknown")
      fmt.Println(v)
   }
}

func main(){
   doSomething(10)    //int 10
   doSomething("abc") //string abc

   doSomethingV2(10)	//int 10
   doSomethingV2("abc")	//string abc
}
```

