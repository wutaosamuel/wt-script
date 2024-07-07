package main

import (
	"errors"
	"flag"
	"os"
)

func main() {
	// phrase flags
	/*
	inputStr, configStr, outputPath, err := phraseFlags()
	if err != nil {
		println(err, '\n')
		flag.Usage()
		os.Exit(1)
	}
	*/
	// replace
}

func phraseFlags() (inputStr, configStr, outputPath string, err error) {
	var (
		template string
		templateFile string
		config string
		configFile string
		outputFile string
	)

	flag.StringVar(&template, "i", "", "The template string for processing")
	flag.StringVar(&templateFile, "input", "", "The template file path for processing")
	flag.StringVar(&config, "c", "", "The config string, contenting data")
	flag.StringVar(&configFile, "config", "", "The config file, contenting data")
	flag.StringVar(&outputFile, "o", "", "The output file path. The program prints string as default, if no path specified")

	if template == "" && templateFile == "" {
		e := "must specify input string or file with -i or -input\n"
		return "", "", "", errors.New(e) 
	}
	if template != "" && templateFile != "" {
		e := "cannot specify both input string and file\n"
		return "", "", "", errors.New(e) 
	}
	if config == "" && configFile == "" {
		e := "must specify config string or file with -i or -input\n"
		return "", "", "", errors.New(e) 
	}
	if config != "" && configFile != "" {
		e := "cannot specify both config string and file\n"
		return "", "", "", errors.New(e) 
	}

	if templateFile != "" {
		buffer, err := os.ReadFile(templateFile)
		if err != nil {
			return "", "", "",  err
		}
		template = string(buffer)
	}
	if configFile != "" {
		buffer, err := os.ReadFile(configFile)
		if err != nil {
			return "", "", "",  err
		}
		config = string(buffer)
	}

	return template, config, outputFile, nil
}
