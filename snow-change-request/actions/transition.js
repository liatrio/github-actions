import * as core from '@actions/core';
import * as serviceNow from '../snow.js';

export const transitionState = async (inputs) => {
    if (!inputs.transition) {
        throw new Error('Must specify the state to transition to');
    }

    if (!inputs.requestSysId) {
        throw new Error('Must set the change request sys id using the requestSysId input');
    }

    const snow = serviceNow.newClient(inputs);
    const states = inputs.transition.split('|');

    for (let i = 0; i < states.length; i++) {
        const state = states[i];
        core.info(`Transitioning to state '${state}'`);

        const updates = {
            state,
        };

        if (state === 'closed') {
            updates.close_code = 'successful';
            updates.close_notes = 'Automatically closed by snow-change-request action';
        }

        await snow.patch({
            path: `/api/sn_chg_rest/change/${inputs.requestSysId}`,
            body: updates,
        });
    }
};
