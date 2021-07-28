import * as core from '@actions/core';
import fetch from 'node-fetch';

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

try {
    const basicAuth = Buffer.from(`${username}:${password}`).toString('base64')
    core.setSecret(basicAuth);

    const response = await fetch(`${serviceNowUrl}/api/sn_chg_rest/change/normal`, {
        method: 'POST',
        body: JSON.stringify({
            description: changeRequestMessage,
            short_description: 'Automated change request',
        }),
        headers: {
            'Accept': 'application/json',
            'Authorization': `Basic ${basicAuth}`,
            'Content-Type': 'application/json',
        }
    });

    if (!response.ok) {
        const responseText = await response.text();
        fail(`Non-2xx response code creating change request (${response.status}): ${responseText}`);
    }

    const changeRequest = await response.json();
    const id = changeRequest?.result?.number?.value;

    if (!id) {
        fail("Unable to find change request id in response");
    }

    core.setOutput("id", id);
} catch (error) {
    fail(`Error creating change request: ${error}`);
}
