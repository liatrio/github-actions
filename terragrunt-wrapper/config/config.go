package config

import (
	"errors"
	"flag"
	"github.com/peterbourgon/ff/v3"
	"os"
	"strings"
)

type Config struct {
	TerragruntStackPath string
	WorkingDirectory    string
	GitHub              *GitHubConfig
	IamRoleToAssume     string
	TerraformPath       string
}

type GitHubConfig struct {
	Owner             string
	Repository        string
	Token             string
	PullRequestNumber int
}

func Build(name string, args []string) (*Config, error) {
	flags := flag.NewFlagSet(name, flag.ContinueOnError)

	conf := &Config{
		GitHub: &GitHubConfig{},
	}

	var githubRepository string

	flags.StringVar(&conf.TerragruntStackPath, "terragrunt-stack-path", "", "")
	flags.StringVar(&githubRepository, "github-repository", "", "")
	flags.StringVar(&conf.GitHub.Token, "github-token", "", "")
	flags.IntVar(&conf.GitHub.PullRequestNumber, "github-pr-number", 0, "")
	flags.StringVar(&conf.IamRoleToAssume, "iam-role-to-assume", "", "")
	flags.StringVar(&conf.TerraformPath, "terraform-path", "", "")

	err := ff.Parse(flags, args, ff.WithEnvVarNoPrefix())
	if err != nil {
		return nil, err
	}

	if githubRepository == "" {
		return nil, errors.New("--github-repository must be set")
	}

	githubRepositoryParts := strings.Split(githubRepository, "/")
	if len(githubRepositoryParts) != 2 {
		return nil, errors.New("expected github repository to be in format ${org}/${repo}")
	}
	conf.GitHub.Owner = githubRepositoryParts[0]
	conf.GitHub.Repository = githubRepositoryParts[1]

	if conf.GitHub.Token == "" {
		return nil, errors.New("--github-token must be set")
	}

	if conf.GitHub.PullRequestNumber == 0 {
		return nil, errors.New("--github-pr-number must be set")
	}

	conf.WorkingDirectory, err = os.Getwd()
	if err != nil {
		return nil, err
	}

	return conf, nil
}
