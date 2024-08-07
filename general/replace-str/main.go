package main

import (
	"errors"
	"flag"
	"fmt"
	"os"
)

// TODO: add support for comment

func main() {
	// phrase flags
	inputStr, configStr, outputPath, err := phraseFlags()
	if err != nil {
		fmt.Println(err)
		flag.Usage()
		os.Exit(1)
	}
	fmt.Println("input")

	// convert configStr to map[string]string
	config := GetKVs(configStr)

	// replace
	result, err := ReplaceString(inputStr, config)
	if err != nil {
		fmt.Println(err, '\n')
		os.Exit(1)
	}

	// print out result string or save to file
	if outputPath == "" {
		fmt.Print(result)
	} else {
		if err := os.WriteFile(outputPath, []byte(result), 0644); err != nil {
			fmt.Println(err, '\n')
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
		help         bool
		helpFlag     bool
	)

	flag.StringVar(&template, "i", "", "template string ")
	flag.StringVar(&templateFile, "input", "", "template file path")
	flag.StringVar(&config, "c", "", "config string")
	flag.StringVar(&configFile, "config", "", "config file path")
	flag.StringVar(&outputFile, "o", "", "output file path, The program prints string as default, if no path specified")
	flag.BoolVar(&help, "h", false, "show help")
	flag.BoolVar(&helpFlag, "help", false, "show help")
	flag.Usage = func() {
		fmt.Println("usage: [-i | -input] [-c | -config] [-o]")
		fmt.Println()

		flag.PrintDefaults()
	}

	flag.Parse()
	if help || helpFlag {
		flag.Usage()
		os.Exit(0)
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
