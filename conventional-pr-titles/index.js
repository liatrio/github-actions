const core = require('@actions/core');
const github = require('@actions/github');
const commitParser = require('conventional-commits-parser');

const prefixes = new Set([
    'feat',
    'fix',
    'docs',
    'style',
    'refactor',
    'perf',
    'test',
    'build',
    'ci',
    'revert'
]);

const fail = (message) => {
    core.setFailed(message);
    process.exit(1);
}

core.info(`Triggered by ${github.context.eventName}`);

if (github.context.eventName !== 'pull_request') {
    fail('Expected event to be a pull request');
}

const title = github.context.payload.pull_request.title;

const titleComponents = commitParser.sync(title);

if (!titleComponents.type) {
    fail('Must specify a conventional commit prefix');
}

if (!prefixes.has(titleComponents.type)) {
    fail('Prefix must be one the allowed prefix types');
}
