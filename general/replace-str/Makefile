# Go Parameters
GOCC=go
GOBUILD=$(GOCC) build
GOCLEAN=$(GOCC) clean
GOTEST=$(GOCC) test
GORUN=$(GOCC) run
BINARY_NAME=replace-str

# CMD dir
## GOCMD=./cmd
## GOBUILDWIN=$(GOCMD)/replace-str

# target dir
## TARGETDEB=$(GOCMD)/deb

# test dir dir
TESTDIR=./test

all: test build
build:
	$(GOBUILD) -o $(BINARY_NAME)
test:
	$(GOTEST) v .
clean:
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
deps:
	$(GOGET) -u 
debug:
	$(GORUN) . -input $(TESTDIR)/str.templ -config $(TESTDIR)/str.env -o $(TESTDIR)/str-result.txt

# Cross compilation
build-win:
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BINARY_NAME).exe -v $(GOBUILDWIN)
