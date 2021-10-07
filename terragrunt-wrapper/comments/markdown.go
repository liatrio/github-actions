package comments

import (
	"fmt"
	"github.com/gruntwork-io/terragrunt/configstack"
)

const (
	TRIPLE_BACKTICS = "```"
)

func GetMarkdownSummaryForStack(stack *configstack.Stack) string {
	return fmt.Sprintf(`
Successfully ran plan for stack.
<details><summary>Show Stack Information</summary>

%s
%s
%s
</details>
`, TRIPLE_BACKTICS, stack.String(), TRIPLE_BACKTICS)
}

func GetMarkdownSummaryForStage(stage, result, planSummary string) string {
	return fmt.Sprintf(`
<details><summary>Show plan output for "%s" stage</summary>

%s
%s
%s
</details>
<br>
<details><summary>Show plan summary</summary>

%sdiff
%s
%s
</details>
`, stage, TRIPLE_BACKTICS, result, TRIPLE_BACKTICS, TRIPLE_BACKTICS, planSummary, TRIPLE_BACKTICS)
}
