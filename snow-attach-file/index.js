import * as core from '@actions/core';
import fetch from 'node-fetch';
import path from 'path';
import * as fs from 'fs/promises';

const fail = (message) => {
    core.setFailed(message);
    process.exit(1);
}

const getInputs = () => {
    const inputs = {};
    [
        'filePath',
        'fileContentType',
        'requestSysId',
        'serviceNowInstanceUrl',
        'serviceNowUsername',
        'serviceNowPassword',
        'tableName',
    ].forEach((inputName) => {
        inputs[inputName] = core.getInput(inputName);
    });

    return inputs;
}

const {
    serviceNowInstanceUrl: serviceNowUrl,
    serviceNowUsername: username,
    serviceNowPassword: password,
    ...inputs
} = getInputs();

if (!(serviceNowUrl && username && password)) {
    fail('Must set ServiceNow url and credentials');
}

core.setSecret(password);
core.info(`Using ServiceNow instance: ${serviceNowUrl}`);

const basicAuth = Buffer.from(`${username}:${password}`).toString('base64');
core.setSecret(basicAuth);

try {
    const fileName = path.basename(inputs.filePath);
    const rawFile = await fs.readFile(inputs.filePath);
    const parameters = new URLSearchParams({
        table_name: inputs.tableName,
        table_sys_id: inputs.requestSysId,
        file_name: fileName,
    });
    const response = await fetch(`${serviceNowUrl}/api/now/attachment/file?${parameters}`, {
        method: 'POST',
        body: rawFile,
        headers: {
            'Accept': 'application/json',
            'Authorization': `Basic ${basicAuth}`,
            'Content-Type': inputs.fileContentType,
        }
    });

    if (!response.ok) {
        const responseText = await response.text();
        fail(`Non-2xx response code attaching file (${response.status}): ${responseText}`);
    }

    core.info('Successfully attached file');
} catch (error) {
    fail(`Error creating ticket attachment: ${error}`);
}
