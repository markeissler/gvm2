package main

import "fmt"
import "runtime"

func main() {
    fmt.Printf("Hello %s/%s\n", runtime.GOOS, runtime.GOARCH)
}
