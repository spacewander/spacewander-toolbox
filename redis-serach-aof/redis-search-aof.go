package main

/*
A simple tool to search keys in Redis' AOF file. When you need to hunt bug related to
Redis key change, you will benefit from it. It takes 2s to search multiple keys in 300M AOF file,
without warming up.

Usage: ./redis-search-aof [-e 1000] [-s 200] [-k key1 [-k ...]] [-r keyPattern1 [-r ...]] [aof filename]
  -e int
    	the end line to parse (default -1, means no limit)
  -s int
    	the start line to parse (default 1)
  -k value
    	the full key names used in matching keys
  -r value
    	the Go regex patterns used in matching keys
Both the start line and end line start from 1.

The output format is "startLine-endLine cmd"
308-320 HMSET client_a name a value 101
576-588 HMSET client_b name b value 102
*/

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"strconv"
	"sync"
)

type patterns []*regexp.Regexp

func (ps *patterns) String() string {
	return fmt.Sprintf("patterns: %v", *ps)
}

func (ps *patterns) Set(value string) error {
	*ps = append(*ps, regexp.MustCompile(value))
	return nil
}

type keys []string

func (ks *keys) String() string {
	return fmt.Sprint("keys: %v", *ks)
}

func (ks *keys) Set(value string) error {
	*ks = append(*ks, value)
	return nil
}

type Operation struct {
	CmdName   string
	DstKey    string
	Args      string
	StartLine int
	EndLine   int
}

func NewOperation(cmdName, dstKey, args string, startLine, endLine int) *Operation {
	return &Operation{
		CmdName:   cmdName,
		DstKey:    dstKey,
		Args:      args,
		StartLine: startLine,
		EndLine:   endLine,
	}
}

func (op *Operation) String() string {
	return fmt.Sprintf("%v-%v %v %v %v", op.StartLine, op.EndLine, op.CmdName, op.DstKey, op.Args)
}

type AOFScanner struct {
	reader *bufio.Reader
	err    error

	op          *Operation
	startLine   int
	endLine     int
	opStartLine int
	curLine     int
	narg        int
	cmdName     string
	dstKey      string
	args        []byte
}

func NewAOFScanner(reader *bufio.Reader, startLine, endLine int) *AOFScanner {
	return &AOFScanner{
		reader:      reader,
		startLine:   startLine,
		opStartLine: startLine,
		curLine:     startLine,
		endLine:     endLine,
	}
}

func (aof *AOFScanner) parseOperation() error {
	for {
		line, err := aof.reader.ReadBytes('\n')
		if err != nil {
			return err
		}
		aof.curLine++
		if len(line) <= 2 {
			// skip empty token, don't treat it as mark
			continue
		}
		// trim \r\n
		line = line[:len(line)-2]
		if len(line) > 1 {
			switch line[0] {
			case '*':
				narg, err := strconv.Atoi(string(line[1:]))
				if err != nil {
					return err
				}
				aof.narg = narg
				aof.opStartLine = aof.curLine
				continue
			case '$':
				// no need to handle bytes number because we read the whole cmd line
				continue
			}
		}
		if aof.narg == 0 {
			// skip if we have not got the sizes of args yet
			continue
		}
		if aof.cmdName == "" {
			aof.cmdName = string(line)
		} else if aof.dstKey == "" {
			aof.dstKey = string(line)
		} else if aof.args == nil {
			aof.args = line
		} else {
			aof.args = append(append(aof.args, ' '), line...)
		}
		aof.narg--
		if aof.narg == 0 {
			aof.op = NewOperation(aof.cmdName, aof.dstKey, string(aof.args), aof.opStartLine, aof.curLine)
			aof.cmdName = ""
			aof.dstKey = ""
			aof.args = nil
			return nil
		}
	}
	return nil
}

func (aof *AOFScanner) Scan() bool {
	// emit operation even its end line number is higher than endLine
	if aof.endLine != -1 && aof.curLine >= aof.endLine {
		return false
	}
	err := aof.parseOperation()
	if err != nil {
		if err != io.EOF {
			aof.err = err
		}
		return false
	}
	return true
}

func (aof *AOFScanner) Finish() {
	err := aof.err
	if err != nil {
		log.Fatalf("Scan failed: %s\n", err)
	}
}

func (aof *AOFScanner) Operation() *Operation {
	return aof.op
}

func main() {
	var startLine int
	var endLine int
	var keyPatterns patterns
	var keys keys
	flag.IntVar(&startLine, "s", 1, "the start line to parse")
	flag.IntVar(&endLine, "e", -1, "the end line to parse")
	flag.Var(&keyPatterns, "r", "the Go regex patterns used in matching keys")
	flag.Var(&keys, "k", "the full key names used in matching keys")
	flag.Parse()
	if len(keyPatterns) == 0 && len(keys) == 0 {
		log.Fatalln("Either -r or -k should be used to specify keys")
	}
	aofFile := flag.Arg(0)
	if aofFile == "" {
		aofFile = "appendonly.aof"
	}

	f, err := os.OpenFile(aofFile, os.O_RDONLY, 0444)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	reader := bufio.NewReader(f)
	lineNum := 1
	for {
		if lineNum == startLine {
			break
		}
		_, err := reader.ReadBytes('\n')
		if err != nil {
			log.Fatalf("Skip to start line failed: %s\n", err)
		}
		lineNum++
	}

	aof := NewAOFScanner(reader, startLine-1, endLine)
	defer aof.Finish()

	opChan := make(chan *Operation, 100)
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		for {
			op := <-opChan
			if op == nil {
				wg.Done()
				break
			}
			for _, p := range keyPatterns {
				if p.MatchString(op.DstKey) {
					fmt.Println(op)
					goto next
				}
			}
			for _, k := range keys {
				if k == op.DstKey {
					fmt.Println(op)
					goto next
				}
			}
		next:
		}
	}()

	for aof.Scan() {
		op := aof.Operation()
		opChan <- op
	}
	close(opChan)
	wg.Wait()
}
