package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type helmRepository struct {
	Name string `json:"name"`
	Url  string `json:"url"`
}

func retrieveEnvironmentVariables() {

}

func getHelmRepositories(helmRepositories *[]helmRepository, args string) error {
	err := json.Unmarshal([]byte(args), helmRepositories)
	if err != nil {
		return err
	}
	return nil
}

func main() {
	//function to retrieve all env vars
	// main should just serve as place to run each command from entrypoin
	args := os.Args[1]
	var helmRepositories []helmRepository

	err := getHelmRepositories(&helmRepositories, args)
	if err != nil {
		fmt.Println(err)
		return
	}

	fmt.Println(helmRepositories)

	fmt.Println("hello world")
}
