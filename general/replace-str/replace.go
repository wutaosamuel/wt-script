package main

import (
	"errors"
	"regexp"
)

const (
	Pattern   = `{{ ([^{}]*) }}`
	KVPattern = `(\w+)=([^=]*\w)(?:\s|$)`
)

func ReplaceString(inputStr string, KVs map[string]string) (string, error) {
	var replacedKey = make([]string, 0)
	var excludeKey = make([]string, 0)

	reg := regexp.MustCompile(Pattern)
	outputStr := reg.ReplaceAllStringFunc(inputStr, func(str string) string {
		key := reg.FindStringSubmatch(str)[1]
		value, ok := KVs[key]
		if ok {
			replacedKey = append(replacedKey, key)
			return value
		}

		if !ok {
			excludeKey = append(excludeKey, key)
		}
		return ""
	})
	DBG_PRINTF("replaced key: len %d, %q\n", len(replacedKey), replacedKey)
	DBG_PRINTF("not used Key: len %d, %q\n", len(excludeKey), excludeKey)
	DBG_PRINTF("config key/val: %q\n", KVs)

	if len(excludeKey) != 0 {
		err := "the template has the following keys not used:\n"
		for _, k := range excludeKey {
			err = err + " " + k + "\n"
		}

		return outputStr, errors.New(err)
	}
	if len(replacedKey) < len(KVs) {
		err := "the config has the following keys not used:\n"
		for key := range KVs {
			var end = false
			for _, r := range replacedKey {
				if key == r {
					end = true
					break
				}
			}

			if !end {
				err = err + " " + key + "\n"
			}
		}

		DBG_PRINTLN("replaced result:", outputStr)
		return outputStr, errors.New(err)
	}

	return outputStr, nil
}

func GetKVs(configStr string) map[string]string {
	var KVs = make(map[string]string, 0)

	reg := regexp.MustCompile(KVPattern)
	matches := reg.FindAllStringSubmatch(configStr, -1)

	for _, match := range matches {
		KVs[match[1]] = match[2]
	}

	return KVs
}
