import * as core from '@actions/core';
import github from '@actions/github';
import fetch from 'node-fetch';
import dayjs from 'dayjs';
import utc from 'dayjs/plugin/utc.js'

dayjs.extend(utc);

const serviceNowUrl = core.getInput('serviceNowInstanceUrl');
const username = core.getInput('serviceNowUsername');
const password = core.getInput('serviceNowPassword');
const changeRequestMessage = core.getInput('changeRequestMessage');

const fail = (message) => {
    core.setFailed(message);
    process.exit(1);
}

if (!(serviceNowUrl && username && password)) {
    fail('Must set ServiceNow url and credentials');
}

core.setSecret(password);
core.info(`Using ServiceNow instance: ${serviceNowUrl}`);

const basicAuth = Buffer.from(`${username}:${password}`).toString('base64');
core.setSecret(basicAuth);

const octokit = github.getOctokit(core.getInput('githubToken'));

const serviceNowApiClient = async ({method = 'GET', path, params, body}) => {
    const options = {
        method,
        headers: {
            'Accept': 'application/json',
            'Authorization': `Basic ${basicAuth}`,
        },
    };

    if (body) {
        options.body = JSON.stringify(body);
        options.headers['Content-Type'] = 'application/json';
    }

    let url = `${serviceNowUrl}${path}`;
    if (params) {
        url = `${url}?${new URLSearchParams(params)}`
    }

    const response = await fetch(url, options);
    if (!response.ok) {
        fail(`Non-2xx response code from ServiceNow (${response.status}): ${await response.text()}`);
    }

    return response.json();
}

try {
    core.info('Finding approval groups');
    const userGroups = await serviceNowApiClient({
        path: '/api/now/table/sys_user_group',
        params: {
            name: 'CAB Approval',
        },
    });
    const approvalGroupId = userGroups.result[0].sys_id;

    const now = dayjs.utc();
    const changeStart = now.format('YYYY-MM-DD HH:mm:ss');
    const changeEnd = now.add(1, 'hour').format('YYYY-MM-DD HH:mm:ss');

    core.info('Creating change request');
    const changeRequest = await serviceNowApiClient({
        method: 'POST',
        path: '/api/sn_chg_rest/change/normal',
        body: {
            assignment_group: approvalGroupId,
            description: changeRequestMessage,
            short_description: 'Automated change request',
            state: 'assess',
            start_date: changeStart,
            end_date: changeEnd,
        },
    });
    const requestNumber = changeRequest?.result?.number?.value;
    const sysId = changeRequest?.result?.sys_id?.value;

    if (!sysId) {
        fail('Unable to find change request id in response');
    }

    const link = `${serviceNowUrl}/nav_to.do?uri=${encodeURIComponent(`/change_request.do?sys_id=${sysId}`)}`;
    core.info('Successfully created change request');
    core.info(`View the change request: ${link}`);

    core.setOutput('sysId', sysId);
    core.setOutput('number', requestNumber);

    const comment = `
# ServiceNow Change Request

[\`${requestNumber}\`](${link})

State: \`assess\` 

<!---sysid: ${sysId}--->
`;
    const {owner, repo, number: issue_number} = github.context.issue;

    if (issue_number) {
        core.info(`Commenting on pull request ${owner}/${repo}#${issue_number}`);

        const response = await octokit.rest.issues.createComment({
            owner,
            repo,
            issue_number,
            body: comment,
        });

        core.info(response.data.html_url);
    }
} catch (error) {
    fail(`Error creating change request: ${error}`);
}
