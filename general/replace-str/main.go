package main

import (
	"errors"
	"flag"
	"fmt"
	"os"
)

func main() {
	// phrase flags
	inputStr, configStr, outputPath, err := phraseFlags()
	if err != nil {
		println(err, '\n')
		flag.Usage()
		os.Exit(1)
	}

	// convert configStr to map[string]string
	config := GetKVs(configStr)

	// replace
	result, err := ReplaceString(inputStr, config)
	if err != nil {
		println(err, '\n')
		os.Exit(1)
	}

	// print out result string or save to file
	if outputPath == "" {
		fmt.Print(result)
	} else {
		if err := os.WriteFile(outputPath, []byte(result), 0644); err != nil {
			println(err, '\n')
			os.Exit(1)
		}
	}
}

func phraseFlags() (inputStr, configStr, outputPath string, err error) {
	var (
		template     string
		templateFile string
		config       string
		configFile   string
		outputFile   string
	)

	flag.StringVar(&template, "i", "", "template string ")
	flag.StringVar(&templateFile, "input", "", "template file path")
	flag.StringVar(&config, "c", "", "config string")
	flag.StringVar(&configFile, "config", "", "config file path")
	flag.StringVar(&outputFile, "o", "", "output file path, The program prints string as default, if no path specified")

	flag.Usage = func() {
		fmt.Println("usage: [-i | -input] [-c | -config] [-o]")
		fmt.Println()
		
		flag.PrintDefaults()
	}

	if template == "" && templateFile == "" {
		e := "must specify input string or file with -i or -input"
		return "", "", "", errors.New(e)
	}
	if template != "" && templateFile != "" {
		e := "cannot specify both input string and file"
		return "", "", "", errors.New(e)
	}
	if config == "" && configFile == "" {
		e := "must specify config string or file with -i or -input"
		return "", "", "", errors.New(e)
	}
	if config != "" && configFile != "" {
		e := "cannot specify both config string and file"
		return "", "", "", errors.New(e)
	}

	if templateFile != "" {
		buffer, err := os.ReadFile(templateFile)
		if err != nil {
			return "", "", "", err
		}
		template = string(buffer)
	}
	if configFile != "" {
		buffer, err := os.ReadFile(configFile)
		if err != nil {
			return "", "", "", err
		}
		config = string(buffer)
	}

	return template, config, outputFile, nil
}
