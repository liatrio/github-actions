package main

import (
	"context"
	"github.com/liatrio/github-actions/terragrunt-wrapper/comments"
	"github.com/liatrio/github-actions/terragrunt-wrapper/config"
	"github.com/liatrio/github-actions/terragrunt-wrapper/terragrunt"
	"log"
	"os"
)

func main() {
	ctx := context.Background()

	conf, err := config.Build(os.Args[0], os.Args[1:])
	if err != nil {
		log.Fatalf("failed to build config: %v", err)
	}

	stages, stack, err := terragrunt.GetStagesInExecutionOrder(conf)
	if err != nil {
		log.Fatalf("failed to get terragrunt stages: %v", err)
	}

	commentWriter := comments.NewCommentWriter(ctx, conf)
	commentWriter.WriteString(comments.GetMarkdownSummaryForStack(stack))

	for _, stage := range stages {
		result, planSummary, err := terragrunt.RunPlanForStage(conf, stage)
		if err != nil {
			log.Fatalf("failed to run terragrunt for %s stage: %v", stage, err)
		}

		commentWriter.WriteString(comments.GetMarkdownSummaryForStage(stage, result, planSummary))
	}

	err = commentWriter.PostComments(ctx)
	if err != nil {
		log.Fatalf("failed to post comments to GitHub: %v", err)
	}
}
