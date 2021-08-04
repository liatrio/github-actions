import * as core from '@actions/core';
import fetch from 'node-fetch';

const request = async (config, method, {headers, body, params, path}) => {
    const options = {
        method,
        headers: {
            'Accept': 'application/json',
            'Authorization': `Basic ${config.basic}`,
            ...headers,
        },
    };

    if (body) {
        if (typeof body === 'object') {
            options.body = JSON.stringify(body);
            options.headers['Content-Type'] = 'application/json';
        } else {
            options.body = body
        }
    }

    let url = `${config.serviceNowUrl}${path}`;
    if (params) {
        url = `${url}?${new URLSearchParams(params)}`
    }

    core.debug(`Making request to ${path}`);
    const response = await fetch(url, options);
    if (!response.ok) {
        throw new Error(`Non-2xx response code from ServiceNow (${path}) [${response.status}]: ${await response.text()}`);
    }

    return response.json();
};

export const newClient = (inputs) => {
    const {
        serviceNowUsername,
        serviceNowPassword,
        serviceNowUrl,
    } = inputs;

    if (!(serviceNowUrl && serviceNowUsername && serviceNowPassword)) {
        throw new Error('Must set ServiceNow url and credentials');
    }

    core.setSecret(serviceNowPassword);
    core.info(`Using ServiceNow instance: ${serviceNowUrl}`);
    const basic = Buffer.from(`${serviceNowUsername}:${serviceNowPassword}`).toString('base64');
    core.setSecret(basic);

    const config = {basic, serviceNowUrl};

    return {
        get: request.bind(null, config, 'GET'),
        patch: request.bind(null, config, 'PATCH'),
        post: request.bind(null, config, 'POST'),
    }
};
