package main

import "context"

func main() {
	call_panic()

}

func call_panic() {
	defer PanicCall(context.Background())
	func() {
		var x *int = nil 
		*x = 123
	}()
}