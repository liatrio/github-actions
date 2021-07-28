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

const basicAuth = Buffer.from(`${username}:${password}`).toString('base64');
core.setSecret(basicAuth);

try {

    core.info('Creating change request');
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
    const requestNumber = changeRequest?.result?.number?.value;
    const sysId = changeRequest?.result?.sys_id?.value;

    if (!sysId) {
        fail("Unable to find change request id in response");
    }

    const link = `${serviceNowUrl}/nav_to.do?uri=${encodeURIComponent(`/change_request.do?sys_id=${sysId}`)}`;
    core.info("Successfully created change request");
    core.info(`View the change request: ${link}`);

    core.setOutput("sysId", sysId);
    core.setOutput("number", requestNumber);
} catch (error) {
    fail(`Error creating change request: ${error}`);
}
