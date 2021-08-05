import * as core from '@actions/core';
import {
    attachFile,
    createChangeRequest,
    approveNormalChangeRequest,
    lookupChangeRequest,
    requireChangeRequestApproval,
    transitionState,
} from './actions/index.js';

const getInputs = () => {
    const inputs = {};
    [
        'action',
        'approvalAssignmentGroup',
        'attachmentFilePath',
        'attachmentFileName',
        'attachmentFileContentType',
        'attachmentTableName',
        'changeRequestMessage',
        'githubToken',
        'transition',
        'requestSysId',
        'sha',
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
    approve: approveNormalChangeRequest,
    'lookup-change-request': lookupChangeRequest,
    'require-approval': requireChangeRequestApproval,
    transition: transitionState,
};

try {
    const action = actions[inputs.action];
    if (!action) {
        fail(`Unsupported action value: ${action}`);
    }

    await action(inputs);
} catch (error) {
    fail(`Error performing action '${inputs.action}' on change request: ${error}`);
}
