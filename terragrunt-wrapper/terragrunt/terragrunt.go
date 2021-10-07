package terragrunt

import (
	"bytes"
	"fmt"
	"github.com/gruntwork-io/terragrunt/cli"
	"github.com/gruntwork-io/terragrunt/configstack"
	"github.com/gruntwork-io/terragrunt/options"
	"github.com/liatrio/github-actions/terragrunt-wrapper/config"
	"io"
	"os"
	"path/filepath"
	"strings"
)

var TF_ACTIONS = map[string]string{
	"will be updated in-place": "!",
	"will be created":          "+",
	"will be destroyed":        "-",
	"must be replaced":         "-",
}

func GetStagesInExecutionOrder(conf *config.Config) ([]string, *configstack.Stack, error) {
	terragruntOptions, err := options.NewTerragruntOptions("")
	if err != nil {
		return nil, nil, err
	}

	terragruntWorkingDir := filepath.Join(conf.WorkingDirectory, conf.TerragruntStackPath)
	terragruntOptions.WorkingDir = terragruntWorkingDir

	stack, err := configstack.FindStackInSubfolders(terragruntOptions)
	if err != nil {
		return nil, nil, err
	}

	stages := make(map[string][]string)

	for _, module := range stack.Modules {
		name := getModuleName(module.Path, terragruntWorkingDir)
		var deps []string

		for _, dependency := range module.Dependencies {
			deps = append(deps, getModuleName(dependency.Path, terragruntWorkingDir))
		}

		stages[name] = deps
	}

	var (
		stageOrder []string
		stagesPtr  = &stages
	)

	for {
		if len(stageOrder) == len(stages) {
			break
		}

		for stage, deps := range *stagesPtr {
			if len(deps) == 0 {
				stageOrder = append(stageOrder, stage)
				newStages := removeStage(stage, *stagesPtr)

				stagesPtr = &newStages
				continue
			}
		}
	}

	return stageOrder, stack, nil
}

func RunPlanForStage(conf *config.Config, stage string) (string, string, error) {
	terragruntWorkingDir := filepath.Join(conf.WorkingDirectory, conf.TerragruntStackPath)
	stageWorkDir := filepath.Join(terragruntWorkingDir, stage)

	fmt.Printf("Running Terragrunt for %s stage (%s)\n", stage, stageWorkDir)

	terragruntOptions, err := options.NewTerragruntOptions(filepath.Join(stageWorkDir, "terragrunt.hcl"))
	if err != nil {
		return "", "", err
	}

	var buff bytes.Buffer

	terragruntOptions.Writer = io.MultiWriter(os.Stdout, &buff)
	terragruntOptions.TerraformCliArgs = []string{"plan", "-no-color"}
	terragruntOptions.Env = parseEnvironmentVariables()
	terragruntOptions.AutoInit = true
	terragruntOptions.SourceUpdate = true
	terragruntOptions.IamRole = conf.IamRoleToAssume
	terragruntOptions.TerraformPath = conf.TerraformPath

	err = cli.RunTerragrunt(terragruntOptions)
	if err != nil {
		return "", "", err
	}

	var (
		sb      strings.Builder
		started bool
		plan    strings.Builder
	)
	for {
		if buff.Len() == 0 {
			break
		}

		str, err := buff.ReadString('\n')
		if err != nil {
			return "", "", err
		}

		if strings.Contains(str, "Terraform will perform the following actions") {
			started = true
		}

		if started {
			sb.WriteString(str)
		} else {
			continue
		}

		for action, symbol := range TF_ACTIONS {
			if strings.Contains(str, action) {
				plan.WriteString(fmt.Sprintf("%s %s", symbol, strings.TrimPrefix(str, "  # ")))

				break
			}
		}

		if strings.Contains(str, "Plan:") {
			plan.WriteString(str)
			break
		}
	}

	return sb.String(), plan.String(), nil
}

// given a stage name and a map of stages -> deps, return a new map with all references to that stage omitted
func removeStage(stageName string, stages map[string][]string) map[string][]string {
	result := make(map[string][]string)

	for stage, deps := range stages {
		if stage == stageName {
			continue
		}

		var newDeps []string
		for _, dep := range deps {
			if dep == stageName {
				continue
			}

			newDeps = append(newDeps, dep)
		}

		result[stage] = newDeps
	}

	return result
}

func getModuleName(path, workingDir string) string {
	return strings.TrimPrefix(path, fmt.Sprintf("%s%c", workingDir, os.PathSeparator))
}

func parseEnvironmentVariables() map[string]string {
	environment := os.Environ()
	environmentMap := make(map[string]string)

	for i := 0; i < len(environment); i++ {
		variableSplit := strings.SplitN(environment[i], "=", 2)

		if len(variableSplit) == 2 {
			environmentMap[strings.TrimSpace(variableSplit[0])] = variableSplit[1]
		}
	}

	return environmentMap
}
