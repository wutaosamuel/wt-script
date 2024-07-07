package main

import (
	"errors"
	"regexp"
)

const (
	Pattern = `{{ ([^{}]*) }}`
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
					break;
				}
			}

			if !end {
				err = err + " " + key + "\n"
			}
		}

		return outputStr, errors.New(err)
	}

	return outputStr, nil
}

func replace(str string) string {
	return ""
}
