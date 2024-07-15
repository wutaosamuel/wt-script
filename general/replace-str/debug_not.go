//go:build !debug

package main

func DBG_PRINTF(format string, arg ...interface{}) {}

func DBG_PRINTLN(a ...interface{}) {}
