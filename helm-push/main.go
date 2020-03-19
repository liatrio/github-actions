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

func retrieveEnvironmentVariables() map[string]string {
	envVars := make(map[string]string)
	envVars["ARGS"] = os.Getenv("ARGS")
	envVars["INPUT_APPVERSION"] = os.Getenv("INPUT_APPVERSION")
	envVars["INPUT_CHART"] = os.Getenv("INPUT_CHART")
	envVars["INPUT_BUCKET"] = os.Getenv("INPUT_BUCKET")
	envVars["INPUT_VERSION"] = os.Getenv("INPUT_VERSION")
	return envVars
}

func getHelmRepositories(helmRepositories *[]helmRepository) error {
	args := os.Args[1]
	err := json.Unmarshal([]byte(args), helmRepositories)
	if err != nil {
		return err
	}
	return nil
}

func main() {
	//function to retrieve all env vars
	// main should just serve as place to run each command from entrypoin

	var helmRepositories []helmRepository

	err := getHelmRepositories(&helmRepositories)
	if err != nil {
		fmt.Println(err)
		return
	}

	fmt.Println(helmRepositories)

	fmt.Println("hello world")

	fmt.Println(retrieveEnvironmentVariables())
}
