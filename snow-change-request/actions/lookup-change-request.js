import * as core from '@actions/core';
import github from '@actions/github';

const sysIdComment = /^<![-]{2,}\s?sysid:\s?(?<sysId>[\w]{32})\s?[-]{2,}>\s?$/m;

export const lookupChangeRequest = async (inputs) => {
    const octokit = github.getOctokit(inputs.githubToken);
    const {owner, repo} = github.context.repo;
    const {sha} = github.context;

    core.info(`Finding pull requests associated with commit ${sha}`)
    const response = await octokit.rest.repos.listPullRequestsAssociatedWithCommit({
        owner,
        repo,
        commit_sha: sha,
    });

    const pulls = response.data;
    if (!pulls.length) {
        core.setFailed('No associated pull requests found');
        return;
    }

    for (let i = 0; i < pulls.length; i++) {
        const prNumber = pulls[i].number;
        core.info(`Looking at PR number ${prNumber}`);
        const sysId = await findSysIdInComments(octokit, {
            owner,
            repo,
            issue_number: prNumber,
        });

        if (sysId) {
            core.info(`Discovered change request sysid: ${sysId}`);
            core.setOutput('sysId', sysId);
            return
        }
        core.info('No comment with sysid information found on pull request');
    }

    core.setFailed('No pull request contained a comment with the sysid');
};

const findSysIdInComments = async (octokit, {owner, repo, issue_number}) => {
    core.info('Requesting comments');
    const response = await octokit.rest.issues.listComments({
        owner,
        repo,
        issue_number,
        per_page: 100,
    });

    for (let i = 0; i < response.data.length; i++) {
        const comment = response.data[i];
        const match = comment.body.match(sysIdComment);

        if (match) {
            return match.groups.sysId;
        }
    }

    return null;
}
