import * as core from '@actions/core';
import {
    attachFile,
    createChangeRequest,
} from './actions/index.js';

const getInputs = () => {
    const inputs = {};
    [
        'action',
        'approvalAssignmentGroup',
        'attachmentFilePath',
        'attachmentFileContentType',
        'attachmentTableName',
        'changeRequestMessage',
        'githubToken',
        'requestSysId',
        'serviceNowUrl',
        'serviceNowUsername',
        'serviceNowPassword',
    ].forEach((inputName) => {
        inputs[inputName] = core.getInput(inputName);
    });

    return inputs;
};

const fail = (message) => {
    core.setFailed(message);
    process.exit(1);
}

const inputs = getInputs();
const actions = {
    'attach-file': attachFile,
    create: createChangeRequest,
};

try {
    const action = actions[inputs.action];
    if (!action) {
        fail(`Unsupported action value: ${action}`);
    }

    await action(inputs);

} catch (error) {
    fail(`Error creating change request: ${error}`);
}
