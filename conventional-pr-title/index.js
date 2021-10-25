const core = require('@actions/core');
const github = require('@actions/github');
const commitParser = require('conventional-commits-parser');

const fail = (message) => {
    core.setFailed(message);
    process.exit(1);
};

const validate = (prefixes, message) => {
    const {type} = commitParser.sync(message);

    if (!type) {
        return fail('Must specify a conventional commit prefix. See https://www.conventionalcommits.org/en/v1.0.0/ for more information.');
    }

    if (!prefixes.has(type)) {
        return fail(`Pull request title or commit prefix must be one of the following: ${Array.from(prefixes.values()).join('|')}`);
    }
}

(async () => {
    try {
        const prefixInput = core.getInput('prefixes')
            .split('\n')
            .map((prefix) => prefix.trim());
        core.info(`Using prefixes: ${prefixInput}`);

        const token = core.getInput('token');
        if (!token) {
            fail("Missing required input 'token'");
        }

        const octokit = github.getOctokit(core.getInput('token'));
        const prefixes = new Set(prefixInput);

        if (github.context.eventName !== 'pull_request') {
            fail(`Expected to be triggered from a pull request event, but was ${github.context.eventName}`);
        }

        core.info('Checking pull request title');
        validate(prefixes, github.context.payload.pull_request.title);

        const {owner, repo, number} = github.context.issue;
        core.info('Checking if there are multiple commits in the pull request');
        const commits = await octokit.rest.pulls.listCommits({
            owner,
            repo,
            pull_number: number,
        });

        if (commits.data.length > 1) {
            core.info('Skipping commit check since there are multiple commits');
            return;
        }

        core.info('Single commit pull request, validating that the only commit uses prefixes');
        validate(commits.data[0].commit.message);
    } catch (error) {
        fail(`Error validating pull request title: ${error.stack}`);
    }
})();
