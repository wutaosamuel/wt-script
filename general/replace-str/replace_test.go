package main

import (
	"testing"
)

func TestReplaceString(t *testing.T) {
	const (
		Str = "{{ city }}, { state } {{ zip }}"
	)
	var KV = map[string]string{
		"city": "Shang Hai",
		//"state": "Shang Hai",
		"zip": "30000",
	}

	outputStr, err := ReplaceString(Str, KV)
	if err != nil {
		t.Error(err)
	}
	if outputStr != "Shang Hai, { state } 30000" {
		t.Error(outputStr)
	}
}

const (
	config = `city=Shang Hai

zip=30000`
	config2 = "city=Shang Hai zip=30000"
	config3 = "name=Hello World gender=male phone=00 123456"
)

var (
	configKV = map[string]string {
	"city": "Shang Hai",
	"zip": "30000",
}
	configKV3 = map[string]string {
	"name": "Hello World",
	"gender": "male",
	"phone": "00 123456",
}
)

func TestGetKVs(t *testing.T) {
	kv := GetKVs(config)
	if !isMapEqual(kv, configKV) {
		t.Error("config not equal")
	}

	kv2 := GetKVs(config2)
	if !isMapEqual(kv2, configKV) {
		t.Error("config2 not equal")
	}

	kv3 := GetKVs(config3)
	if !isMapEqual(kv3, configKV3) {
		t.Error("config3 not equal")
	}
}

func isMapEqual(map1, map2 map[string]string) bool {
	for key, value := range map1 {
		if value != map2[key] {
			return false
		}
	}

	return true
}
