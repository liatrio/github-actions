import * as core from '@actions/core';
import path from 'path';
import * as fs from 'fs/promises';
import * as serviceNow from '../snow.js';

export const attachFile = async (inputs) => {
    if (!inputs.attachmentFilePath) {
        throw new Error('Must specify an attachment using attachmentFilePath');
    }

    if (!inputs.requestSysId) {
        throw new Error('Must set the change request sys id using the requestSysId input');
    }

    const snow = serviceNow.newClient(inputs);
    const fileName = path.basename(inputs.attachmentFilePath);
    const rawFile = await fs.readFile(inputs.attachmentFilePath);

    core.info('Attaching file to change request');
    await snow.post({
        path: '/api/now/attachment/file',
        params: new URLSearchParams({
            table_name: inputs.attachmentTableName,
            table_sys_id: inputs.requestSysId,
            file_name: fileName,
        }),
        headers: {
            'Content-Type': inputs.attachmentFileContentType,
        },
        body: rawFile,
    })
    core.info('Successfully attached file');
};
