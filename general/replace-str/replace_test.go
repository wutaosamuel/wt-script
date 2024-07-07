package main

import "testing"

func TestReplaceString(t *testing.T) {
	const (
		Str = "{{ city }}, { state } {{ zip }}"
	)
	var KV = map[string]string{
		"city":  "Shang Hai",
		//"state": "Shang Hai",
		"zip":   "30000",
	}

	outputStr, err := ReplaceString(Str, KV)
	if err != nil {
		t.Error(err)
	}
	if outputStr != "Shang Hai, { state } 30000" {
		t.Error(outputStr)
	}
}
