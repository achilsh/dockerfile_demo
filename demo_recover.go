package main

import (
	"context"
	"fmt"
	"runtime"
	"strings"
)

func PanicCall(ctx context.Context) {
	ch := make(chan int, 3)
	v := []string{"a", "b", "c"}
	for _, vv := range v {
		go func() {
			fmt.Println(vv)  // GOEXPERIMENT=loopvar or use go version 1.22
			ch <- 1
		}()
	}
	for  range v {
		<-ch
	}

	if e := recover(); e != nil {
		buf := &strings.Builder{}
		pc := make([]uintptr, 10)
		n := runtime.Callers(3, pc)
		frames := runtime.CallersFrames(pc[:n])

		var frame runtime.Frame
		more := n > 0
		for more {
			frame, more = frames.Next()
			buf.Write([]byte(fmt.Sprintf("  => %s:%d %s\n", frame.File, frame.Line, frame.Function)))
		}

		fmt.Printf("e: %v, stack: %v\n", e, buf.String())
	}
}