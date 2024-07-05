package main

import (
	"flag"
	"regexp"
)

func main() {
	// phrase flags

	// read input
	// replace

	reg := regexp.MustCompile(`{{ ([^{}]*) }}`)
	reg.ReplaceAllStringFunc("{{city}}, {{ state }} {{ zip }}", replace)
}

func phraseFlags() {
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

}
