package comments

import (
	"context"
	"github.com/google/go-github/v39/github"
	"github.com/liatrio/github-actions/terragrunt-wrapper/config"
	"golang.org/x/oauth2"
	"strings"
)

const (
	MAX_COMMENT_LENGTH = 65536
	SEPARATOR          = "\n---\n"
)

type CommentWriter struct {
	conf     *config.Config
	client   *github.Client
	comments []strings.Builder
}

func NewCommentWriter(ctx context.Context, conf *config.Config) *CommentWriter {
	return &CommentWriter{
		conf:     conf,
		client:   githubClient(ctx, conf.GitHub.Token),
		comments: []strings.Builder{{}},
	}
}

func githubClient(ctx context.Context, accessToken string) *github.Client {
	client := github.NewClient(oauth2.NewClient(ctx, oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: accessToken},
	)))

	return client
}

// shouldWriteToNewComment returns true if the comment we want to write will exceed the MAX_COMMENT_LENGTH for GitHub
// Pull Request comments, and false otherwise.
func (c *CommentWriter) shouldWriteToNewComment(str string) bool {
	return len(str)+len(SEPARATOR)+c.comments[len(c.comments)-1].Len() > MAX_COMMENT_LENGTH
}

// currentCommentIsEmpty returns true if the last strings.Builder within the comments slice is empty, and false otherwise.
func (c *CommentWriter) currentCommentIsEmpty() bool {
	return c.comments[len(c.comments)-1].Len() == 0
}

func (c *CommentWriter) write(str string) {
	c.comments[len(c.comments)-1].WriteString(str)
}

func (c *CommentWriter) WriteString(str string) {
	// if we're about to exceed the max length, start writing to another comment
	if c.shouldWriteToNewComment(str) {
		c.comments = append(c.comments, strings.Builder{})
	} else { // otherwise, add a separator and continue
		if !c.currentCommentIsEmpty() { // but don't add one if the current comment is empty
			c.write(SEPARATOR)
		}
	}

	c.write(str)
}

func (c *CommentWriter) PostComments(ctx context.Context) error {
	for _, builder := range c.comments {
		comment := builder.String()

		_, _, err := c.client.Issues.CreateComment(ctx, c.conf.GitHub.Owner, c.conf.GitHub.Repository, c.conf.GitHub.PullRequestNumber, &github.IssueComment{
			Body: &comment,
		})
		if err != nil {
			return err
		}
	}

	return nil
}
